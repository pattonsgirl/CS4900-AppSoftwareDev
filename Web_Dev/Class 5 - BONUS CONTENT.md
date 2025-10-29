# **✅ Class 5 — Project Work, Review, and Troubleshooting**

## **Goal**

Consolidate knowledge by applying all learned skills to the WSU Work Order Management system. This session is designed to be interactive, allowing for guided work time, reinforcement of key concepts, and exploration of related advanced topics based on student interest.

## **Topics**

### **Guided Student Project Time**

The majority of this class should be dedicated to students working on enhancements to the WSU Work Order Management system. The instructor's role is to circulate, answer questions, and provide guidance as students encounter challenges. This hands-on time is critical for cementing the concepts learned throughout the course.


### **1-on-1 or Group Troubleshooting**

This is an opportunity to address common stumbling blocks and misconceptions. Potential areas for review include:

* **RxJS/Signal Interop:** Clarifying why `toSignal` is used and how to handle the `initialValue`.  
* **Reactive Forms:** Debugging validation issues or problems with accessing form values.  
* **Dependency Injection:** Ensuring services are correctly provided in `app.config.ts` and injected into components.  
* **CORS Errors:** Explaining what Cross-Origin Resource Sharing (CORS) is and why it might cause HTTP requests to fail when the frontend and backend are on different origins (e.g., localhost:4200 and localhost:8080).

#### **Common Issues and Solutions**

#### Issue 1: CORS Errors

When the Angular frontend (localhost:4200) tries to communicate with the Spring Boot backend (localhost:8080), you might encounter CORS errors:

```
Access to XMLHttpRequest at 'http://localhost:8080/mr-fixit-service/work_order' 
from origin 'http://localhost:4200' has been blocked by CORS policy
```

**Solution**: Configure CORS in your Spring Boot backend:

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins("http://localhost:4200")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true);
    }
}
```

### 🔍 **Detailed Code Breakdown: Understanding CORS**

CORS (Cross-Origin Resource Sharing) is one of the most common issues in full-stack development. Let's understand it thoroughly:

**What is CORS and Why Does it Exist?**

**The browser security model:**
```
Your Angular App                    Your Spring Boot API
http://localhost:4200        →      http://localhost:8080
    (Origin 1)                           (Origin 2)
```

**What's an "origin"?**
- **Protocol** + **Domain** + **Port** = **Origin**
- `http://localhost:4200` ≠ `http://localhost:8080`
- **Different ports** = **Different origins**

**The Same-Origin Policy:**
- **Security feature** built into all browsers
- Prevents malicious websites from stealing your data
- **Blocks** JavaScript from making requests to different origins
- **Why?** Without it, evil.com could make requests to yourbank.com using your cookies!

**Example attack scenario (without CORS protection):**

```
1. You log into yourbank.com
2. Your browser stores authentication cookie
3. You visit evil.com (without closing yourbank.com)
4. evil.com JavaScript runs: fetch('https://yourbank.com/transfer', {
     method: 'POST',
     body: { to: 'evil-account', amount: 1000000 }
   })
5. Browser automatically sends YOUR cookies
6. Bank thinks it's YOU making the request
7. Your money is transferred!
```

**CORS to the rescue:**
- Browser checks: "Is evil.com allowed to make requests to yourbank.com?"
- yourbank.com says: "No! Only requests from yourbank.com itself"
- Browser blocks the request
- Your money is safe!

**Our development scenario:**

```
Browser: "Angular app at localhost:4200 wants to call API at localhost:8080"
Browser: "These are different origins - I need permission!"
Browser: Sends OPTIONS request (preflight) to localhost:8080
Backend: Must respond: "Yes, I allow localhost:4200"
Browser: "OK, I'll allow the actual request"
```

**Spring Boot CORS Configuration Breakdown:**

```java
@Configuration  // Tells Spring this is a configuration class
public class WebConfig implements WebMvcConfigurer {
```

**`@Configuration` annotation:**
- Marks class as source of bean definitions
- Spring scans and processes at startup
- Configures application-wide settings

**`implements WebMvcConfigurer`:**
- Interface providing callback methods for Spring MVC configuration
- Allows customizing default Spring MVC behavior
- **Without implementation**: Default CORS (blocks everything)
- **With implementation**: Custom CORS rules

**The addCorsMappings method:**

```java
@Override
public void addCorsMappings(CorsRegistry registry) {
    registry.addMapping("/**")
            .allowedOrigins("http://localhost:4200")
            .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
            .allowedHeaders("*")
            .allowCredentials(true);
}
```

**Line-by-line explanation:**

**`registry.addMapping("/**")`:**
```java
"/**"  // Glob pattern for all endpoints
```
- `/*` = matches all top-level paths: `/work_order`, `/building`
- `/**` = matches ALL paths including nested: `/work_order`, `/work_order/123`, `/api/v1/work_order`
- **Effect**: CORS rules apply to ENTIRE API

**Alternative patterns:**
```java
// Only specific endpoint:
registry.addMapping("/work_order/**")

// Multiple patterns:
registry.addMapping("/work_order/**")
registry.addMapping("/building/**")
```

**`.allowedOrigins("http://localhost:4200")`:**
```java
"http://localhost:4200"  // Must match EXACTLY
```

**Critical precision:**
- `http://localhost:4200` ✅
- `http://localhost:4200/` ❌ (trailing slash matters!)
- `https://localhost:4200` ❌ (https vs http)
- `http://127.0.0.1:4200` ❌ (localhost vs 127.0.0.1)

**Multiple origins for different environments:**
```java
.allowedOrigins(
    "http://localhost:4200",           // Local development
    "https://staging.example.com",     // Staging environment
    "https://www.example.com"          // Production
)

// OR dynamically:
.allowedOriginPatterns("http://localhost:*")  // Any port on localhost
```

**`.allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")`:**

Each HTTP method explained:

- **GET**: Retrieve data (read-only, safe)
  - Example: `GET /work_order` → Fetch all work orders
  
- **POST**: Create new resource
  - Example: `POST /work_order` → Create new work order
  
- **PUT**: Update entire resource
  - Example: `PUT /work_order/123` → Replace work order #123
  
- **DELETE**: Remove resource
  - Example: `DELETE /work_order/123` → Delete work order #123
  
- **OPTIONS**: Preflight check (required for CORS!)
  - Browser automatically sends this before actual request
  - Server responds with allowed methods/headers
  - **If you forget OPTIONS**: All requests fail!

**Why include OPTIONS?**
```
Browser thinking:
1. "I need to POST to /work_order"
2. "This is cross-origin - I should check first"
3. Sends: OPTIONS /work_order
4. Server responds: "Allowed methods: GET, POST, PUT, DELETE, OPTIONS"
5. Browser: "POST is allowed? Great!"
6. Sends: POST /work_order (actual request)
```

**`.allowedHeaders("*")`:**
```java
"*"  // Wildcard - allows ALL headers
```

**Common headers Angular might send:**
- `Content-Type: application/json` (for POST/PUT bodies)
- `Authorization: Bearer <token>` (for authentication)
- `X-Custom-Header: value` (custom headers)

**Why wildcard?**
- **Development**: Easy, don't worry about specific headers
- **Production**: Should be more restrictive:
  ```java
  .allowedHeaders(
      "Content-Type",
      "Authorization",
      "X-Requested-With"
  )
  ```

**`.allowCredentials(true)`:**
```java
true  // Allows sending cookies and auth headers
```

**What are "credentials"?**
- **Cookies**: Session cookies, auth cookies
- **Authorization headers**: JWT tokens, API keys
- **TLS client certificates**: Advanced auth

**When to use `true`:**
- Your API uses session cookies
- Your API uses JWT tokens in headers
- You need authentication between frontend/backend

**Security implication:**
```java
// ⚠️ DANGEROUS - Don't do this:
.allowedOrigins("*")          // Allow ANY origin
.allowCredentials(true)       // WITH credentials

// This allows evil.com to:
// 1. Make requests to your API
// 2. Include user's cookies
// 3. Steal user data!

// ✅ SAFE - Do this:
.allowedOrigins("http://localhost:4200")  // Specific origin
.allowCredentials(true)                   // Safe with specific origin
```

**Complete CORS request flow:**

```
1. Angular app loads in browser (localhost:4200)
2. User clicks "Load Work Orders"
3. Angular calls: this.http.get('http://localhost:8080/work_order')

4. Browser intercepts:
   "Wait! This is cross-origin!"

5. Browser sends OPTIONS request (preflight):
   OPTIONS http://localhost:8080/work_order
   Origin: http://localhost:4200
   Access-Control-Request-Method: GET
   Access-Control-Request-Headers: content-type

6. Spring Boot receives OPTIONS:
   - Checks WebConfig
   - Sees localhost:4200 is allowed
   - Sees GET is allowed
   - Responds:
     Access-Control-Allow-Origin: http://localhost:4200
     Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
     Access-Control-Allow-Headers: *
     Access-Control-Allow-Credentials: true

7. Browser receives response:
   "OK, this origin is allowed for GET!"

8. Browser sends actual request:
   GET http://localhost:8080/work_order
   Origin: http://localhost:4200

9. Spring Boot responds with:
   - Work order data (JSON)
   - CORS headers again
   Access-Control-Allow-Origin: http://localhost:4200

10. Browser: "Origin matches! I'll let Angular access the data"

11. Angular receives data and updates UI
```

**Common CORS debugging tips:**

**Problem: "No 'Access-Control-Allow-Origin' header"**
```
Solution: Add CORS configuration to backend
```

**Problem: "The request was blocked due to CORS policy"**
```
Check:
1. Is backend running? (No CORS headers if server is down)
2. Is WebConfig class loaded? (Add @Configuration)
3. Is URL correct? (localhost vs 127.0.0.1)
4. Is port correct? (:4200 vs :4201)
```

**Problem: "Credentials flag is true, but origin is '*'"**
```
Fix: Change from .allowedOrigins("*") to specific origin
```

**Problem: "Method PUT is not allowed by CORS"**
```
Fix: Add "PUT" to .allowedMethods()
```

**Problem: "Header 'Authorization' is not allowed"**
```
Fix: Change .allowedHeaders("*") or add "Authorization"
```

**Production CORS configuration:**

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Value("${app.cors.allowed-origins}")
    private String[] allowedOrigins;  // From application.properties

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")  // Only /api/* endpoints
                .allowedOrigins(allowedOrigins)  // From config file
                .allowedMethods("GET", "POST", "PUT", "DELETE")  // No OPTIONS here (auto-included)
                .allowedHeaders("Content-Type", "Authorization")  // Specific headers only
                .allowCredentials(true)
                .maxAge(3600);  // Cache preflight for 1 hour
    }
}
```

**In application.properties:**
```properties
# Development
app.cors.allowed-origins=http://localhost:4200

# Production
app.cors.allowed-origins=https://www.yourcompany.com,https://app.yourcompany.com
```

**Why CORS exists (the good reason):**
Without CORS, any website could steal your data from other websites. CORS is annoying in development but critical for security in production!

#### Issue 2: Form Validation Not Working

If form validation isn't triggering, check these common issues:

```ts
// ❌ WRONG - Missing ReactiveFormsModule import
@Component({
  imports: [CommonModule] // Missing ReactiveFormsModule!
})

// ✅ CORRECT - Include ReactiveFormsModule
@Component({
  imports: [CommonModule, ReactiveFormsModule]
})

// ❌ WRONG - Not marking fields as touched
onSubmit() {
  if (this.form.invalid) return; // Validation errors won't show
}

// ✅ CORRECT - Mark all fields as touched to show validation
onSubmit() {
  if (this.form.invalid) {
    this.markFormGroupTouched(this.form);
    return;
  }
}
```

#### Issue 3: Signals Not Updating UI

If changing a signal doesn't update the UI:

```ts
// ❌ WRONG - Mutating array directly
this.workOrders().push(newWorkOrder); // Signal doesn't detect this change!

// ✅ CORRECT - Create new array reference
this.workOrders.update(orders => [...orders, newWorkOrder]);

// OR

// ✅ CORRECT - Set new array
this.workOrders.set([...this.workOrders(), newWorkOrder]);
```

### 🔍 **Detailed Code Breakdown: Signal Immutability**

This is one of the most common pitfalls when working with Angular signals. Let's understand why immutability matters:

**How Angular Detects Changes:**

Angular signals use **reference equality** to detect changes:

```ts
// Angular's internal check (simplified):
if (oldValue === newValue) {
  // No change, skip update
} else {
  // Change detected, trigger update
}
```

**The Problem with Direct Mutation:**

```ts
workOrders = signal<WorkOrder[]>([
  { id: 1, title: 'Fix sink' },
  { id: 2, title: 'Paint wall' }
]);

// ❌ WRONG - Direct mutation:
this.workOrders().push({ id: 3, title: 'Replace door' });
```

**What happens here:**

```ts
const arrayReference = this.workOrders();  // Gets array reference
arrayReference.push(newWorkOrder);         // MUTATES the array

// But the REFERENCE didn't change!
// It's still pointing to the same array in memory

// Angular's check:
// oldArrayReference === currentArrayReference  →  true
// Angular thinks: "No change!" and doesn't update UI
```

**Visual representation:**

```
Memory before .push():
workOrders signal → Array at memory address 0x1234
                    [
                      { id: 1, ... },
                      { id: 2, ... }
                    ]

Memory after .push():
workOrders signal → SAME Array at memory address 0x1234
                    [
                      { id: 1, ... },
                      { id: 2, ... },
                      { id: 3, ... }  ← Added, but same reference!
                    ]

Angular: "Address 0x1234 === Address 0x1234? Yes! No update needed."
Result: UI DOESN'T update even though data changed!
```

**Solution 1: Using .update() with spread operator**

```ts
// ✅ CORRECT:
this.workOrders.update(orders => [...orders, newWorkOrder]);
```

**Breaking this down:**

```ts
this.workOrders.update(
  orders => {
//  ^^^^^^
//  Current value of signal (the array)

    return [...orders, newWorkOrder];
//         ^^^^^^^^^^
//         Spread operator creates NEW array
  }
);
```

**The spread operator `[...orders]`:**

```ts
const oldArray = [1, 2, 3];
const newArray = [...oldArray, 4];

// oldArray !== newArray  →  true (different references!)
// oldArray: [1, 2, 3]
// newArray: [1, 2, 3, 4]
```

**What `...` does:**
1. Creates brand new array
2. Copies all elements from old array
3. Adds new element at the end
4. Returns completely new array reference

**Memory after .update():**

```
OLD Array at 0x1234:
[
  { id: 1, ... },
  { id: 2, ... }
]

NEW Array at 0x5678:  ← Different memory address!
[
  { id: 1, ... },
  { id: 2, ... },
  { id: 3, ... }
]

Angular: "Address 0x1234 !== Address 0x5678? Change detected!"
Result: UI updates! ✅
```

**Solution 2: Using .set() with spread operator**

```ts
// ✅ ALSO CORRECT:
this.workOrders.set([...this.workOrders(), newWorkOrder]);
```

**Comparing .set() vs .update():**

**`.set()` - Replace entire value:**
```ts
this.workOrders.set([...this.workOrders(), newWorkOrder]);
//              ^^^
//              Direct replacement

// You must:
// 1. Get current value: this.workOrders()
// 2. Transform it: [...this.workOrders(), newWorkOrder]
// 3. Set new value: .set(newArray)
```

**`.update()` - Transform based on current:**
```ts
this.workOrders.update(orders => [...orders, newWorkOrder]);
//              ^^^^^^
//              Transform function

// Angular:
// 1. Calls your function with current value
// 2. Uses returned value as new value
// More concise for transformations
```

**When to use which:**

```ts
// ✅ Use .set() for complete replacement:
this.workOrders.set([]);  // Clear array
this.workOrders.set(newArrayFromServer);  // Replace with server data
this.count.set(42);  // Set to specific value

// ✅ Use .update() for transformations:
this.workOrders.update(orders => [...orders, newItem]);  // Add item
this.workOrders.update(orders => orders.filter(wo => wo.id !== 5));  // Remove item
this.count.update(n => n + 1);  // Increment
```

**Other common mutations to avoid:**

```ts
// ❌ WRONG - All of these mutate directly:
this.workOrders().pop();           // Remove last
this.workOrders().shift();         // Remove first
this.workOrders().unshift(item);   // Add to start
this.workOrders().splice(1, 1);    // Remove at index
this.workOrders()[0].title = 'X';  // Modify property
this.workOrders().sort();          // Sort in place
this.workOrders().reverse();       // Reverse in place

// ✅ CORRECT - Create new arrays:

// Remove last:
this.workOrders.update(orders => orders.slice(0, -1));

// Remove first:
this.workOrders.update(orders => orders.slice(1));

// Add to start:
this.workOrders.update(orders => [newItem, ...orders]);

// Remove at index:
this.workOrders.update(orders => 
  orders.filter((_, i) => i !== indexToRemove)
);

// Modify property (replace entire object):
this.workOrders.update(orders => 
  orders.map(wo => 
    wo.id === 5 
      ? { ...wo, title: 'New Title' }  // New object!
      : wo
  )
);

// Sort (create new sorted array):
this.workOrders.update(orders => 
  [...orders].sort((a, b) => a.title.localeCompare(b.title))
);

// Reverse (create new reversed array):
this.workOrders.update(orders => [...orders].reverse());
```

**Nested object immutability:**

```ts
workOrder = signal<WorkOrder>({
  id: 1,
  title: 'Fix sink',
  room: { buildingId: 2, roomNumber: '101' }
});

// ❌ WRONG - Mutates nested object:
this.workOrder().room.roomNumber = '102';

// ✅ CORRECT - Replace entire object:
this.workOrder.update(wo => ({
  ...wo,           // Copy all properties
  room: {          // Replace room object
    ...wo.room,    // Copy existing room properties
    roomNumber: '102'  // Override roomNumber
  }
}));
```

**The complete pattern:**

```ts
// For primitives (number, string, boolean):
count = signal(0);
this.count.set(1);              // Simple replacement
this.count.update(n => n + 1);  // Transform

// For arrays:
items = signal<Item[]>([]);
this.items.set([...newItems]);              // Replace
this.items.update(arr => [...arr, item]);   // Add (create new array)
this.items.update(arr => arr.filter(...));  // Remove (filter creates new)

// For objects:
user = signal<User>({ name: 'John', age: 30 });
this.user.set({ name: 'Jane', age: 25 });           // Replace
this.user.update(u => ({ ...u, age: 31 }));         // Update property

// For nested structures:
complex = signal<Complex>({ 
  user: { name: 'John' }, 
  items: [1, 2, 3] 
});
this.complex.update(c => ({
  ...c,
  user: { ...c.user, name: 'Jane' },    // New user object
  items: [...c.items, 4]                // New items array
}));
```

**Why this matters in our WSU application:**

```ts
// In WorkOrderListComponent:
workOrders = signal<WorkOrder[]>([]);

// When we fetch from server:
loadWorkOrders(): void {
  this.service.getWorkOrders().subscribe({
    next: (response) => {
      // ✅ CORRECT - Replace with server data:
      this.workOrders.set(response.data);
    }
  });
}

// When user creates new work order:
addWorkOrder(newWorkOrder: WorkOrder): void {
  // ✅ CORRECT - Add to existing array:
  this.workOrders.update(orders => [...orders, newWorkOrder]);
}

// When user deletes work order:
deleteWorkOrder(id: number): void {
  // ✅ CORRECT - Filter creates new array:
  this.workOrders.update(orders => 
    orders.filter(wo => wo.orderNumber !== id)
  );
}

// When user updates work order:
updateWorkOrder(updated: WorkOrder): void {
  // ✅ CORRECT - Map creates new array with new objects:
  this.workOrders.update(orders =>
    orders.map(wo => 
      wo.orderNumber === updated.orderNumber 
        ? { ...updated }  // New object
        : wo
    )
  );
}
```

**Performance note:**

You might think: "Creating new arrays/objects every time is wasteful!"

**Actually:**
- JavaScript engines optimize this heavily
- Spread operator is very fast (shallow copy)
- Change detection is MUCH faster when it can use reference checks
- Mutable updates that don't trigger renders are MORE wasteful (user sees stale data!)

**The golden rule:**
**"Never mutate what a signal holds. Always create new references."**

### Issue 4: Subscription Memory Leaks

If you're subscribing to Observables without cleanup:

```ts
// ❌ WRONG - No cleanup, causes memory leaks
ngOnInit() {
  this.service.getData().subscribe(data => {
    this.data.set(data);
  });
}

// ✅ CORRECT - Use takeUntilDestroyed
ngOnInit() {
  this.service.getData()
    .pipe(takeUntilDestroyed(this.destroyRef))
    .subscribe(data => {
      this.data.set(data);
    });
}

// ✅ ALSO CORRECT - Use toSignal
data = toSignal(this.service.getData(), { initialValue: [] });
```

### **Optional Exploration: Advanced Features**

Based on student progress and questions, we can introduce related, more advanced topics.

#### **Routing with Parameters**

Our WSU application uses routing with parameters extensively. Let's examine how it works:

**Route Configuration:**

```ts
// src/app/app.routes.ts
export const routes: Routes = [
  {
    path: 'work-orders',
    children: [
      {
        path: 'list',
        loadComponent: () => import('./features/work-orders/components/work-order-list/work-order-list.component')
          .then(m => m.WorkOrderListComponent)
      },
      {
        path: 'create',
        loadComponent: () => import('./features/work-orders/components/work-order-form/work-order-form.component')
          .then(m => m.WorkOrderFormComponent)
      },
      {
        path: ':id', // Route parameter
        loadComponent: () => import('./features/work-orders/components/work-order-detail/work-order-detail.component')
          .then(m => m.WorkOrderDetailComponent)
      }
    ]
  }
];
```

**Accessing Route Parameters (Modern Approach):**

```ts
// src/app/features/work-orders/components/work-order-detail/work-order-detail.component.ts
export class WorkOrderDetailComponent extends BaseComponent {
  // Modern: Use input() with route parameter binding
  id = input.required<string>();

  constructor() {
    super();

    // React to route parameter changes with effect
    effect(() => {
      const workOrderId = this.id();
      if (workOrderId) {
        this.loadWorkOrder(workOrderId);
      }
    });
  }

  private async loadWorkOrder(id: string): Promise<void> {
    const workOrder = await this.handleAsync(
      () => firstValueFrom(this.workOrderService.getWorkOrderById(parseInt(id))),
      'Failed to load work order'
    );

    if (workOrder) {
      this.workOrder.set(workOrder);
    }
  }
}
```

**Navigating with Parameters:**

```html
<!-- In work-order-list.component.html -->
<a [routerLink]="['/work-orders', workOrder.orderNumber]" class="work-order-title">
  {{ workOrder.title }}
</a>

<!-- Or with navigation -->
<button (click)="viewDetails(workOrder.orderNumber)">View Details</button>
```

```ts
viewDetails(id: number): void {
  this.router.navigate(['/work-orders', id]);
}
```

#### **Component Lifecycle Hooks**

Angular provides several lifecycle hooks. Our WSU application uses these strategically:

```ts
export class WorkOrderListComponent implements OnInit, AfterViewInit {
  private readonly destroyRef = inject(DestroyRef);

  /**
   * ngOnInit - Called once after component creation
   * Use for: Initial data loading, service subscriptions
   */
  ngOnInit(): void {
    this.loadWorkOrders();
    this.setupFilters();
  }

  /**
   * ngAfterViewInit - Called after component's view is initialized
   * Use for: DOM manipulation, accessing ViewChild elements
   */
  ngAfterViewInit(): void {
    // Example: Focus on search input
    this.searchInput?.nativeElement.focus();
  }

  /**
   * ngOnDestroy - Called before component is destroyed
   * Note: With DestroyRef and takeUntilDestroyed, manual cleanup is often unnecessary
   */
}
```

**Modern Cleanup Pattern:**

Instead of implementing `ngOnDestroy`:

```ts
// ❌ OLD WAY - Manual cleanup
export class OldComponent implements OnDestroy {
  private destroy$ = new Subject<void>();

  ngOnInit() {
    this.service.getData()
      .pipe(takeUntil(this.destroy$))
      .subscribe(data => this.handleData(data));
  }

  ngOnDestroy() {
    this.destroy$.next();
    this.destroy$.complete();
  }
}

// ✅ NEW WAY - Automatic cleanup with DestroyRef
export class ModernComponent {
  private readonly destroyRef = inject(DestroyRef);

  ngOnInit() {
    this.service.getData()
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(data => this.handleData(data));
  }
  // No ngOnDestroy needed!
}
```

#### **Performance with Deferred Loading (@defer)**

This is a powerful and highly relevant modern feature. Our application could be enhanced with deferred loading for heavy components:

```html
<!-- src/app/features/dashboard/dashboard.component.html -->

<!-- Load technician efficiency widget only when scrolled into view -->
<section class="technician-section">
  <h2 class="section-title">Top Technicians</h2>
  
  @defer (on viewport) {
    <app-technician-efficiency-widget 
      [workOrders]="workOrders()">
    </app-technician-efficiency-widget>
  } @placeholder {
    <div class="widget-placeholder">
      <p>Scroll down to load technician statistics</p>
    </div>
  } @loading {
    <app-loading-spinner message="Loading technician data..."></app-loading-spinner>
  }
</section>

<!-- Load chart component only when user clicks a button -->
<section class="analytics-section">
  <button #chartTrigger class="btn btn-primary">Show Analytics Chart</button>
  
  @defer (on interaction(chartTrigger)) {
    <app-work-order-analytics-chart 
      [data]="workOrders()">
    </app-work-order-analytics-chart>
  } @placeholder {
    <div class="chart-placeholder">
      <p>Click the button to load analytics</p>
    </div>
  } @loading (minimum 500ms) {
    <app-loading-spinner message="Preparing chart..."></app-loading-spinner>
  }
</section>

<!-- Prefetch on hover for better UX -->
<section class="details-section">
  <a routerLink="/work-orders/detailed-report" #reportLink>
    View Detailed Report
  </a>
  
  @defer (on hover(reportLink); prefetch on idle) {
    <app-detailed-report-preview></app-detailed-report-preview>
  }
</section>
```

**@defer Triggers:**

- `on idle` - Load when browser is idle
- `on viewport` - Load when element enters viewport
- `on interaction(element)` - Load when user interacts with element
- `on hover(element)` - Load when user hovers over element
- `on immediate` - Load immediately
- `on timer(duration)` - Load after specified duration

**@defer Sub-blocks:**

- `@placeholder` - Content shown before loading starts
- `@loading` - Content shown while loading
- `@error` - Content shown if loading fails

#### 🔍 **Detailed Code Breakdown: @defer Deferrable Views**

The `@defer` block is one of Angular's most powerful performance features. Let's understand how it works in depth:

**What Problem Does @defer Solve?**

**Traditional loading (everything at once):**
```
User navigates to dashboard
    ↓
Angular loads ALL components
    ↓
- Main dashboard: 50 KB
- Chart component: 200 KB ← User might never scroll here!
- Analytics widget: 150 KB ← User might never click!
- Export module: 100 KB ← Rarely used!
    ↓
Total: 500 KB downloaded immediately
Initial page: SLOW ❌
```

**With @defer (lazy loading):**
```
User navigates to dashboard
    ↓
Angular loads ONLY visible components
    ↓
- Main dashboard: 50 KB
    ↓
Total: 50 KB downloaded
Initial page: FAST ✅
    ↓
User scrolls → Chart loads (200 KB)
User clicks button → Analytics loads (150 KB)
User clicks export → Export loads (100 KB)
```

**Basic @defer Syntax:**

```html
@defer (on viewport) {
  <!-- Deferred content: Only loaded when visible -->
  <app-heavy-component></app-heavy-component>
} @placeholder {
  <!-- Shown BEFORE loading starts -->
  <div>Scroll down to load content</div>
} @loading {
  <!-- Shown WHILE loading -->
  <app-loading-spinner></app-loading-spinner>
} @error {
  <!-- Shown IF loading fails -->
  <div>Failed to load component</div>
}
```

**The Lifecycle of a @defer Block:**

```
Stage 1: PLACEHOLDER
    ↓
User triggers condition (e.g., scrolls into view)
    ↓
Stage 2: LOADING
    ↓
Angular downloads component JavaScript
    ↓
Component initializes
    ↓
Stage 3: LOADED (or ERROR if fails)
```

**Trigger: `on viewport`**

```html
@defer (on viewport) {
  <app-technician-widget [workOrders]="workOrders()"></app-technician-widget>
}
```

**How this works:**

```ts
// Angular uses Intersection Observer API:
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      // Element is visible! Start loading
      loadComponent();
    }
  });
});

observer.observe(placeholderElement);
```

**Visual representation:**

```
Browser viewport (visible area):
┌─────────────────────────┐
│  Dashboard Header       │
│  Statistics Cards       │
│  Work Order List        │
│                         │  ← User scrolls down
└─────────────────────────┘
  ↓ Scroll ↓
┌─────────────────────────┐
│  Work Order List        │
│  [Placeholder]          │ ← Enters viewport!
│                         │
│                         │  Trigger fires →
└─────────────────────────┘   Load widget
```

**Why this is powerful:**
- **Bandwidth saved**: Don't load what user never sees
- **CPU saved**: Don't initialize unused components
- **Memory saved**: Don't keep unused components in memory
- **Initial load faster**: Smaller bundle to download

**Trigger: `on interaction`**

```html
<button #chartTrigger>Show Analytics</button>

@defer (on interaction(chartTrigger)) {
  <app-analytics-chart [data]="workOrders()"></app-analytics-chart>
}
```

**How this works:**

```ts
// Angular adds event listener to the trigger element:
chartTriggerElement.addEventListener('click', () => {
  loadComponent();
}, { once: true }); // Only trigger once!
```

**User experience flow:**

```
1. User sees button: "Show Analytics"
2. Chart component NOT loaded yet (0 KB)
3. User clicks button
4. Click event fires
5. Angular starts loading chart component
6. Loading spinner shows
7. Chart component downloads (200 KB)
8. Chart renders with data
```

**Why this is brilliant:**
- Feature used by 10% of users? Other 90% don't pay the cost!
- User explicitly requested it? They're willing to wait
- Progressive enhancement at its finest

**Trigger: `on hover`**

```html
<a routerLink="/report" #reportLink>View Report</a>

@defer (on hover(reportLink); prefetch on idle) {
  <app-report-preview></app-report-preview>
}
```

**Multiple triggers explained:**

```html
on hover(reportLink)     prefetch on idle
^^^^^^^^^^^^^^^^^^^^^    ^^^^^^^^^^^^^^^^^
Main trigger             Secondary trigger
```

**Main trigger: `on hover`**
```ts
reportLinkElement.addEventListener('mouseenter', () => {
  loadComponentAndRender();  // Load AND show
});
```

**Prefetch trigger: `on idle`**
```ts
// When browser has nothing else to do:
requestIdleCallback(() => {
  downloadComponent();  // Download but DON'T render
});
```

**Smart loading strategy:**

```
Timeline:

0s - Page loads
    ↓
2s - Browser idle detected
    ↓
    prefetch on idle fires
    ↓
    Downloads component (but doesn't render)
    ↓
5s - User hovers over link
    ↓
    on hover fires
    ↓
    Component ALREADY downloaded!
    ↓
    Instant render (feels instant to user!)
```

**Why prefetch?**
- **Predictive**: Anticipate what user might want
- **Non-blocking**: Only when browser has free time
- **Instant UX**: When user acts, it's already ready

**Trigger: `on timer`**

```html
@defer (on timer(5000ms)) {
  <app-newsletter-popup></app-newsletter-popup>
}
```

**How this works:**

```ts
setTimeout(() => {
  loadComponent();
}, 5000);  // 5 seconds
```

**Use cases:**
- Non-critical features that can wait
- Popups/modals that appear after delay
- Background data loading
- Time-based promotions

**Trigger: `on idle`**

```html
@defer (on idle) {
  <app-background-sync></app-background-sync>
}
```

**How this works:**

```ts
// Browser's requestIdleCallback API:
requestIdleCallback(() => {
  // CPU is free, user not interacting
  loadComponent();
}, { timeout: 2000 });  // Max 2s wait
```

**When browser is "idle":**
- No animations running
- No user scrolling/clicking
- No network requests
- CPU usage low

**Perfect for:**
- Analytics components
- Monitoring widgets
- Background tasks
- Non-essential features

**The @loading Block with Minimum Time:**

```html
@defer (on viewport) {
  <app-chart></app-chart>
} @loading (minimum 500ms) {
  <app-loading-spinner></app-loading-spinner>
}
```

**Why `minimum 500ms`?**

**Without minimum (bad UX):**
```
0ms: Start loading
50ms: Component loaded (very fast!)
    ↓
Spinner flashes for 50ms (user sees flicker)
    ↓
Content appears
Result: Jarring, feels buggy ❌
```

**With minimum (good UX):**
```
0ms: Start loading
50ms: Component loaded (but...)
    ↓
Spinner keeps showing until 500ms
    ↓
500ms: Smooth transition to content
Result: Feels polished, no flicker ✅
```

**Implementation:**

```ts
const startTime = Date.now();
const minLoadingTime = 500;

loadComponent().then(() => {
  const elapsed = Date.now() - startTime;
  const remaining = Math.max(0, minLoadingTime - elapsed);
  
  setTimeout(() => {
    showContent();  // Show after minimum time
  }, remaining);
});
```

**The @placeholder Block:**

```html
@defer (on viewport) {
  <app-widget></app-widget>
} @placeholder (minimum 100ms) {
  <div class="placeholder-skeleton">
    <!-- Skeleton screen -->
  </div>
}
```

**Why placeholder minimum?**

```
// Without minimum:
User scrolls fast through page
    ↓
Viewport triggers fire rapidly
    ↓
Placeholders flash in/out quickly
    ↓
Result: Looks broken ❌

// With minimum:
User scrolls fast
    ↓
Placeholder shows for at least 100ms
    ↓
Either loads or gracefully disappears
    ↓
Result: Looks intentional ✅
```

**Real-World Example in WSU App:**

```html
<!-- src/app/features/dashboard/dashboard.component.html -->

<section class="statistics-section">
  <!-- Always loaded - critical first-screen content -->
  <app-statistics-cards [workOrders]="workOrders()"></app-statistics-cards>
</section>

<section class="charts-section">
  <!-- Deferred - user might not scroll here -->
  @defer (on viewport; prefetch on idle) {
    <app-work-order-trends-chart 
      [workOrders]="workOrders()"
      [dateRange]="dateRange()">
    </app-work-order-trends-chart>
  } @placeholder (minimum 200ms) {
    <div class="chart-skeleton">
      <div class="skeleton-title"></div>
      <div class="skeleton-bars"></div>
    </div>
  } @loading (minimum 500ms) {
    <div class="chart-loading">
      <app-loading-spinner message="Loading chart..."></app-loading-spinner>
    </div>
  } @error {
    <div class="chart-error">
      <p>Failed to load chart</p>
      <button (click)="retryLoadChart()">Retry</button>
    </div>
  }
</section>

<section class="export-section">
  <!-- Deferred - only when user clicks -->
  <button #exportTrigger class="btn-export">
    Export Reports
  </button>
  
  @defer (on interaction(exportTrigger)) {
    <app-export-dialog 
      [workOrders]="workOrders()">
    </app-export-dialog>
  } @loading (minimum 300ms) {
    <app-loading-spinner message="Loading export tool..."></app-loading-spinner>
  }
</section>
```

**Performance Impact:**

**Before @defer:**
```
Initial Bundle Size: 850 KB
Time to Interactive: 4.2s
First Contentful Paint: 2.8s
```

**After @defer:**
```
Initial Bundle Size: 320 KB (62% reduction!)
Time to Interactive: 1.5s (64% faster!)
First Contentful Paint: 0.9s (68% faster!)

Chart component: Loads only when visible
Export dialog: Loads only when requested
Analytics: Loads during idle time
```

**Bundle analysis:**

```
Main bundle (always loaded):
- Dashboard component: 50 KB
- Work order list: 80 KB
- Statistics cards: 40 KB
- Core services: 150 KB
Total: 320 KB

Lazy chunks (loaded on demand):
- Chart component: 200 KB (loaded on scroll)
- Export dialog: 180 KB (loaded on click)
- Analytics widget: 150 KB (loaded when idle)
Total deferred: 530 KB

Total app: 850 KB (but only 320 KB initially!)
```

**Best Practices:**

```html
<!-- ✅ DO: Defer heavy, non-critical components -->
@defer (on viewport) {
  <app-heavy-chart></app-heavy-chart>
}

<!-- ❌ DON'T: Defer critical above-the-fold content -->
@defer (on viewport) {
  <app-page-title></app-page-title>  <!-- User needs this immediately! -->
}

<!-- ✅ DO: Use appropriate triggers -->
@defer (on interaction(button)) {
  <app-modal></app-modal>  <!-- Perfect: user explicitly requested -->
}

<!-- ❌ DON'T: Defer things that affect layout -->
@defer (on viewport) {
  <app-navigation></app-navigation>  <!-- Page will jump when this loads! -->
}

<!-- ✅ DO: Provide meaningful placeholders -->
@defer (on viewport) {
  <app-widget></app-widget>
} @placeholder {
  <div class="skeleton">  <!-- Matches real component size -->
    <!-- Skeleton screen -->
  </div>
}

<!-- ❌ DON'T: Leave placeholders empty -->
@defer (on viewport) {
  <app-widget></app-widget>
} @placeholder {
  <!-- Nothing here - page jumps when content loads! -->
}
```

**The Future of Performance:**

`@defer` represents Angular's vision for the future:
- **Declarative**: You describe what you want, Angular handles how
- **Automatic**: Code splitting happens automatically
- **Flexible**: Multiple triggers for different scenarios
- **Predictive**: Prefetch anticipates user needs

This is how modern web apps should be built: fast initial loads, smart lazy loading, and seamless user experiences.

#### **HTTP Interceptors Deep Dive**

Our WSU application uses interceptors for cross-cutting concerns:

```ts
// src/app/shared/interceptors/retry.interceptor.ts
export function retryInterceptor(
  request: HttpRequest<unknown>, 
  next: HttpHandlerFn
): Observable<any> {
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
          // Don't retry if we've exceeded max retries
          if (index >= defaultConfig.maxRetries) {
            return throwError(() => error);
          }

          // Don't retry if the error status code is not retryable
          if (!defaultConfig.retryableStatusCodes.includes(error.status)) {
            return throwError(() => error);
          }

          // Calculate delay with exponential backoff
          const delayTime = defaultConfig.retryDelay * 
                           Math.pow(defaultConfig.backoffMultiplier, index);
          
          console.log(`Retrying request (attempt ${index + 1})`);
          
          return timer(delayTime);
        }),
        take(defaultConfig.maxRetries + 1)
      )
    )
  );
}
```

**Custom Interceptor Example - Adding Authentication:**

```ts
// Example: auth.interceptor.ts
export function authInterceptor(
  request: HttpRequest<unknown>,
  next: HttpHandlerFn
): Observable<any> {
  const authToken = localStorage.getItem('auth_token');
  
  if (authToken) {
    // Clone request and add authorization header
    request = request.clone({
      setHeaders: {
        Authorization: `Bearer ${authToken}`
      }
    });
  }
  
  return next(request);
}

// Register in app.config.ts
export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(
      withInterceptors([authInterceptor, retryInterceptor, errorInterceptor])
    )
  ]
};
```

#### **Reviewing and Connecting All Pieces**

Dedicate the final part of the class to a high-level review, tracing the flow of data and events through the WSU Work Order Management application:

### **Complete Application Flow**

1. **Initial Load**
   - User navigates to `http://localhost:4200/dashboard`
   - Angular Router matches route and loads `DashboardComponent`
   - Component's `ngOnInit()` calls `loadDashboardData()`

2. **Data Fetching**
   - `loadDashboardData()` calls `workOrderService.getWorkOrders()`
   - Service uses `ApiService.get()` which uses `HttpClient`
   - Request passes through **retry interceptor** and **error interceptor**
   - HTTP GET request sent to `http://localhost:8080/mr-fixit-service/work_order`

3. **Backend Processing**
   - Spring Boot backend receives request
   - JPA repository queries database
   - Data transformed to DTOs
   - Response sent back with work orders array

4. **Frontend Response Handling**
   - Observable emits response data
   - Component updates `workOrders` signal using `.set()`
   - Multiple **computed signals** automatically recalculate:
     - `totalOrders()`
     - `openOrders()`
     - `completionRate()`
   - Template reactively updates with new data

5. **User Interaction**
   - User sees dashboard with statistics
   - User clicks "Create New Work Order" button
   - **Event binding** `(click)` triggers navigation
   - Router loads `WorkOrderFormComponent`

6. **Form Interaction**
   - Component creates **Reactive Form** with validators
   - User fills out title, description, category, location
   - Real-time validation shows errors on blur/touch
   - `categoryOptions` signal provides dropdown data from `LookupService`

7. **Form Submission**
   - User clicks "Create Work Order" button
   - `(ngSubmit)` event binding calls `onSubmit()`
   - Form validation runs - if invalid, shows errors
   - If valid, component calls `workOrderService.createWorkOrder()`

8. **Creating Data**
   - Service transforms form data to backend DTO format
   - HTTP POST request sent to backend
   - Backend creates work order in database
   - Returns created work order with generated ID

9. **Post-Create Navigation**
   - Component receives success response
   - Updates `isSubmitting` signal to `false`
   - Shows success message
   - Navigates to detail view: `/work-orders/{id}`

10. **Detail View**
    - Router loads `WorkOrderDetailComponent`
    - Component uses `input.required<string>()` for route parameter
    - **Effect** reacts to `id()` change and loads work order
    - Service fetches work order by ID from backend
    - Signal updated with work order data
    - Template displays complete work order information

11. **Refresh Cycle**
    - User navigates back to list
    - Clicks refresh button
    - Event binding calls `refreshList()`
    - Re-fetches data from server
    - List updates with latest data including new work order

### **Best Practices Review**

Conclude with a summary of key software development principles as they apply to Angular and our WSU project:

#### **Code Organization**

```
✅ DO: Feature-based organization
src/app/
  features/
    work-orders/
      components/
    dashboard/
  shared/
    components/
    models/
    utils/
  services/

❌ DON'T: Flat structure with all components in one folder
```

#### **Naming Conventions**

```ts
// ✅ DO: Clear, descriptive names
export class WorkOrderListComponent { }
export class WorkOrderService { }
export interface WorkOrder { }

// ❌ DON'T: Vague or inconsistent names
export class List { }
export class DataService { }
export interface Item { }
```

#### **DRY (Don't Repeat Yourself)**

```ts
// ✅ DO: Extract common logic to services
export class ApiService {
  get<T>(endpoint: string): Observable<T> { }
  post<T>(endpoint: string, data: any): Observable<T> { }
}

// ❌ DON'T: Duplicate HTTP logic in every component
export class WorkOrderComponent {
  loadData() {
    return this.http.get('http://localhost:8080/...')
      .pipe(map(response => ({ success: true, data: response })));
  }
}
```

#### **SRP (Single Responsibility Principle)**

```ts
// ✅ DO: Components handle presentation
export class WorkOrderListComponent {
  workOrders = signal<WorkOrder[]>([]);
  
  ngOnInit() {
    this.loadWorkOrders(); // Delegates to service
  }
}

// ✅ DO: Services handle business logic and data
export class WorkOrderService {
  getWorkOrders(): Observable<WorkOrder[]> {
    return this.apiService.get('work_order')
      .pipe(map(response => response.data));
  }
}

// ❌ DON'T: Mix concerns
export class WorkOrderListComponent {
  ngOnInit() {
    // Component shouldn't contain HTTP logic
    this.http.get('http://localhost:8080/work_order')
      .pipe(map(r => r.data))
      .subscribe(data => this.workOrders.set(data));
  }
}
```

#### **Type Safety**

```ts
// ✅ DO: Use interfaces for type safety
export interface WorkOrder {
  orderNumber: number;
  title: string;
  status: WorkOrderStatus;
}

workOrders = signal<WorkOrder[]>([]);

// ❌ DON'T: Use any type
workOrders = signal<any[]>([]);
```

#### **Error Handling**

```ts
// ✅ DO: Handle errors gracefully
this.service.getData().subscribe({
  next: (data) => this.handleData(data),
  error: (error) => {
    console.error('Error loading data:', error);
    this.showError('Failed to load data');
  }
});

// ❌ DON'T: Ignore errors
this.service.getData().subscribe(data => this.handleData(data));
```

### **Project Resources and Next Steps**

**Recommended Learning Resources:**
1. **Official Angular Documentation**: https://angular.dev
2. **RxJS Documentation**: https://rxjs.dev
3. **Angular Blog**: https://blog.angular.io
4. **Angular Signals RFC**: Understanding the future of reactivity

**Career Development:**
- Build portfolio projects using these concepts
- Contribute to open-source Angular projects
- Stay updated with Angular releases and new features
- Practice with coding challenges focused on reactive programming
