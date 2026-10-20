# Class 4: HTTP Requests & Async Programming

> **Reference Application Grounding**:
> All practical demonstrations and code samples in this session are grounded in the reference repository [Mr Fix It UI](https://github.com/WSU-kduncan/mr-fixit-ui).
> Specific reference files:
>
> - `src/environments/environment.ts` (API base URL configuration)
> - `src/app/services/api.service.ts` (centralized HTTP gateway wrapping GET and POST)
> - `src/app/services/work-order.service.ts` (domain service fetching and mapping work order entities)
> - `src/app/features/work-orders/components/work-order-list/` (reactive UI handling loading, error, and data states)

## The Anatomy of an HTTP Request

Up to this point, our components have rendered mock in-memory arrays. Real web applications communicate with backend servers over HTTP to fetch and save data.

An HTTP transaction consists of two halves:

1. **The Request**: Sent by the browser client to an endpoint URL. It contains:
   - **Method (Verb)**: The intended action (`GET` to read, `POST` to create, `PUT`/`PATCH` to update, `DELETE` to remove).
   - **Endpoint Path**: Identifies the resource location (such as `/mr-fixit-service/work_order`).
   - **Headers**: Metadata describing the request (`Content-Type: application/json`, `Accept: application/json`).
   - **Body (Payload)**: JSON-formatted data sent with `POST` or `PUT` requests.
2. **The Response**: Returned by the server. It contains:
   - **Status Code**: A numeric code indicating the outcome:
     - `200 OK`: Request succeeded.
     - `400 Bad Request`: Client sent malformed or invalid data.
     - `404 Not Found`: The requested URL path does not exist on the server.
     - `500 Internal Server Error`: Backend unhandled exception or crash.
     - `Status 0`: Browser network failure (backend is offline, or request blocked by CORS).
   - **Headers**: Metadata returned by the server.
   - **Body**: The payload, typically serialized JSON data.

In `mr-fixit-ui`, the demo API (`mr-fixit-service`) provides `GET` and `POST` routes.

## Section 1. Full-Stack HTTP Flow in Angular

In `mr-fixit-ui`, HTTP communication is split into distinct layers:

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
│ - Logs outgoing requests and responses                 │
└───────────────────────────┬────────────────────────────┘
                            │ HTTP Network Request
┌───────────────────────────▼────────────────────────────┐
│ Backend Server (Spring Boot on localhost:8080)          │
└────────────────────────────────────────────────────────┘
```

## Section 2. Observables vs. Signals: Bridging Async Data

Angular works with two reactive primitives:

- **Signals**: Synchronous value containers designed for UI rendering.
- **Observables (RxJS)**: Asynchronous event streams that deliver values over time.

Because network calls take time to complete, Angular's `HttpClient` returns an RxJS `Observable<T>`.

HTTP observables in Angular are **cold** and **finite**:

- Cold means the HTTP request does not fire until someone subscribes to it.
- Finite means once the server returns a response, the observable emits that payload and immediately completes.

### Pattern 1: Declarative Conversion with `toSignal`

Best for read-only streams that load on component initialization:

```typescript
import { Component, inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { WorkOrderService } from '../../services/work-order.service';

@Component({ ... })
export class OrderListComponent {
  private readonly orderService = inject(WorkOrderService);

  // Automatically subscribes and unpacks the observable into a read-only signal
  readonly orders = toSignal(this.orderService.getWorkOrders(), {
    initialValue: [] // Critical: Prevents undefined crashes before response arrives
  });
}
```

#### Student Survival Pitfall: Forgetting `initialValue`

If you omit `initialValue: []`, the signal starts as `undefined`. When your template tries to loop over `@for (order of orders(); track order.id)`, it crashes immediately with:

```
TypeError: Cannot read properties of undefined (reading 'track')
```

Always provide an empty array (`initialValue: []`) so the template renders an empty state while waiting for the response.

Checkpoint:

> "Why do we pass `initialValue: []` to `toSignal()` when fetching an array?"  
> To give the signal a valid empty array while the network request is still loading, preventing template evaluation errors.

### Pattern 2: Controlled Subscription with `takeUntilDestroyed`

Best for services with reload buttons or user-triggered requests:

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
      takeUntilDestroyed(this.destroyRef) // Automatically cancels if destroyed
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

## Section 3. Configuring HttpClient and the ApiService Gateway

In standalone Angular, `HttpClient` is registered in `src/app/app.config.ts`:

```typescript
// src/app/app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideHttpClient } from '@angular/common/http';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient()
  ]
};
```

#### Student Survival Pitfall: Missing Provider

If you inject `HttpClient` without calling `provideHttpClient()` in `app.config.ts`, your app crashes with:

```
NullInjectorError: No provider for _HttpClient!
```

Whenever you see this error, open `src/app/app.config.ts` and verify `provideHttpClient()` is inside `providers`.

Checkpoint:

> "If the console shows `NullInjectorError: No provider for _HttpClient!`, what is missing?"  
> `provideHttpClient()` was not added to the providers array in `src/app/app.config.ts`.

### The `ApiService` Gateway in `mr-fixit-ui`

`ApiService` centralizes your backend URL:

```typescript
// src/app/services/api.service.ts
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = environment.apiUrl; // e.g. 'http://localhost:8080/mr-fixit-service'

  get<T>(endpoint: string): Observable<T> {
    return this.http.get<T>(`${this.baseUrl}/${endpoint}`);
  }

  post<T>(endpoint: string, body: unknown): Observable<T> {
    return this.http.post<T>(`${this.baseUrl}/${endpoint}`, body);
  }
}
```

## Section 4. Four UI States: Loading, Empty, Success, and Error

Every network interaction should account for all four UI states:

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

## Section 5. Live Demo in Mr Fix It UI

1. Open `http://localhost:4200/dashboard`.
2. Open DevTools (`F12` or `Cmd+Option+I`) and switch to the **Network** tab.
3. Filter requests by **Fetch/XHR**.
4. Reload the page and find the request to `http://localhost:8080/mr-fixit-service/work_order`.
5. Inspect the response payload: confirm the JSON keys match the TypeScript interfaces in `src/app/shared/models/`.
6. Simulate a backend outage: stop the Spring Boot backend process on port 8080.
7. Click the **Retry** button in Angular:
   - Notice the request fail with status `0` (connection refused).
   - Notice the Angular UI render the error banner without crashing.
8. Restart the backend and click **Retry** to demonstrate recovery.

## Section 6. Transfer into Students Repo

The last 20 minutes are for students to implement Homework 4 in their assigned components:

### Homework 4: Component Logic, Signals & Services

1. **Extract Domain Service**: Generate a service (`ng g s services/<domain>`) and move domain signals and item operations into it.
2. **Inject the Service**: In your assigned feature component from `COMPONENT_PLAN.md`, inject the service using `inject()`.
3. **Build Child Component**: Create a child detail/card component with signal `input()` and render it within your parent component.
4. **Interactive Signals**: Bind user events `(click)` or `(input)` to update signals via `.set()` and `.update()`.
5. **Git Commit & Push**: Commit your changes and push to `lastname-homework4`.
