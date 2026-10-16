# Class 4 — HTTP Requests & Async Programming

> 💡 **Reference Application Grounding (`wsu-test`)**:
> All practical demonstrations and code samples in this session are grounded in `/Users/edjenkins/Documents/GitHub/WSU/2025/wsu-test`.
> Specific reference files:
> - `src/environments/environment.ts` (API base URL configuration)
> - `src/app/services/api.service.ts` (centralized HTTP gateway wrapping GET and POST)
> - `src/app/services/work-order.service.ts` (domain service fetching and mapping work order entities)
> - `src/app/features/work-orders/components/work-order-list/` (reactive UI handling loading, error, and data states)

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
│ Component Layer (WorkOrderListComponent)               │
│ - Triggers reload requests                             │
│ - Reads reactive signals for rendering                 │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│ Domain Service (WorkOrderService)                      │
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
    initialValue: [] // CRITICAL: Prevents undefined crashes before response arrives!
  });
}
```

#### ⚠️ Student Survival Pitfall: Forgetting `initialValue`
If you omit `initialValue: []`, the signal's initial value is `undefined`. When your template attempts to render `@for (order of orders(); track order.id)`, the template evaluates immediately and crashes with:
```
TypeError: Cannot read properties of undefined (reading 'track')
```
Always provide an empty array (`initialValue: []`) so the template renders an empty state while the network request is in flight!

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
      takeUntilDestroyed(this.destroyRef) // Automatically cancels on component destruction!
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

#### ⚠️ Student Survival Pitfall: Leaked Subscriptions
If you subscribe manually in a component without `takeUntilDestroyed`, the subscription continues running in the background even if the user navigates to another page. Always attach `.pipe(takeUntilDestroyed(this.destroyRef))`!

## Section 1. The HTTP Protocol and REST Fundamentals

RESTful APIs map resources to standard HTTP verbs:
- `GET /work_order`: Fetches a list of work orders.
- `GET /work_order/101`: Fetches details for work order #101.
- `POST /work_order`: Creates a new work order.

In `wsu-test`, the demo API (`mr-fixit-service`) provides `GET` and `POST` routes. It does not expose `PUT` or `DELETE`.

> 🧪 **Simpler Lab Reference in `wsu-test`**:
> Want to see Angular's modern signal-native `httpResource` API where loading, error, and value signals are created with zero subscription boilerplate? Open `http://localhost:4200/labs/http-resource` (Lab 10) in `wsu-test` (`src/app/features/labs/http-resource-lab/`).

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

#### ⚠️ Student Survival Pitfall: Missing Provider
If you inject `HttpClient` without calling `provideHttpClient()` in `app.config.ts`, your app will crash with:
```
NullInjectorError: No provider for _HttpClient!
```
Whenever you see this error, check `src/app/app.config.ts` and ensure `provideHttpClient()` is included in the `providers` array.

### The `ApiService` Gateway in `wsu-test`

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
    return this.http.get<T>(`${this.baseUrl}/${endpoint}`);
  }

  post<T>(endpoint: string, body: unknown): Observable<T> {
    return this.http.post<T>(`${this.baseUrl}/${endpoint}`, body);
  }
}
```

> 🧪 **Simpler Lab Reference in `wsu-test`**:
> Want to test retry interceptors with exponential backoff on 500/503 server errors in an interactive simulator? Open `http://localhost:4200/labs/http-resilience` (Lab 11) in `wsu-test` (`src/app/features/labs/http-resilience-lab/`).

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

1. Open `http://localhost:4200/dashboard`.
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
4. **Bridge to Signals**: Unpack the HTTP response into a component signal using `toSignal()` (with `initialValue: []`) or `.subscribe()` with a signal `.set()`.
5. **Implement 4 UI States**: Your template must display:
   - Loading indicator while the request is in flight.
   - Error banner with retry option if the call fails.
   - Data list with `@for` when items exist.
   - Empty state when the server returns an empty list.
6. **Live Backend Requirement**: Connect directly to your Spring Boot API. Do not use fake timeout arrays. If your request fails, ask the instructor for help.

## Lab References: Simpler Isolated Examples in `wsu-test`

In `wsu-test`, navigate to `http://localhost:4200/labs` to open the **Learning Studio** catalog.

- **Lab 10 — `httpResource` API (`/labs/http-resource`)**:
  - **Route**: `http://localhost:4200/labs/http-resource`
  - **Source Code**: `src/app/features/labs/http-resource-lab/`
  - **What it demonstrates**: Single-file component using Angular's modern `httpResource` API. An editable order-number signal drives the HTTP request, automatically producing `value`, `isLoading`, and `error` signals without manual subscriptions.
  - **Why consult this lab**: Shows the future of Angular HTTP data fetching in a clean, self-contained view.

- **Lab 11 — HTTP Interceptors & Resilience (`/labs/http-resilience`)**:
  - **Route**: `http://localhost:4200/labs/http-resilience`
  - **Source Code**: `src/app/features/labs/http-resilience-lab/`
  - **What it demonstrates**: Interactive request simulator demonstrating `retryInterceptor` (exponential backoff on transient 500/503 errors), `errorInterceptor` logging, and centralized error boundary toasts.
  - **Why consult this lab**: Helps you visualize what happens under the hood when a server endpoint fails or drops a connection.
