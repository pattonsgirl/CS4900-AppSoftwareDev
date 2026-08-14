# **🌐 Class 3 — HTTP Requests & Async Programming**

## **Goal**

Understand how to communicate with backend APIs asynchronously using Angular's HttpClient and integrate the resulting data streams (Observables) into the component's reactive state (Signals) using examples from the WSU Work Order Management system.

## **Topics**

### **What is an HTTP Request?**

An HTTP (Hypertext Transfer Protocol) request is the mechanism by which a client (like an Angular application running in a browser) communicates with a server to request or send data. The most common types of requests, or "verbs," for a full-stack application are:

* **GET:** Retrieve data from the server.  
* **POST:** Send new data to the server to create a resource.  
* **PUT / PATCH:** Send data to update an existing resource.  
* **DELETE:** Request that the server delete a resource.

In our WSU Work Order Management system, we use these HTTP methods to interact with our backend API:

- **GET /work_order** - Retrieve all work orders
- **GET /work_order/{id}** - Get a specific work order by ID
- **POST /work_order** - Create a new work order
- **GET /work_order/category** - Get all work order categories
- **GET /work_order/status** - Get all work order statuses

#### **The HttpClient Service**

Angular provides a dedicated service, `HttpClient`, for making HTTP requests. It is a simplified client HTTP API that rests on the `XMLHttpRequest` interface exposed by browsers. Its major features include the ability to request typed response values, streamlined error handling, and request/response interception.

To use `HttpClient`, it must be made available to the application's dependency injection system. In a modern standalone application, this is done by calling `provideHttpClient()` within the providers array in `app.config.ts`.

Looking at our WSU application's configuration:

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

### 🔍 **Detailed Code Breakdown: HttpClient Configuration**

Let's examine how HTTP client is configured at the application level:

**`provideHttpClient()` Function:**

```ts
provideHttpClient(
  withInterceptors([retryInterceptor, errorInterceptor])
)
```

**Breaking this down:**
- `provideHttpClient()` - Function that registers HttpClient in DI system
- `withInterceptors([...])` - Configuration function that adds middleware
- `[retryInterceptor, errorInterceptor]` - Array of interceptor functions

**What happens when you call provideHttpClient()?**
1. Registers `HttpClient` service as singleton
2. Configures HTTP backend (uses native browser `fetch` or `XMLHttpRequest`)
3. Sets up interceptor chain
4. Makes `HttpClient` available for injection throughout app

**Interceptor Execution Order:**

```
Request Flow (outgoing):
Component → retryInterceptor → errorInterceptor → HTTP Backend → Server

Response Flow (incoming):
Server → HTTP Backend → errorInterceptor → retryInterceptor → Component
```

**Why order matters:**
```ts
withInterceptors([retryInterceptor, errorInterceptor])
//                 ^^^^^^^^^^^^^^^  ^^^^^^^^^^^^^^^
//                 Runs first       Runs second (outgoing)
//                 Runs second      Runs first (incoming)
```

**Request journey:**
1. Component calls `this.http.get('/api/data')`
2. Request passes through `retryInterceptor` (outer layer)
3. Request passes through `errorInterceptor` (inner layer)
4. Request sent to server
5. Response comes back through `errorInterceptor` first
6. Response passes through `retryInterceptor` second
7. Component receives response

**Why this specific order?**
- **Retry outer**: Catches errors from error interceptor and retries entire request
- **Error inner**: Logs/transforms errors before retry logic decides what to do
- If reversed, retry wouldn't catch errors properly transformed by error interceptor

**Alternative configuration without interceptors:**
```ts
// Minimal setup:
provideHttpClient()  // Just HttpClient, no middleware

// With specific features:
provideHttpClient(
  withJsonpSupport(),              // Enable JSONP requests
  withInterceptorsFromDi(),        // Use class-based interceptors
  withXsrfConfiguration({...})     // Configure CSRF protection
)
```

Notice that we're not just providing `HttpClient`, but also configuring it with **interceptors**. These are middleware functions that can transform or handle requests and responses. We'll discuss these in more detail later.

### **Creating a Base API Service**

Our WSU project uses a centralized `ApiService` that wraps `HttpClient` and provides consistent handling of HTTP requests:

```ts
// src/app/services/api.service.ts
import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { environment } from '../../environments/environment';

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

### 🔍 **Detailed Code Breakdown: API Service**

This service is a brilliant example of the **wrapper pattern** and **generic programming**. Let's dissect it:

**Generic Interface Definition:**

```ts
export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
  timestamp: Date;
}
```

**Understanding generics:**
- `<T>` is a **type parameter** (like a function parameter, but for types)
- `T` is a placeholder that gets replaced with actual types when used
- `data: T` means "data property has whatever type T is"

**Usage examples:**
```ts
// When you use ApiResponse<WorkOrder>:
{
  success: boolean;    // Always boolean
  data: WorkOrder;     // T replaced with WorkOrder
  message?: string;    // Always optional string
  timestamp: Date;     // Always Date
}

// When you use ApiResponse<WorkOrder[]>:
{
  success: boolean;
  data: WorkOrder[];   // T replaced with WorkOrder[]
  message?: string;
  timestamp: Date;
}
```

**Why this pattern?**
- **Type safety**: Compiler knows exact structure of response
- **Reusability**: One interface serves all response types
- **Consistency**: All API responses have same shape
- **Documentation**: Clear what data to expect

**Service Decorator and Configuration:**

```ts
@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private baseUrl = environment.apiUrl;
  
  constructor(private http: HttpClient) {}
```

**`@Injectable({ providedIn: 'root' })`:**
- Marks class as injectable (can be injected into other classes)
- `providedIn: 'root'` registers as **singleton** at app level
- **Singleton**: Only ONE instance exists for entire app
- All components share the same ApiService instance

**Why singleton?**
- **Consistency**: All API calls use same configuration
- **Memory efficient**: Don't create multiple instances
- **State sharing**: Can cache data if needed
- **Performance**: No overhead of creating/destroying instances

**`private baseUrl = environment.apiUrl;`:**
```ts
// environment.ts might have:
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/mr-fixit-service'
};

// So baseUrl becomes: 'http://localhost:8080/mr-fixit-service'
```

**Why use environment file?**
- **Flexibility**: Different URLs for dev/staging/production
- **Security**: Don't hardcode production URLs in code
- **Build-time**: Can be replaced during build process
- **Easy switching**: Change one file, not scattered code

**Constructor Dependency Injection:**

```ts
constructor(private http: HttpClient) {}
//          ^^^^^^^ ^^^^^^^^^^^^^^^^^^^
//          Access   Type + Parameter name
```

**TypeScript shorthand magic:**
```ts
// This single line does THREE things:

// 1. Declares private property:
private http: HttpClient;

// 2. Creates constructor parameter:
constructor(http: HttpClient) {}

// 3. Assigns parameter to property:
this.http = http;

// All in one line!
```

**GET Request Method Deep Dive:**

```ts
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
```

**Method signature breakdown:**

```ts
get<T>(endpoint: string, params?: any): Observable<ApiResponse<T>>
//  ^^^ ^^^^^^^^^^^^^^^  ^^^^^^^^^^^^   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//  Generic  Parameters    Optional     Return type
```

**Generic method parameter:**
- `<T>` makes this method generic
- When calling, specify what T is: `get<WorkOrder>(...)`
- Return type automatically adapts: `Observable<ApiResponse<WorkOrder>>`

**HttpParams construction:**

```ts
let httpParams = new HttpParams();
```

**Why HttpParams class?**
- **Immutable**: Each `.set()` returns new instance
- **URL encoding**: Automatically encodes special characters
- **Type safety**: Prevents malformed query strings
- **Browser compatible**: Works across all browsers

**Parameter building loop:**

```ts
if (params) {
  Object.keys(params).forEach(key => {
    if (params[key] !== null && params[key] !== undefined) {
      httpParams = httpParams.set(key, params[key].toString());
    }
  });
}
```

**Step-by-step execution:**
```ts
// Input: params = { status: 'OPN', page: 1, deleted: null }

Object.keys(params)  
// Returns: ['status', 'page', 'deleted']

.forEach(key => {
  // Iteration 1: key = 'status'
  if ('OPN' !== null && 'OPN' !== undefined) {  // true
    httpParams = httpParams.set('status', 'OPN');
  }
  
  // Iteration 2: key = 'page'
  if (1 !== null && 1 !== undefined) {  // true
    httpParams = httpParams.set('page', '1');  // toString() converts to '1'
  }
  
  // Iteration 3: key = 'deleted'
  if (null !== null && null !== undefined) {  // false - skipped!
    // This doesn't run
  }
});

// Result: URL will be /endpoint?status=OPN&page=1
// Notice: deleted parameter is excluded (null/undefined stripped out)
```

**Why check for null/undefined?**
- **Clean URLs**: Don't send `?deleted=null` to server
- **Server expectations**: Many APIs don't handle null in query params well
- **Clarity**: URL only shows meaningful parameters

**Why `.toString()`?**
- HttpParams.set() expects strings
- Converts: `1` → `'1'`, `true` → `'true'`, `false` → `'false'`
- **Safe**: Won't crash if value is already string

**HTTP GET call:**

```ts
return this.http.get<T>(`${this.baseUrl}/${endpoint}`, { params: httpParams })
```

**URL template literal:**
```ts
`${this.baseUrl}/${endpoint}`
// If baseUrl = 'http://localhost:8080/mr-fixit-service'
// And endpoint = 'work_order'
// Result: 'http://localhost:8080/mr-fixit-service/work_order'
```

**Options object:**
```ts
{ params: httpParams }
// Passes query parameters to request
// HttpClient converts to: ?status=OPN&page=1
```

**RxJS pipe and map operator:**

```ts
.pipe(
  map(data => ({
    success: true,
    data: data,
    timestamp: new Date()
  }))
)
```

**What `.pipe()` does:**
- Takes Observable from `http.get()`
- Passes it through operators (transformations)
- Returns new Observable with transformed data

**What `map()` operator does:**
- Transforms each emitted value
- Like `Array.map()`, but for Observables
- Receives raw server response
- Returns wrapped response

**Transformation flow:**
```ts
// Server returns:
{
  orderNumber: 123,
  title: "Broken sink",
  status: { code: "OPN", ... }
}

// map() transforms to:
{
  success: true,
  data: {
    orderNumber: 123,
    title: "Broken sink",
    status: { code: "OPN", ... }
  },
  timestamp: Date(2025-10-28T14:30:00.000Z)
}
```

**Why wrap the response?**
1. **Consistency**: All responses have same structure
2. **Metadata**: Add success flag and timestamp
3. **Error handling**: Interceptors can distinguish success from error
4. **Future-proofing**: Can add pagination, warnings, etc. later

**POST Request Comparison:**

```ts
post<T>(endpoint: string, data: any): Observable<ApiResponse<T>> {
  return this.http.post<T>(`${this.baseUrl}/${endpoint}`, data).pipe(
    map(response => ({
      success: true,
      data: response,
      timestamp: new Date()
    }))
  );
}
```

**Key differences from GET:**
- **Second parameter**: `data` (request body) instead of params (query string)
- **No HttpParams**: Body sent as JSON, not query string
- **Same wrapping**: Still wraps response consistently

**HTTP method comparison:**

```ts
// GET: Query string parameters
this.http.get<T>(url, { params: httpParams })
// URL: /api/work_order?status=OPN&page=1

// POST: Request body
this.http.post<T>(url, data)
// URL: /api/work_order
// Body: { "title": "...", "description": "..." }

// PUT: Request body (usually update entire resource)
this.http.put<T>(url, data)

// DELETE: No body typically
this.http.delete<T>(url)
```

**DELETE special case:**

```ts
delete<T>(endpoint: string): Observable<ApiResponse<T>> {
  return this.http.delete<T>(`${this.baseUrl}/${endpoint}`).pipe(
    map(() => ({
      success: true,
      data: null as T,  // Type assertion: treating null as type T
      timestamp: new Date()
    }))
  );
}
```

**Why `null as T`?**
- DELETE usually doesn't return data (just success/failure)
- But our `ApiResponse<T>` interface requires `data: T`
- `null as T` tells TypeScript: "Trust me, null is valid here"
- **Type assertion**: Overrides TypeScript's type checking

**Alternative approaches:**
```ts
// Could make data optional:
export interface ApiResponse<T> {
  success: boolean;
  data?: T;  // Optional
  timestamp: Date;
}

// Or use union type:
data: T | null

// Our approach is simpler but requires type assertion
```

**Real-world usage examples:**

```ts
// In a component:
class WorkOrderListComponent {
  private apiService = inject(ApiService);
  
  loadWorkOrders() {
    // TypeScript knows this returns Observable<ApiResponse<WorkOrder[]>>
    this.apiService.get<WorkOrder[]>('work_order', { 
      status: 'OPN',
      page: 1,
      limit: 10
    }).subscribe(response => {
      // response.data is typed as WorkOrder[]
      console.log(response.data);  // ✓ Type-safe!
      console.log(response.timestamp);  // ✓ Type-safe!
    });
  }
  
  createWorkOrder(workOrder: WorkOrder) {
    // TypeScript knows this returns Observable<ApiResponse<WorkOrder>>
    this.apiService.post<WorkOrder>('work_order', workOrder)
      .subscribe(response => {
        // response.data is typed as WorkOrder (singular)
        console.log(response.data.orderNumber);  // ✓ Type-safe!
      });
  }
}
```

**Why this service pattern is brilliant:**
1. **DRY**: Don't repeat URL construction in every service
2. **Type-safe**: Generics ensure correct types everywhere
3. **Consistent**: All API responses have same shape
4. **Maintainable**: Change base URL in one place
5. **Testable**: Easy to mock for unit tests
6. **Scalable**: Add authentication headers, logging, etc. in one place

### **What is an Observable? Subscribing to API Responses**

When you make a request with `HttpClient`, it does not return the data directly. Instead, it returns an **RxJS Observable**. An Observable is a powerful construct for managing asynchronous operations. It represents a stream of data that may arrive over time.

A key characteristic of `HttpClient` Observables is that they are "cold." This means the HTTP request is not actually sent until a piece of code **subscribes** to the Observable.

```ts
// In a data service
import { inject } from '@angular/core';
import { ApiService } from './api.service';
import { Observable } from 'rxjs';

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

In this example, calling `getWorkOrders()` does not send the request. It only returns the Observable object. The request is sent when `subscribe()` is called on that object (or when we convert it to a signal with `toSignal`).

### **Using Services in Components: The Observable to Signal Pattern**

Looking at how we use these services in components, we can see two patterns:

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

**Pattern 2: Converting Observables to Signals with toSignal**

While the `takeUntilDestroyed` pattern is solid, Angular provides `toSignal` from `@angular/core/rxjs-interop` as a cleaner approach for one-time data loading:

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

The `toSignal` function subscribes to an Observable and converts its emissions into a signal. It automatically handles the subscription and, crucially, unsubscribes when the component is destroyed, preventing memory leaks. This is the recommended pattern for consuming HTTP data in modern components.

The `initialValue` option is required because a signal must always have a value, but the HTTP response will not be available synchronously. The signal will hold this initial value until the Observable emits, at which point the signal's value will be updated to the data from the server.

### **Handling Multiple Observable Responses**

When you need to combine data from multiple endpoints, RxJS operators like `combineLatest` or `forkJoin` are invaluable:

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

### **Error Handling Basics**

Network requests can fail. `HttpClient` captures these errors in an `HttpErrorResponse` and sends them through the Observable's error channel. When using manual subscriptions, you handle errors in the error callback:

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

More advanced error handling, such as retrying failed requests, can be accomplished using RxJS operators. Our WSU application implements this with interceptors (as we'll see below).

### **HTTP Interceptors: Retry Logic and Error Handling**

Angular interceptors are middleware functions that can transform or handle requests and responses globally. Our WSU application uses two key interceptors:

**1. Retry Interceptor** - Automatically retries failed requests:

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

### 🔍 **Detailed Code Breakdown: Retry Interceptor**
This interceptor is a masterclass in resilient HTTP communication. Let's dissect every piece:

**Interceptor Function Signature:**

```ts
export function retryInterceptor(
  request: HttpRequest<unknown>, 
  next: HttpHandlerFn
): Observable<any>
```

**Parameters explained:**
- `request: HttpRequest<unknown>` - The HTTP request being made
  - `<unknown>` means body type is not specified (could be anything)
  - Immutable object containing URL, headers, body, etc.
- `next: HttpHandlerFn` - Function to call next interceptor or HTTP backend
  - Like Express.js middleware's `next()`
  - Returns Observable of HTTP response

**Return type:**
- `Observable<any>` - Stream that eventually emits response or error
- `any` because we don't know response type (works with all requests)

**Retry Configuration Object:**

```ts
const defaultConfig: RetryConfig = {
  maxRetries: 3,
  retryDelay: 1000,
  backoffMultiplier: 2,
  retryableStatusCodes: [408, 429, 500, 502, 503, 504]
};
```

**Each property explained:**

**`maxRetries: 3`:**
- Maximum number of retry attempts
- Total attempts = 1 original + 3 retries = 4 attempts
- **Why 3?** Balance between persistence and not hammering a failing server

**`retryDelay: 1000`:**
- Initial delay before first retry (in milliseconds)
- 1000ms = 1 second
- Base value for exponential backoff calculation

**`backoffMultiplier: 2`:**
- Multiplier for exponential backoff
- Each retry waits longer than the previous one
- **Pattern**: delay × multiplier^attempt

**Exponential backoff calculation:**
```ts
// Attempt 0 (1st retry): 1000 * 2^0 = 1000 * 1 = 1000ms (1 second)
// Attempt 1 (2nd retry): 1000 * 2^1 = 1000 * 2 = 2000ms (2 seconds)
// Attempt 2 (3rd retry): 1000 * 2^2 = 1000 * 4 = 4000ms (4 seconds)
// Total wait time: 1 + 2 + 4 = 7 seconds
```

**Why exponential backoff?**
1. **Server recovery**: Gives server time to recover from overload
2. **Network congestion**: Reduces load during network issues
3. **Courtesy**: Don't hammer a struggling server
4. **Industry standard**: Used by AWS, Google Cloud, etc.

**`retryableStatusCodes: [408, 429, 500, 502, 503, 504]`:**

Let's break down each status code:

- **408 Request Timeout**: Client didn't send request fast enough
  - **Retryable?** Yes - might succeed on retry
  
- **429 Too Many Requests**: Rate limit exceeded
  - **Retryable?** Yes - with backoff, should succeed later
  
- **500 Internal Server Error**: Server encountered unexpected condition
  - **Retryable?** Yes - might be temporary server issue
  
- **502 Bad Gateway**: Gateway got invalid response from upstream
  - **Retryable?** Yes - upstream server might recover
  
- **503 Service Unavailable**: Server temporarily unavailable
  - **Retryable?** Yes - server might restart or recover
  
- **504 Gateway Timeout**: Gateway didn't get response in time
  - **Retryable?** Yes - upstream might respond on retry

**NOT retryable (intentionally excluded):**
- **400 Bad Request**: Client error, won't succeed on retry
- **401 Unauthorized**: Need authentication, retry won't help
- **403 Forbidden**: Permission denied, retry won't help
- **404 Not Found**: Resource doesn't exist, won't appear on retry
- **422 Unprocessable Entity**: Validation error, retry won't help

**Core Retry Logic:**

```ts
return next(request).pipe(
  retryWhen(errors => /* ... */)
)
```

**`next(request)`:**
- Calls next interceptor or sends request to server
- Returns `Observable<HttpResponse | HttpError>`
- **This is where the actual HTTP request happens**

**`.pipe()`:**
- Chains RxJS operators
- Transforms the Observable stream

**`retryWhen()` operator:**
- **Advanced** RxJS operator for custom retry logic
- Takes a function that receives Observable of errors
- Returns Observable that controls retry timing
- **How it works:**
  1. If request succeeds → emits response, completes
  2. If request fails → emits error to `retryWhen`
  3. If `retryWhen` emits value → retries request
  4. If `retryWhen` emits error → propagates error to subscriber

**Error Stream Processing:**

```ts
errors.pipe(
  mergeMap((error: HttpErrorResponse, index: number) => {
    // Processing logic
  }),
  take(defaultConfig.maxRetries + 1)
)
```

**`errors` Observable:**
- Stream of HTTP errors that occurred
- Each emission is one failed request
- `HttpErrorResponse` contains status, message, etc.

**`mergeMap()` operator:**
- **Also called**: `flatMap`
- Transforms each error into a new Observable
- **Flattens** inner Observables into outer stream
- **Purpose here**: Decide whether to retry or give up

**`index` parameter:**
- **Auto-provided** by RxJS
- Counts which retry attempt this is
- 0 = first retry, 1 = second retry, etc.

**Guard Clause 1: Max Retries:**

```ts
if (index >= config.maxRetries) {
  return throwError(() => error);
}
```

**Breaking this down:**
```ts
// index starts at 0
// maxRetries is 3

// index = 0: 0 >= 3? No → continue
// index = 1: 1 >= 3? No → continue
// index = 2: 2 >= 3? No → continue
// index = 3: 3 >= 3? Yes → throw error (stop retrying)
```

**`throwError(() => error)`:**
- Creates Observable that immediately emits error
- **Arrow function**: `() => error` - lazy evaluation
- Propagates error to subscriber (gives up retrying)

**Guard Clause 2: Retryable Status:**

```ts
if (!config.retryableStatusCodes.includes(error.status)) {
  return throwError(() => error);
}
```

**What this does:**
```ts
// Example: error.status = 404 (Not Found)
[408, 429, 500, 502, 503, 504].includes(404)  // false
!false  // true
// → throw error (don't retry 404s)

// Example: error.status = 503 (Service Unavailable)
[408, 429, 500, 502, 503, 504].includes(503)  // true
!true  // false
// → continue (retry 503s)
```

**Why check status code?**
- **Efficiency**: Don't waste time retrying permanent failures
- **User experience**: Fail fast for client errors
- **Server courtesy**: Don't retry when problem is client-side

**Exponential Backoff Calculation:**

```ts
const delayTime = config.retryDelay * Math.pow(config.backoffMultiplier, index);
```

**Step-by-step calculation:**

```ts
// Math.pow(base, exponent) = base^exponent

// Retry 1 (index = 0):
delayTime = 1000 * Math.pow(2, 0)
delayTime = 1000 * 1
delayTime = 1000ms

// Retry 2 (index = 1):
delayTime = 1000 * Math.pow(2, 1)
delayTime = 1000 * 2
delayTime = 2000ms

// Retry 3 (index = 2):
delayTime = 1000 * Math.pow(2, 2)
delayTime = 1000 * 4
delayTime = 4000ms
```

**Visual timeline:**
```
Request fails
    ↓
Wait 1 second → Retry 1
    ↓ (fails)
Wait 2 seconds → Retry 2
    ↓ (fails)
Wait 4 seconds → Retry 3
    ↓ (fails)
Give up → Error to component
```

**Debug Logging:**

```ts
console.log(`Retrying request (attempt ${index + 1}/${config.maxRetries + 1}) after ${delayTime}ms`);
```

**Example console output:**
```
Retrying request (attempt 1/4) after 1000ms
Retrying request (attempt 2/4) after 2000ms
Retrying request (attempt 3/4) after 4000ms
```

**Why `index + 1`?**
- `index` is 0-based (0, 1, 2)
- Humans count from 1 (1, 2, 3)
- `index + 1` converts to human-readable

**Why `maxRetries + 1`?**
- 3 retries + 1 original attempt = 4 total attempts

**Timer Operator:**

```ts
return timer(delayTime);
```

**What `timer()` does:**
- RxJS operator that emits after specified delay
- Creates Observable that waits `delayTime` milliseconds
- Then emits single value (0) and completes
- **Effect**: Delays the retry by calculated time

**How it works in context:**
```ts
mergeMap((error, index) => {
  // ... validation ...
  return timer(2000);  // Wait 2 seconds
  // When timer emits → mergeMap completes
  // → retryWhen sees completion → retries request
})
```

**Take Operator:**

```ts
.take(defaultConfig.maxRetries + 1)
```

**What `take()` does:**
- Takes first N emissions from Observable
- Automatically completes after N items
- **Safety net**: Prevents infinite retries

**Why `maxRetries + 1`?**
```ts
// maxRetries = 3
// take(3 + 1) = take(4)

// Emission 1 (index 0) → passes through
// Emission 2 (index 1) → passes through
// Emission 3 (index 2) → passes through
// Emission 4 (index 3) → passes through, then completes
// Any more → blocked (shouldn't happen due to earlier guard)
```

**Complete Execution Flow:**

```
1. Component calls: this.http.get('/api/data')
2. Request enters retry interceptor
3. Request sent to server
4. Server returns 503 (Service Unavailable)
5. Error emitted to retryWhen
6. mergeMap receives: error (status 503), index (0)
7. Check: index (0) >= maxRetries (3)? No → continue
8. Check: status (503) in retryable list? Yes → continue
9. Calculate: delay = 1000 * 2^0 = 1000ms
10. Log: "Retrying request (attempt 1/4) after 1000ms"
11. Return: timer(1000)
12. Wait 1 second
13. Timer emits → retryWhen retries request
14. Request sent again (attempt 2)
15. Server still returns 503
16. Repeat steps 5-14 with index 1 (wait 2 seconds)
17. Repeat again with index 2 (wait 4 seconds)
18. Index becomes 3: 3 >= 3? Yes → throwError
19. Error propagates to component
20. Component's error handler executes
```

**Real-world scenario:**

```ts
// Server is overloaded and returning 503s
// Timeline:
// 0s: Original request → 503
// 1s: Retry 1 → 503
// 3s: Retry 2 → 503  (cumulative: waited 1+2=3s)
// 7s: Retry 3 → 200 Success! (cumulative: waited 1+2+4=7s)
// User gets response after 7s instead of immediate failure
```

**Why this pattern is brilliant:**
1. **Resilient**: Handles temporary failures gracefully
2. **Courteous**: Exponential backoff prevents server overload
3. **Intelligent**: Only retries retryable errors
4. **Bounded**: Max retries prevents infinite loops
5. **Observable**: Logs help debugging
6. **Transparent**: Components don't need retry logic
7. **Configurable**: Easy to adjust retry parameters

**2. Error Interceptor** - Centralized error handling:

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

#### **Environment Configuration**

Our application uses environment configuration to manage different API endpoints for development and production:

```ts
// src/environments/environment.ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/mr-fixit-service'
};
```

This allows us to easily switch between local development and production API endpoints without changing code.

### **Complete Example: Work Order Service**

Let's look at a complete, production-ready service that demonstrates all these concepts:

```ts
// src/app/services/work-order.service.ts
import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';
import { map, catchError } from 'rxjs';
import {
  WorkOrder,
  WorkOrderCreateRequest,
  PaginatedResponse,
  PaginationParams
} from '@shared/models';
import { BackendWorkOrderDto, BackendWorkOrderRequestDto } from '@shared/models';
import { ApiService } from './api.service';

/**
 * Work Order Service - handles work order data operations
 * Adheres strictly to backend API endpoints (mr-fixit-service)
 * 
 * Available backend endpoints:
 * - GET /work_order - get all work orders
 * - POST /work_order - create work order
 * - GET /work_order/{id} - get work order by id
 * - GET /work_order/category - get all categories
 * - GET /work_order/status - get all statuses
 */
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

        // Apply client-side pagination if needed (backend doesn't support it yet)
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

### **Using the Service in a Component**

Now let's see how we consume this service in a component:

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

### **Practical Exercise: Building a Data-Fetching Dashboard**

Let's walk through creating a dashboard component that fetches and displays work order statistics:

```ts
// src/app/features/dashboard/dashboard.component.ts
import { Component, OnInit, signal, computed, inject, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { WorkOrderService } from '@app/services/work-order.service';
import { WorkOrder } from '@shared/models';
import { LoadingSpinnerComponent } from '@shared/components/loading-spinner/loading-spinner.component';

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

And in the template:

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

## **Summary**

This comprehensive example demonstrates:

1. **HttpClient Configuration**: Setting up `provideHttpClient()` with interceptors
2. **Service Pattern**: Encapsulating HTTP logic in services
3. **Observable to Signal**: Converting async data to reactive signals
4. **Error Handling**: Using interceptors and error callbacks
5. **Loading States**: Managing loading indicators during requests
6. **Computed Properties**: Deriving statistics from loaded data
7. **RxJS Operators**: Using `map`, `catchError`, and `takeUntilDestroyed`
8. **Real-world Patterns**: Production-ready code from an actual application

This provides a complete foundation for making HTTP requests in modern Angular applications.
