## **🌐 Class 3 — HTTP Requests & Async Programming**

### **Goal**

Understand how to communicate with backend APIs asynchronously using Angular's HttpClient and integrate the resulting data streams (Observables) into the component's reactive state (Signals) using examples from the WSU Work Order Management system.

### **Topics**

#### **What is an HTTP Request?**

An HTTP (Hypertext Transfer Protocol) request is the mechanism by which a client (like an Angular application running in a browser) communicates with a server to request or send data. The most common types of requests, or "verbs," for a full-stack application are:

* **GET:** Retrieve data from the server.
* **POST:** Send new data to the server to create a resource.
* **PUT / PATCH:** Send data to update an existing resource.
* **DELETE:** Request that the server delete a resource.

**In our WSU Work Order Management system:**

- **GET /work_order** - Retrieve all work orders
- **GET /work_order/{id}** - Get a specific work order by ID
- **POST /work_order** - Create a new work order
- **GET /work_order/category** - Get all work order categories
- **GET /work_order/status** - Get all work order statuses

#### **The HttpClient Service**

Angular provides a dedicated service, `HttpClient`, for making HTTP requests. It is a simplified client HTTP API that rests on the `XMLHttpRequest` interface exposed by browsers. Its major features include the ability to request typed response values, streamlined error handling, and request/response interception.

To use `HttpClient`, it must be made available to the application's dependency injection system. In a modern standalone application, this is done by calling `provideHttpClient()` within the providers array in `app.config.ts`.

**WSU Application Configuration:**

```ts
// src/app/app.config.ts
import { ApplicationConfig, provideBrowserGlobalErrorListeners, provideZoneChangeDetection } from '@angular/core';
import { provideRouter, withComponentInputBinding } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';

import { routes } from './app.routes';
import { errorInterceptor } from '@shared/interceptors/error.interceptor';
import { retryInterceptor } from '@shared/interceptors/retry.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes, withComponentInputBinding()),
    provideHttpClient(
      withInterceptors([retryInterceptor, errorInterceptor]) // Adding interceptors
    )
  ]
};
```

**Key Configuration Concepts:**

**`provideHttpClient()` with Interceptors:**
- Registers `HttpClient` as singleton in DI system
- Configures HTTP backend (uses native browser `fetch` or `XMLHttpRequest`)
- Sets up interceptor chain for middleware functionality
- Makes `HttpClient` available for injection throughout app

**Interceptor Execution Order:**
```
Request Flow (outgoing):
Component → retryInterceptor → errorInterceptor → HTTP Backend → Server

Response Flow (incoming):
Server → HTTP Backend → errorInterceptor → retryInterceptor → Component
```

**Why this specific order?**
- **Retry outer**: Catches errors from error interceptor and retries entire request
- **Error inner**: Logs/transforms errors before retry logic decides what to do

#### **Creating a Base API Service**

Our WSU project uses a centralized `ApiService` that wraps `HttpClient` and provides consistent handling of HTTP requests:

```ts
// src/app/services/api.service.ts
export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
  timestamp: Date;
}

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private baseUrl = environment.apiUrl;

  constructor(private http: HttpClient) {}

  /**
   * GET request - handles Spring Boot ResponseEntity responses
   */
  get<T>(endpoint: string, params?: any): Observable<ApiResponse<T>> {
    let httpParams = new HttpParams();
    if (params) {
      Object.keys(params).forEach(key => {
        if (params[key] !== null && params[key] !== undefined) {
          httpParams = httpParams.set(key, params[key].toString());
        }
      });
    }

    return this.http.get<T>(`${this.baseUrl}/${endpoint}`, { params: httpParams }).pipe(
      map(data => ({
        success: true,
        data: data,
        timestamp: new Date()
      }))
    );
  }

  /**
   * POST request - handles Spring Boot ResponseEntity responses
   */
  post<T>(endpoint: string, data: any): Observable<ApiResponse<T>> {
    return this.http.post<T>(`${this.baseUrl}/${endpoint}`, data).pipe(
      map(response => ({
        success: true,
        data: response,
        timestamp: new Date()
      }))
    );
  }

  /**
   * PUT request - handles Spring Boot ResponseEntity responses
   */
  put<T>(endpoint: string, data: any): Observable<ApiResponse<T>> {
    return this.http.put<T>(`${this.baseUrl}/${endpoint}`, data).pipe(
      map(response => ({
        success: true,
        data: response,
        timestamp: new Date()
      }))
    );
  }

  /**
   * DELETE request - handles Spring Boot ResponseEntity responses
   */
  delete<T>(endpoint: string): Observable<ApiResponse<T>> {
    return this.http.delete<T>(`${this.baseUrl}/${endpoint}`).pipe(
      map(() => ({
        success: true,
        data: null as T,
        timestamp: new Date()
      }))
    );
  }
}
```

**Key Patterns in API Service:**

**Generic Interface (`ApiResponse<T>`):**
- Type parameter `<T>` is replaced with actual types when used
- Ensures type safety across all API responses
- Provides consistent response structure
- Example: `ApiResponse<WorkOrder>` has `data: WorkOrder`

**Service Configuration:**
- `@Injectable({ providedIn: 'root' })` - Singleton service at app level
- `private baseUrl = environment.apiUrl` - Centralized base URL configuration
- Constructor injection: `constructor(private http: HttpClient) {}`

**HttpParams Construction:**
- `HttpParams` class is immutable - each `.set()` returns new instance
- Automatically encodes special characters for URL safety
- Filters out `null` and `undefined` values (clean URLs)
- Converts all values to strings with `.toString()`

**RxJS pipe and map operator:**
- `.pipe()` - Chains RxJS operators for data transformation
- `map()` - Transforms each emitted value (like `Array.map()` but for Observables)
- Wraps raw server response in consistent `ApiResponse` structure

**Why wrap responses?**
1. **Consistency**: All responses have same structure
2. **Metadata**: Add success flag and timestamp
3. **Error handling**: Interceptors can distinguish success from error
4. **Future-proofing**: Can add pagination, warnings, etc. later

#### **What is an Observable? Subscribing to API Responses**

When you make a request with `HttpClient`, it does not return the data directly. Instead, it returns an **RxJS Observable**. An Observable is a powerful construct for managing asynchronous operations. It represents a stream of data that may arrive over time.

A key characteristic of `HttpClient` Observables is that they are "cold." This means the HTTP request is not actually sent until a piece of code **subscribes** to the Observable.

**Work Order Service Example:**

```ts
// src/app/services/work-order.service.ts
export class WorkOrderService {
  private apiService = inject(ApiService);

  getWorkOrders(): Observable<PaginatedResponse<WorkOrder>> {
    // This returns an Observable - the request isn't sent yet
    return this.apiService.get<BackendWorkOrderDto[]>('work_order');
  }

  getWorkOrderById(workOrderNumber: number): Observable<WorkOrder> {
    // This returns an Observable - the request isn't sent yet
    return this.apiService.get<BackendWorkOrderDto>(`work_order/${workOrderNumber}`).pipe(
      map(response => response.data)
    );
  }

  createWorkOrder(request: WorkOrderCreateRequest): Observable<WorkOrder> {
    const backendRequest: BackendWorkOrderRequestDto = {
      studentId: request.studentId,
      room: {
        buildingId: request.room.buildingId,
        roomNumber: request.room.roomNumber
      },
      categoryId: request.categoryId,
      statusCode: request.statusCode || 'OPN',
      title: request.title,
      description: request.description,
      dateRequested: request.dateRequested
    };

    return this.apiService.post<BackendWorkOrderDto>('work_order', backendRequest).pipe(
      map(response => response.data)
    );
  }
}
```

**Important**: Calling `getWorkOrders()` does not send the request. It only returns the Observable object. The request is sent when `subscribe()` is called (or when converted to a signal with `toSignal`).

#### **Using Services in Components: The Observable to Signal Pattern**

There are two main patterns for consuming Observables in components:

**Pattern 1: Manual Subscription with takeUntilDestroyed**

```ts
// src/app/features/dashboard/dashboard.component.ts
export class DashboardComponent implements OnInit {
  workOrders = signal<WorkOrder[]>([]);
  isLoading = signal<boolean>(true);
  
  private readonly workOrderService = inject(WorkOrderService);

  ngOnInit(): void {
    this.loadDashboardData();
  }

  private loadDashboardData(): void {
    this.isLoading.set(true);
    
    // Subscribe to the Observable
    this.workOrderService.getWorkOrders()
      .pipe(takeUntilDestroyed(this.destroyRef)) // Automatically unsubscribe on destroy
      .subscribe({
        next: (response) => {
          this.workOrders.set(response.data);
          this.isLoading.set(false);
        },
        error: (error) => {
          console.error('Error loading dashboard data:', error);
          this.isLoading.set(false);
        }
      });
  }
}
```

**Key Points:**
- Manual control over when request is made
- Can handle loading states explicitly
- `takeUntilDestroyed()` prevents memory leaks
- Good for requests triggered by user actions

**Pattern 2: Converting Observables to Signals with toSignal**

```ts
import { Component, inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { WorkOrderService } from '@app/services/work-order.service';

@Component({
  selector: 'app-work-order-list',
  standalone: true,
  imports: [/* ... */],
  templateUrl: './work-order-list.component.html'
})
export class WorkOrderListComponent {
  private readonly workOrderService = inject(WorkOrderService);

  // Convert the Observable from the service into a signal.
  // The request is made when the component is initialized.
  public workOrders = toSignal(
    this.workOrderService.getWorkOrders(),
    { initialValue: [] } // Provide an initial value while waiting for the response
  );
}
```

**Key Points:**
- Cleaner syntax for one-time data loading
- Automatically handles subscription and unsubscription
- `initialValue` required because signals must always have a value
- Signal updates automatically when Observable emits

#### **Handling Multiple Observable Responses**

When you need to combine data from multiple endpoints, make separate subscriptions:

```ts
// src/app/features/work-orders/components/work-order-list/work-order-list.component.ts
export class WorkOrderListComponent implements OnInit {
  private readonly workOrderService = inject(WorkOrderService);
  private readonly lookupService = inject(LookupService);

  workOrders = signal<WorkOrder[]>([]);
  categoryOptions = signal<{ value: string; label: string }[]>([]);

  ngOnInit(): void {
    this.loadWorkOrders();
    this.loadCategories();
  }

  private loadWorkOrders(): void {
    this.workOrderService.getWorkOrders().pipe(
      takeUntilDestroyed(this.destroyRef)
    ).subscribe({
      next: (response: any) => {
        this.workOrders.set(response.data);
        this.applyFilters();
      },
      error: (error) => {
        console.error('Failed to load work orders:', error);
      }
    });
  }

  private loadCategories(): void {
    this.lookupService.getWorkOrderCategories().pipe(
      takeUntilDestroyed(this.destroyRef)
    ).subscribe({
      next: (categories) => {
        const categoryOptions = [
          { value: 'all', label: 'All Categories' },
          ...categories.map(category => ({
            value: category.id.toString(),
            label: category.description
          }))
        ];
        this.categoryOptions.set(categoryOptions);
      },
      error: (error) => {
        console.error('Error loading categories:', error);
      }
    });
  }
}
```

#### **Error Handling Basics**

Network requests can fail. `HttpClient` captures these errors in an `HttpErrorResponse` and sends them through the Observable's error channel:

```ts
this.workOrderService.getWorkOrders().pipe(
  takeUntilDestroyed(this.destroyRef)
).subscribe({
  next: (response) => {
    this.workOrders.set(response.data);
  },
  error: (error) => {
    console.error('Failed to load work orders:', error);
    // Handle the error - show message to user, log, etc.
  }
});
```

More advanced error handling can be accomplished using RxJS operators and interceptors.

#### **HTTP Interceptors: Retry Logic and Error Handling**

Angular interceptors are middleware functions that can transform or handle requests and responses globally. Our WSU application uses two key interceptors:

**1. Retry Interceptor** - Automatically retries failed requests with exponential backoff:

```ts
// src/app/shared/interceptors/retry.interceptor.ts
export function retryInterceptor(request: HttpRequest<unknown>, next: HttpHandlerFn): Observable<any> {
  const defaultConfig: RetryConfig = {
    maxRetries: 3,
    retryDelay: 1000,
    backoffMultiplier: 2,
    retryableStatusCodes: [408, 429, 500, 502, 503, 504]
  };

  return next(request).pipe(
    retryWhen(errors => 
      errors.pipe(
        mergeMap((error: HttpErrorResponse, index: number) => {
          const config = defaultConfig;
          
          // Don't retry if we've exceeded max retries
          if (index >= config.maxRetries) {
            return throwError(() => error);
          }

          // Don't retry if the error status code is not retryable
          if (!config.retryableStatusCodes.includes(error.status)) {
            return throwError(() => error);
          }

          // Calculate delay with exponential backoff
          const delayTime = config.retryDelay * Math.pow(config.backoffMultiplier, index);
          
          console.log(`Retrying request (attempt ${index + 1}/${config.maxRetries + 1}) after ${delayTime}ms`);
          
          return timer(delayTime);
        }),
        take(defaultConfig.maxRetries + 1)
      )
    )
  );
}
```

**Retry Configuration Explained:**

**`maxRetries: 3`:**
- Maximum retry attempts (total attempts = 1 original + 3 retries = 4)
- Balance between persistence and not hammering a failing server

**`retryDelay: 1000`:**
- Initial delay before first retry (1000ms = 1 second)
- Base value for exponential backoff calculation

**`backoffMultiplier: 2`:**
- Each retry waits longer than previous one
- Pattern: delay × multiplier^attempt
- Exponential backoff:
  - Attempt 0 (1st retry): 1000 × 2^0 = 1000ms (1 second)
  - Attempt 1 (2nd retry): 1000 × 2^1 = 2000ms (2 seconds)
  - Attempt 2 (3rd retry): 1000 × 2^2 = 4000ms (4 seconds)
  - Total wait time: 1 + 2 + 4 = 7 seconds

**`retryableStatusCodes`:**
- **408 Request Timeout** - Retryable (might succeed on retry)
- **429 Too Many Requests** - Retryable (with backoff, should succeed later)
- **500 Internal Server Error** - Retryable (might be temporary)
- **502 Bad Gateway** - Retryable (upstream server might recover)
- **503 Service Unavailable** - Retryable (server might restart)
- **504 Gateway Timeout** - Retryable (upstream might respond)

**NOT retryable (intentionally excluded):**
- 400 Bad Request - Client error, won't succeed
- 401 Unauthorized - Need authentication
- 403 Forbidden - Permission denied
- 404 Not Found - Resource doesn't exist
- 422 Unprocessable Entity - Validation error

**Why exponential backoff?**
1. **Server recovery**: Gives server time to recover from overload
2. **Network congestion**: Reduces load during network issues
3. **Courtesy**: Don't hammer a struggling server
4. **Industry standard**: Used by AWS, Google Cloud, etc.

**2. Error Interceptor** - Centralized error handling and logging:

```ts
// src/app/shared/interceptors/error.interceptor.ts
export function errorInterceptor(request: HttpRequest<unknown>, next: HttpHandlerFn): Observable<any> {
  return next(request).pipe(
    catchError((error: HttpErrorResponse) => {
      let errorMessage = 'An error occurred';

      if (error.error instanceof ErrorEvent) {
        // Client-side error
        errorMessage = `Error: ${error.error.message}`;
      } else {
        // Server-side error
        errorMessage = `Error Code: ${error.status}\nMessage: ${error.message}`;
      }

      console.error('HTTP Error:', errorMessage);
      return throwError(() => error);
    })
  );
}
```

**Error Handling Logic:**
- Distinguishes between client-side and server-side errors
- Logs errors consistently across application
- Propagates error to subscriber for component-specific handling

#### **Environment Configuration**

The application uses environment configuration to manage different API endpoints:

```ts
// src/environments/environment.ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/mr-fixit-service'
};
```

**Benefits:**
- Different URLs for dev/staging/production
- Don't hardcode production URLs in code
- Can be replaced during build process
- Easy switching between environments

#### **Complete Example: Work Order Service**

Production-ready service demonstrating all concepts:

```ts
// src/app/services/work-order.service.ts
@Injectable({
  providedIn: 'root'
})
export class WorkOrderService {
  constructor(private apiService: ApiService) {}

  /**
   * Get all work orders
   * Endpoint: GET /work_order
   */
  getWorkOrders(pagination?: PaginationParams): Observable<PaginatedResponse<WorkOrder>> {
    return this.apiService.get<BackendWorkOrderDto[]>('work_order').pipe(
      map(response => {
        const workOrders = response.data;

        // Apply client-side pagination if needed
        const page = pagination?.page || 1;
        const limit = pagination?.limit || 1000;
        const total = workOrders.length;
        const totalPages = Math.ceil(total / limit);
        const startIndex = (page - 1) * limit;
        const endIndex = startIndex + limit;
        const paginatedData = workOrders.slice(startIndex, endIndex);

        return {
          success: true,
          data: paginatedData,
          pagination: {
            page,
            limit,
            total,
            totalPages,
            hasNext: page < totalPages,
            hasPrevious: page > 1
          },
          timestamp: new Date()
        };
      }),
      catchError(error => {
        console.error('Failed to fetch work orders:', error);
        throw error;
      })
    );
  }

  /**
   * Get work order by ID
   * Endpoint: GET /work_order/{id}
   */
  getWorkOrderById(workOrderNumber: number): Observable<WorkOrder> {
    return this.apiService.get<BackendWorkOrderDto>(`work_order/${workOrderNumber}`).pipe(
      map(response => response.data),
      catchError(error => {
        console.error(`Failed to fetch work order ${workOrderNumber}:`, error);
        throw error;
      })
    );
  }

  /**
   * Create new work order
   * Endpoint: POST /work_order
   */
  createWorkOrder(request: WorkOrderCreateRequest): Observable<WorkOrder> {
    const backendRequest: BackendWorkOrderRequestDto = {
      studentId: request.studentId,
      room: {
        buildingId: request.room.buildingId,
        roomNumber: request.room.roomNumber
      },
      categoryId: request.categoryId,
      statusCode: request.statusCode || 'OPN',
      title: request.title,
      description: request.description,
      dateRequested: request.dateRequested,
      maintenanceTechnicianCode: request.maintenanceTechnicianCode || null,
      appointmentScheduled: request.appointmentScheduled || null,
      completionNotes: request.completionNotes || null
    };

    return this.apiService.post<BackendWorkOrderDto>('work_order', backendRequest).pipe(
      map(response => response.data),
      catchError(error => {
        console.error('Failed to create work order:', error);
        throw error;
      })
    );
  }
}
```

#### **Using the Service in a Component**

Example of consuming the service in a form component:

```ts
// src/app/features/work-orders/components/work-order-form/work-order-form.component.ts
export class WorkOrderFormComponent implements OnInit {
  private readonly workOrderService = inject(WorkOrderService);
  
  isSubmitting = signal<boolean>(false);
  errorMessage = signal<string>('');
  successMessage = signal<string>('');

  onSubmit(): void {
    if (!this.workOrderForm.valid) {
      this.markFormGroupTouched(this.workOrderForm);
      return;
    }

    this.isSubmitting.set(true);
    this.errorMessage.set('');
    this.successMessage.set('');

    const formValue = this.workOrderForm.value;
    this.createWorkOrder(formValue);
  }

  private createWorkOrder(formValue: any): void {
    const request: WorkOrderCreateRequest = {
      title: formValue.title,
      description: formValue.description,
      categoryId: formValue.categoryId,
      room: {
        buildingId: formValue.buildingId,
        roomNumber: formValue.roomNumber
      },
      studentId: formValue.studentId,
      statusCode: 'OPN',
      dateRequested: formValue.dateRequested,
      maintenanceTechnicianCode: null,
      appointmentScheduled: null,
      completionNotes: null
    };

    this.workOrderService.createWorkOrder(request).pipe(
      takeUntilDestroyed(this.destroyRef)
    ).subscribe({
      next: (workOrder: any) => {
        this.successMessage.set('Work order created successfully!');
        this.isSubmitting.set(false);
        setTimeout(() => {
          this.router.navigate(['/work-orders', workOrder.orderNumber]);
        }, 1500);
      },
      error: (error) => {
        console.error('Failed to create work order:', error);
        this.errorMessage.set('Failed to create work order. Please try again.');
        this.isSubmitting.set(false);
      }
    });
  }
}
```

#### **Practical Exercise: Building a Data-Fetching Dashboard**

Complete dashboard component that fetches and displays work order statistics:

```ts
// src/app/features/dashboard/dashboard.component.ts
@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, LoadingSpinnerComponent],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class DashboardComponent implements OnInit {
  workOrders = signal<WorkOrder[]>([]);
  isLoading = signal<boolean>(true);
  
  private readonly workOrderService = inject(WorkOrderService);

  ngOnInit(): void {
    this.loadDashboardData();
  }

  private loadDashboardData(): void {
    this.isLoading.set(true);
    
    this.workOrderService.getWorkOrders()
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: (response) => {
          this.workOrders.set(response.data);
          this.isLoading.set(false);
        },
        error: (error) => {
          console.error('Error loading dashboard data:', error);
          this.isLoading.set(false);
        }
      });
  }

  // Computed statistics from work orders
  totalOrders = computed(() => this.workOrders().length);
  openOrders = computed(() => 
    this.workOrders().filter(wo => wo.status.code === 'OPN').length
  );
  inProgressOrders = computed(() => 
    this.workOrders().filter(wo => wo.status.code === 'NPRGRS').length
  );
  completedOrders = computed(() => 
    this.workOrders().filter(wo => wo.status.code === 'CMPLTD').length
  );
  completionRate = computed(() => {
    const total = this.totalOrders();
    if (total === 0) return 0;
    return Math.round((this.completedOrders() / total) * 100);
  });
}
```

**Template:**

```html
<!-- src/app/features/dashboard/dashboard.component.html -->
<div class="dashboard">
  <!-- Loading State -->
  @if (isLoading()) {
    <div class="loading-container">
      <app-loading-spinner size="lg" message="Loading dashboard data..."></app-loading-spinner>
    </div>
  }

  <!-- Dashboard Content -->
  @if (!isLoading() && workOrders().length > 0) {
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-card__value">{{ totalOrders() }}</div>
        <div class="stat-card__label">Total Work Orders</div>
      </div>

      <div class="stat-card">
        <div class="stat-card__value">{{ openOrders() }}</div>
        <div class="stat-card__label">Open Orders</div>
      </div>

      <div class="stat-card">
        <div class="stat-card__value">{{ completionRate() }}%</div>
        <div class="stat-card__label">Completion Rate</div>
      </div>
    </div>
  }
</div>
```

### **Summary**

This comprehensive class demonstrates:

1. **HttpClient Configuration**: Setting up `provideHttpClient()` with interceptors
2. **Service Pattern**: Encapsulating HTTP logic in services with generic types
3. **Observable to Signal**: Converting async data to reactive signals
4. **Error Handling**: Using interceptors and error callbacks for resilient communication
5. **Loading States**: Managing loading indicators during async requests
6. **Computed Properties**: Deriving statistics from loaded data
7. **RxJS Operators**: Using `map`, `catchError`, `takeUntilDestroyed`, `retryWhen`
8. **Retry Logic**: Implementing exponential backoff for failed requests
9. **Environment Configuration**: Managing different API endpoints
10. **Real-world Patterns**: Production-ready code from an actual application

This provides a complete foundation for making HTTP requests in modern Angular applications.
