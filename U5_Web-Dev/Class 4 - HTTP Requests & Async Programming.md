# Class 4 — HTTP Requests & Async Programming

## Setting the Stage: The Anatomy of an HTTP Request

Up to this point, our components have consumed mock in-memory arrays. In production systems, client applications communicate with server APIs over HTTP (HyperText Transfer Protocol) to fetch and persist data.

An HTTP transaction consists of two halves:
1. **The Request**: Sent by the browser client to an origin URL. It contains:
   - **Method (Verb)**: Indicates the intended action (`GET` for reading, `POST` for creating, `PUT`/`PATCH` for updating, `DELETE` for removing).
   - **Endpoint Path**: Identifies the resource location (such as `/mr-fixit-service/work_order`).
   - **Headers**: Metadata describing the request (`Content-Type: application/json`, `Accept: application/json`).
   - **Body (Payload)**: JSON-formatted data sent with `POST` or `PUT` requests.
2. **The Response**: Returned by the server. It contains:
   - **Status Code**: A numeric indicator of the result:
     - `200 OK`: Request succeeded.
     - `400 Bad Request`: Client sent invalid or malformed data.
     - `404 Not Found`: The requested URL path does not exist on the server.
     - `500 Internal Server Error`: Backend unhandled exception or crash.
     - `Status 0`: Browser network failure (backend is offline, or request blocked by CORS).
   - **Headers**: Metadata returned by the server.
   - **Body**: The payload, typically serialized JSON data.

## Full-Stack HTTP Architecture in Angular

In the reference application `wsu-test`, HTTP communication is organized into distinct layers following the Single Responsibility Principle:

```
┌────────────────────────────────────────────────────────┐
│ Component Layer (e.g. WorkOrderListComponent)           │
│ - Triggers reload requests                             │
│ - Reads reactive signals for rendering                 │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│ Domain Service (e.g. WorkOrderService)                 │
│ - Manages business models (WorkOrder[])               │
│ - Maintains signal store                               │
│ - Coordinates endpoint paths                           │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│ Gateway Service (ApiService)                           │
│ - Prepends base API URL (http://localhost:8080/...)    │
│ - Appends standard JSON headers                        │
│ - Delegates to Angular HttpClient                      │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│ Angular HttpClient & Interceptors                      │
│ - retryInterceptor (retries transient 5xx GET calls)   │
│ - errorInterceptor (logs errors and rethrows)          │
└───────────────────────────┬────────────────────────────┘
                            │ HTTP Network Request
┌───────────────────────────▼────────────────────────────┐
│ Backend Server (Spring Boot on localhost:8080)          │
└────────────────────────────────────────────────────────┘
```

## Observables vs. Signals: The Asynchronous Bridge

Angular uses two distinct reactive paradigms:
- **Signals**: Synchronous, value-oriented state containers designed for UI rendering.
- **Observables (RxJS)**: Asynchronous event streams that deliver values over time.

Because network calls take time to complete, `HttpClient` returns an RxJS `Observable<T>`.

**Crucial Observable Property**: `HttpClient` observables are **cold** and **finite**. The HTTP request does not execute until someone subscribes to it. Once the server returns a response, the observable emits that single payload and immediately **completes**.

### Two Patterns to Bridge Observables to Signals

#### Pattern 1: Declarative Conversion with `toSignal`
Best for read-only streams that initialize on component load:
```typescript
import { Component, inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { WorkOrderService } from '../../services/work-order.service';

@Component({ ... })
export class OrderListComponent {
  private readonly orderService = inject(WorkOrderService);

  // Automatically subscribes and unpacks the observable into a read-only signal
  readonly orders = toSignal(this.orderService.getWorkOrders(), {
    initialValue: []
  });
}
```
*Note*: The `initialValue: []` is mandatory. Without it, the signal initially holds `undefined`, which crashes template `@for` loops before the network request resolves.

#### Pattern 2: Controlled Subscription with `takeUntilDestroyed`
Best for reloadable services and user-triggered fetches:
```typescript
import { Injectable, signal, inject, DestroyRef } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ApiService } from './api.service';

@Injectable({ providedIn: 'root' })
export class WorkOrderService {
  private readonly api = inject(ApiService);
  private readonly destroyRef = inject(DestroyRef);

  private readonly _orders = signal<WorkOrder[]>([]);
  readonly orders = this._orders.asReadonly();
  readonly isLoading = signal<boolean>(false);
  readonly errorMessage = signal<string | null>(null);

  reloadWorkOrders(): void {
    this.isLoading.set(true);
    this.errorMessage.set(null);

    this.api.get<WorkOrder[]>('/work_order').pipe(
      takeUntilDestroyed(this.destroyRef) // Cancels in-flight request if destroyed
    ).subscribe({
      next: (data) => {
        this._orders.set(data);
        this.isLoading.set(false);
      },
      error: (err) => {
        this.errorMessage.set('Failed to load work orders from server.');
        this.isLoading.set(false);
      }
    });
  }
}
```

## Section 1. The HTTP Protocol and REST Fundamentals

RESTful APIs map resources to standard HTTP verbs:
- `GET /work_order`: Fetches a list of work orders.
- `GET /work_order/101`: Fetches details for work order #101.
- `POST /work_order`: Creates a new work order.

In `wsu-test`, the demo API (`mr-fixit-service`) provides `GET` and `POST` routes. It does not provide `PUT` or `DELETE`.

Checkpoint:
> "If your Spring Boot backend returns HTTP 404, what does that mean?"
> The requested endpoint URL does not match any `@GetMapping` or `@RequestMapping` path on your Spring controller.

## Section 2. Configuring HttpClient and the ApiService Gateway

In modern standalone Angular, `HttpClient` is registered globally in `src/app/app.config.ts`:

```typescript
// src/app/app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { retryInterceptor } from './shared/interceptors/retry.interceptor';
import { errorInterceptor } from './shared/interceptors/error.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(
      withInterceptors([retryInterceptor, errorInterceptor])
    )
  ]
};
```

### The `ApiService` Gateway

`ApiService` encapsulates the server host URL:

```typescript
// src/app/services/api.service.ts
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = environment.apiUrl; // e.g., 'http://localhost:8080/mr-fixit-service'

  get<T>(endpoint: string): Observable<T> {
    return this.http.get<T>(`${this.baseUrl}${endpoint}`);
  }

  post<T>(endpoint: string, body: unknown): Observable<T> {
    return this.http.post<T>(`${this.baseUrl}${endpoint}`, body);
  }
}
```

## Section 3. Robust UI States: Loading, Empty, Success, and Error

A complete network interaction must handle all four UI states explicitly:

```html
<!-- src/app/features/work-orders/components/work-order-list/work-order-list.component.html -->
<section class="work-order-view">
  <h2>Maintenance Work Orders</h2>

  <!-- 1. Error State -->
  @if (errorMessage()) {
    <div class="alert alert--danger" role="alert">
      <p>{{ errorMessage() }}</p>
      <button type="button" (click)="reload()">Retry Connection</button>
    </div>
  }

  <!-- 2. Loading State -->
  @else if (isLoading()) {
    <div class="loading-container">
      <p>Fetching work orders from server...</p>
    </div>
  }

  <!-- 3. Success State with Empty Check -->
  @else {
    <div class="orders-grid">
      @for (order of orders(); track order.id) {
        <article class="order-card">
          <h3>{{ order.title }}</h3>
          <span class="status">{{ order.status.code }}</span>
        </article>
      } @empty {
        <!-- 4. Empty State -->
        <p class="empty-notice">No work orders returned by the server.</p>
      }
    </div>
  }
</section>
```

## Section 4. Live Demo in `wsu-test`

1. Open http://localhost:4200/dashboard.
2. Open DevTools (`F12` or `Cmd+Option+I`) and navigate to the **Network** tab.
3. Filter requests by **Fetch/XHR**.
4. Reload the page and locate the request to `http://localhost:8080/mr-fixit-service/work_order`.
5. Inspect the response payload: verify the JSON keys match the TypeScript model interfaces in `src/app/shared/models/`.
6. Simulate a server drop: stop the Spring Boot backend process on port 8080.
7. Click the **Retry** button in Angular:
   - Observe the request fail with status `0` / connection refused.
   - Observe the Angular UI render the error banner without crashing the application.
8. Restart the backend and click **Retry** to demonstrate recovery.

## Section 5. Transfer into Students Repo

The last 20 minutes are dedicated to connecting each student's frontend to **their own** backend API:

### Homework 4: HTTP Requests & Async Programming

1. **Configure HttpClient**: Add `provideHttpClient()` to your `app.config.ts`.
2. **Environment URL**: Define your backend API base URL in `src/environments/environment.ts`.
3. **Build the Gateway or Service**: Inject `HttpClient` into your data service and write a typed `GET` method returning an Observable.
4. **Bridge to Signals**: Unpack the HTTP response into a component signal using `toSignal()` or `.subscribe()` with a signal `.set()`.
5. **Implement 4 UI States**: Your template must display:
   - Loading indicator while the request is in flight.
   - Error banner with retry option if the call fails.
   - Data list with `@for` when items exist.
   - Empty state when the server returns an empty list.
6. **Live Backend Requirement**: Connect directly to your Spring Boot API. Do not use fake timeout arrays. If your request fails, ask the instructor for help.

## After Class (Ungraded Resources)

- `/labs/http-resource` (Lab 10): Exploring Angular's signal-driven `httpResource` API with built-in loading and error signals.
- `/labs/http-resilience` (Lab 11): Simulating network latency, transient 503 drops, and centralized error boundary interception.
