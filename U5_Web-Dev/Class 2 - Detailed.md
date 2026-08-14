# **🧠 Class 2 — Behavior & State Management with Signals**

## **Goal**

Understand how to add dynamic functionality to components using event binding and manage application state reactively with Angular Signals using real examples from the WSU Work Order Management application. Introduce services for logic encapsulation and modern, signal-based component inputs.

## **Topics**

### **What are Signals? The New Reactive Primitive**

Angular Signals are the new foundation for reactivity in the framework. A signal is a wrapper around a value that can notify interested consumers when that value changes. This system allows Angular to perform highly efficient, fine-grained updates to the UI. Instead of checking an entire component for changes, Angular knows exactly which parts of the DOM depend on a specific signal and updates only those parts when the signal's value is modified. This approach simplifies the mental model for developers: change a value, and the UI updates automatically, without the need to manually manage subscriptions or change detection cycles.

### **Writable Signals**

A writable signal is a signal whose value can be changed directly.

* **Creation:** You create a signal using the `signal()` function from `@angular/core`, providing an initial value.

```ts
// In a component class
isLoading = signal(false);
workOrders = signal<WorkOrder[]>([]);
currentPage = signal(1);
```

* **Reading:** To read a signal's value, you call it like a function. This syntax is crucial, as it's how Angular tracks where the signal is being used.

```html
<p>The current count is: {{ isLoading() }}</p>

@if (isLoading()) {
  <app-loading-spinner />
}
```

* **Updating:** There are two primary methods for updating a writable signal's value:  
  * **.set(newValue)**: Replaces the current value with a new one. `this.isLoading.set(true);`  
  * **.update(updateFn)**: Computes a new value based on the current value. This is safer for state transitions that depend on the previous state. `this.currentPage.update(currentValue => currentValue + 1);`

Looking at our `WorkOrderListComponent`, we can see signals in action:

```ts
// src/app/features/work-orders/components/work-order-list/work-order-list.component.ts
export class WorkOrderListComponent implements OnInit {
  workOrders = signal<WorkOrder[]>([]);
  filteredWorkOrders = signal<WorkOrder[]>([]);
  isLoading = signal<boolean>(true);
  totalCount = signal<number>(0);
  currentPage = signal<number>(1);
  pageSize = signal<number>(10);
  filtersCollapsed = signal<boolean>(false);

  // Load work orders
  private loadWorkOrders(): void {
    this.isLoading.set(true); // Update loading state

    this.workOrderService.getWorkOrders().pipe(
      takeUntilDestroyed(this.destroyRef)
    ).subscribe({
      next: (response: any) => {
        this.workOrders.set(response.data); // Set complete list
        this.applyFilters();
        this.isLoading.set(false); // Clear loading state
      },
      error: (error) => {
        console.error('Failed to load work orders:', error);
        this.isLoading.set(false);
      }
    });
  }

  // Update page
  onPageChange(page: number): void {
    this.currentPage.set(page);
    this.applyFilters();
  }

  // Toggle filters
  toggleFiltersCollapse(): void {
    this.filtersCollapsed.update(collapsed => !collapsed);
  }
}
```

### 🔍 **Detailed Code Breakdown: Writable Signals in Action**

Let's examine each signal declaration and understand the patterns:

**Signal Declarations:**

```ts
workOrders = signal<WorkOrder[]>([]);
```

**Breaking this down:**
- `workOrders` - Property name (convention: plural for arrays)
- `signal<WorkOrder[]>` - Generic function call with TypeScript type parameter
- `<WorkOrder[]>` - Type parameter: array of WorkOrder objects
- `([])` - Initial value: empty array
- **Result**: Creates a `WritableSignal<WorkOrder[]>`

**Why explicitly type the signal?**
```ts
// ❌ Without type parameter:
workOrders = signal([]);  // Type is WritableSignal<never[]> - can't add items!

// ✅ With type parameter:
workOrders = signal<WorkOrder[]>([]);  // Type is WritableSignal<WorkOrder[]> - correct!
```

**Multiple Signal Patterns:**

```ts
isLoading = signal<boolean>(true);
```
- **Boolean signals**: Common for UI state (loading, collapsed, disabled)
- Initial value: `true` (starts in loading state)
- **Usage pattern**: Toggle between states, show/hide UI elements

```ts
currentPage = signal<number>(1);
pageSize = signal<number>(10);
```
- **Number signals**: For counters, pagination, quantities
- **Convention**: Start counting from 1 for pages (user-friendly)
- **Why 10?** Common default page size (balance between data/performance)

```ts
totalCount = signal<number>(0);
```
- **Defensive initialization**: Start with 0 (prevents undefined errors)
- Will be updated when data loads from server
- Used in computed signals for pagination math

**The `.set()` Method Deep Dive:**

```ts
this.isLoading.set(true);
```

**What happens internally:**
1. Signal stores old value reference
2. Signal compares new value with old value
3. If different, updates internal value
4. Marks all dependent consumers as "dirty"
5. Schedules change detection
6. Returns void

**Memory efficiency:**
```ts
// Primitive values (boolean, number, string):
this.isLoading.set(false);  // Direct value comparison
this.currentPage.set(2);     // Direct value comparison

// Object/Array values:
this.workOrders.set([...newOrders]);  // Reference comparison!
```

**Critical distinction:**
```ts
// ❌ This WON'T trigger updates (same reference):
const orders = this.workOrders();
orders.push(newOrder);
this.workOrders.set(orders);  // Same array reference!

// ✅ This WILL trigger updates (new reference):
this.workOrders.set([...this.workOrders(), newOrder]);  // New array!
```

**The `.update()` Method Deep Dive:**

```ts
this.filtersCollapsed.update(collapsed => !collapsed);
```

**Breaking down the syntax:**
- `.update()` - Signal method for computed updates
- `collapsed =>` - Arrow function receiving current value
- `!collapsed` - Returns opposite boolean (toggle pattern)
- **Type safety**: Parameter type inferred from signal type

**Why use `.update()` instead of `.set()`?**

```ts
// ❌ Verbose and error-prone:
const current = this.filtersCollapsed();
this.filtersCollapsed.set(!current);

// ✅ Concise and safe:
this.filtersCollapsed.update(collapsed => !collapsed);
```

**The `.update()` advantage:**
- **Race condition safe**: Reads value at moment of update
- **Type-safe**: TypeScript ensures return type matches signal type
- **Functional style**: Declares transformation, not imperative steps
- **Composable**: Can chain logic easily

**Common `.update()` patterns:**

```ts
// Toggle boolean:
this.isCollapsed.update(v => !v);

// Increment counter:
this.currentPage.update(page => page + 1);

// Decrement with minimum:
this.currentPage.update(page => Math.max(1, page - 1));

// Add to array (immutably):
this.workOrders.update(orders => [...orders, newOrder]);

// Remove from array:
this.workOrders.update(orders => 
  orders.filter(wo => wo.orderNumber !== deleteId)
);

// Update object property:
this.formData.update(data => ({
  ...data,
  title: 'New Title'
}));
```

**Loading Pattern Analysis:**

```ts
private loadWorkOrders(): void {
  this.isLoading.set(true); // 1. Set loading state BEFORE async operation

  this.workOrderService.getWorkOrders().pipe(
    takeUntilDestroyed(this.destroyRef)
  ).subscribe({
    next: (response: any) => {
      this.workOrders.set(response.data); // 2. Update data
      this.applyFilters();                 // 3. Process data
      this.isLoading.set(false);          // 4. Clear loading state
    },
    error: (error) => {
      console.error('Failed to load work orders:', error);
      this.isLoading.set(false);          // 5. CRITICAL: Also clear on error!
    }
  });
}
```

**Why set loading BEFORE the call?**
1. **Immediate UI feedback**: User sees loading spinner instantly
2. **Prevents double-clicks**: Can disable buttons while loading
3. **Clear state management**: Always know if operation is in progress

**Why clear loading in BOTH success and error?**
- **Error case**: If we forget, UI stays in loading state forever (terrible UX)
- **Pattern**: ALWAYS pair `set(true)` with `set(false)` in all branches
- **Alternative**: Use `finalize()` operator (more advanced)

```ts
// Better pattern with finalize:
this.workOrderService.getWorkOrders().pipe(
  takeUntilDestroyed(this.destroyRef),
  finalize(() => this.isLoading.set(false))  // Always runs, success or error!
).subscribe({
  next: (response) => {
    this.workOrders.set(response.data);
    this.applyFilters();
  },
  error: (error) => {
    console.error('Failed to load work orders:', error);
  }
});
```

**Pagination Pattern:**

```ts
onPageChange(page: number): void {
  this.currentPage.set(page);
  this.applyFilters();
}
```

**Simple but powerful pattern:**
1. **Update state**: Change page number
2. **Trigger side effect**: Refilter/refetch data
3. **UI updates automatically**: Computed signals recalculate

**Event flow:**
1. User clicks "Next Page" button
2. Button calls `(click)="onPageChange(currentPage() + 1)"`
3. Method updates `currentPage` signal
4. `applyFilters()` uses new page value
5. Filtered data updates
6. Template re-renders with new data
7. All happens in milliseconds!

**Why not use computed signal for filtering?**

```ts
// ❌ Tempting but problematic:
filteredWorkOrders = computed(() => {
  const orders = this.workOrders();
  const page = this.currentPage();
  // Apply filters and pagination...
  return filtered;
});
```

**Problems:**
- Recalculates on EVERY dependency change (workOrders OR currentPage)
- Can't make async calls in computed (no API fetching)
- Hard to debug complex filter logic

```ts
// ✅ Better: Separate method with explicit triggers
applyFilters(): void {
  const filtered = this.workOrders()
    .filter(/* ... */)
    .slice(start, end);
  this.filteredWorkOrders.set(filtered);
}
```

**Benefits:**
- **Explicit**: Clear when filtering happens
- **Debuggable**: Can log, breakpoint, step through
- **Flexible**: Can add async operations if needed
- **Performant**: Only runs when explicitly called

### **Event Binding ((click), (input))**

Event binding allows components to respond to user actions. The syntax uses parentheses around the event name, such as `(click)` or `(input)`. This binding connects a DOM event to a method in the component's TypeScript class.

```html
<button (click)="refreshList()">Refresh</button>
<button (click)="toggleFiltersCollapse()">Toggle Filters</button>
```

```ts
// In the component class
import { signal } from '@angular/core';

export class WorkOrderListComponent {
  filtersCollapsed = signal(false);

  refreshList(): void {
    this.loadWorkOrders(); // Reload data from service
  }

  toggleFiltersCollapse(): void {
    this.filtersCollapsed.update(collapsed => !collapsed);
  }

  clearFilters(): void {
    this.searchControl.setValue('');
    this.statusFilter.setValue('all');
    this.categoryFilter.setValue('all');
    this.sortControl.setValue('dateAdded');
  }
}
```

In our work order list template, we can see event binding being used extensively:

```html
<!-- Header Actions -->
<button 
  class="btn btn-info"
  type="button"
  (click)="refreshList()"
  [disabled]="isLoading()"
  aria-label="Refresh work order list">
  <span class="btn-icon">↻</span>
  Refresh
</button>

<!-- Toggle Filters -->
<button 
  class="collapse-button"
  type="button"
  (click)="toggleFiltersCollapse()"
  [attr.aria-expanded]="!filtersCollapsed()"
  aria-label="Toggle filters">
  <span class="collapse-icon" [class.collapsed]="filtersCollapsed()">▼</span>
</button>

<!-- Clear Filters -->
<button 
  class="btn btn-outline-danger"
  type="button"
  (click)="clearFilters()"
  aria-label="Clear all filters">
  Clear Filters
</button>
```

### **Computed Signals**

A computed signal is a read-only signal that derives its value from other signals. It automatically updates whenever any of its dependency signals change. Computed signals are both lazily evaluated (the calculation only runs when the value is requested) and memoized (the result is cached and only recalculated if a dependency changes), making them highly efficient.

```ts
// In the component class
workOrders = signal<WorkOrder[]>([]);
totalCount = signal(0);
pageSize = signal(10);

// Computed properties
totalPages = computed(() => Math.ceil(this.totalCount() / this.pageSize()));
startIndex = computed(() => (this.currentPage() - 1) * this.pageSize());
endIndex = computed(() => Math.min(this.startIndex() + this.pageSize(), this.totalCount()));
```

When `workOrders`, `totalCount`, or `pageSize` are updated, `totalPages`, `startIndex`, and `endIndex` will automatically reflect the new derived values without any extra code.

Looking at our `DashboardComponent`, we see extensive use of computed signals for statistics:

```ts
// src/app/features/dashboard/dashboard.component.ts
export class DashboardComponent implements OnInit {
  workOrders = signal<WorkOrder[]>([]);

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

  cancelledOrders = computed(() => 
    this.workOrders().filter(wo => wo.status.code === 'CNCLD').length
  );

  totalActiveWorkOrders = computed(() => 
    this.openOrders() + this.inProgressOrders()
  );

  completionRate = computed(() => {
    const total = this.totalOrders();
    if (total === 0) return 0;
    return Math.round((this.completedOrders() / total) * 100);
  });

  // Additional computed statistics
  overdueOrders = computed(() => {
    const now = new Date();
    const sevenDaysAgo = new Date(now.getTime() - (7 * 24 * 60 * 60 * 1000));
    
    return this.workOrders().filter(wo => {
      const requestDate = new Date(wo.dateRequested);
      const isOld = requestDate < sevenDaysAgo;
      const isNotCompleted = wo.status.code !== 'CMPLTD' && wo.status.code !== 'CNCLD';
      return isOld && isNotCompleted;
    }).length;
  });

  categoryBreakdown = computed(() => {
    const categories = new Map<string, number>();
    
    this.workOrders().forEach(wo => {
      const categoryName = wo.category.description;
      categories.set(categoryName, (categories.get(categoryName) || 0) + 1);
    });
    
    return Array.from(categories.entries())
      .map(([name, count]) => ({ name, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 5); // Top 5 categories
  });

  technicianEfficiency = computed(() => {
    const technicianStats = new Map<string, { completed: number; total: number; avgTime: number }>();
    
    this.workOrders().forEach(wo => {
      if (wo.maintenanceTechnician?.code) {
        const techCode = wo.maintenanceTechnician.code;
        const stats = technicianStats.get(techCode) || { completed: 0, total: 0, avgTime: 0 };
        
        stats.total++;
        if (wo.status.code === 'CMPLTD' && wo.appointmentCompleted) {
          stats.completed++;
          const requestDate = new Date(wo.dateRequested);
          const completionDate = new Date(wo.appointmentCompleted);
          const diffTime = completionDate.getTime() - requestDate.getTime();
          const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
          stats.avgTime += diffDays;
        }
        
        technicianStats.set(techCode, stats);
      }
    });
    
    return Array.from(technicianStats.entries())
      .map(([code, stats]) => ({
        code,
        name: `${code}`,
        completed: stats.completed,
        total: stats.total,
        completionRate: stats.total > 0 ? Math.round((stats.completed / stats.total) * 100) : 0,
        avgTime: stats.completed > 0 ? Math.round(stats.avgTime / stats.completed) : 0
      }))
      .filter(tech => tech.total >= 2) // Only show technicians with 2+ orders
      .sort((a, b) => b.completionRate - a.completionRate)
      .slice(0, 3); // Top 3 technicians
  });
}
```

### 🔍 **Detailed Code Breakdown: Computed Signals**

This dashboard component is a masterclass in computed signal patterns. Let's dissect each one:

**Simple Computed Signal:**

```ts
totalOrders = computed(() => this.workOrders().length);
```

**Breaking this down:**
- `computed()` - Function from `@angular/core` that creates derived state
- `() =>` - Arrow function (no parameters needed)
- `this.workOrders()` - **READS** the signal (establishes dependency)
- `.length` - JavaScript array property
- **Returns**: `Signal<number>` (read-only!)

**What happens internally:**
1. Angular tracks that this computed signal reads `workOrders`
2. When `workOrders` changes, Angular marks this computed as "dirty"
3. Next time someone reads `totalOrders()`, it recalculates
4. Result is cached until dependencies change
5. **Lazy evaluation**: Doesn't calculate until someone reads it

**Memoization example:**
```ts
// First read - calculates and caches
const total1 = this.totalOrders(); // Runs: this.workOrders().length

// Second read - returns cached value
const total2 = this.totalOrders(); // Returns cached result (no calculation!)

// workOrders changes
this.workOrders.set(newOrders);

// Next read - recalculates
const total3 = this.totalOrders(); // Runs: this.workOrders().length again
```

**Filtered Computed Signals:**

```ts
openOrders = computed(() => 
  this.workOrders().filter(wo => wo.status.code === 'OPN').length
);
```

**Step-by-step execution:**
1. `this.workOrders()` - Read array of work orders (dependency tracked)
2. `.filter()` - JavaScript array method (creates new array)
3. `wo =>` - Arrow function for each work order
4. `wo.status.code === 'OPN'` - Boolean test (keep if open)
5. `.length` - Count matching items
6. **Result**: Number of open work orders

**Performance consideration:**
```ts
// This runs the filter EVERY time the computed is read (if dirty)
// For 1000 work orders, iterates all 1000 items
// But it's ONLY recalculated when workOrders actually changes
```

**Chain of Computed Signals:**

```ts
totalActiveWorkOrders = computed(() => 
  this.openOrders() + this.inProgressOrders()
);
```

**THIS IS POWERFUL!** Let's trace the dependency graph:

```
workOrders (writable signal)
    ↓
    ├─→ openOrders (computed)
    │       ↓
    └─→ inProgressOrders (computed)
            ↓
        totalActiveWorkOrders (computed)
```

**Execution flow when `workOrders` changes:**
1. `workOrders.set()` is called
2. Angular marks `openOrders` and `inProgressOrders` as dirty
3. Angular marks `totalActiveWorkOrders` as dirty (depends on those two)
4. Template reads `totalActiveWorkOrders()`
5. Computed evaluates, which reads `openOrders()`
6. `openOrders()` recalculates (filters workOrders)
7. Then reads `inProgressOrders()`
8. `inProgressOrders()` recalculates (filters workOrders)
9. Adds them together
10. Returns result

**Efficiency note:**
- Each computed only recalculates if its DIRECT dependencies changed
- Results are cached
- Angular is smart about scheduling updates

**Computed Signal with Guard Clause:**

```ts
completionRate = computed(() => {
  const total = this.totalOrders();
  if (total === 0) return 0;  // Guard clause!
  return Math.round((this.completedOrders() / total) * 100);
});
```

**Why the guard clause?**
```ts
// ❌ Without guard:
completionRate = computed(() => 
  Math.round((this.completedOrders() / this.totalOrders()) * 100)
);
// If totalOrders() is 0, this is: Math.round(0 / 0 * 100) = NaN ⚠️

// ✅ With guard:
if (total === 0) return 0;  // Prevents division by zero!
```

**JavaScript division by zero:**
- `1 / 0` = `Infinity`
- `0 / 0` = `NaN` (Not a Number)
- `NaN` breaks UI: `{{ completionRate() }}%` shows "NaN%"

**Math.round() usage:**
```ts
Math.round(75.8)  // → 76
Math.round(75.4)  // → 75
Math.round(75.5)  // → 76
```

**Complex Computed Signal - Date Logic:**

```ts
overdueOrders = computed(() => {
  const now = new Date();
  const sevenDaysAgo = new Date(now.getTime() - (7 * 24 * 60 * 60 * 1000));
  
  return this.workOrders().filter(wo => {
    const requestDate = new Date(wo.dateRequested);
    const isOld = requestDate < sevenDaysAgo;
    const isNotCompleted = wo.status.code !== 'CMPLTD' && wo.status.code !== 'CNCLD';
    return isOld && isNotCompleted;
  }).length;
});
```

**Breaking down the date calculation:**

```ts
const now = new Date();  // Current timestamp: e.g., 2025-10-28T14:30:00
```

```ts
now.getTime()  // Milliseconds since 1970-01-01: 1730126400000
```

```ts
7 * 24 * 60 * 60 * 1000
// 7 days × 24 hours × 60 minutes × 60 seconds × 1000 milliseconds
// = 604,800,000 milliseconds
```

```ts
const sevenDaysAgo = new Date(now.getTime() - 604800000);
// Subtracts 7 days worth of milliseconds
// Result: Date object 7 days in the past
```

**Filter logic breakdown:**

```ts
const requestDate = new Date(wo.dateRequested);
// Convert string date to Date object for comparison
```

```ts
const isOld = requestDate < sevenDaysAgo;
// Date comparison: true if requested more than 7 days ago
```

```ts
const isNotCompleted = wo.status.code !== 'CMPLTD' && wo.status.code !== 'CNCLD';
// NOT completed AND NOT cancelled (still active)
```

```ts
return isOld && isNotCompleted;
// Keep if BOTH conditions are true
```

**Why break down the logic?**
- **Readability**: Clear variable names explain intent
- **Debuggable**: Can log each intermediate value
- **Maintainable**: Easy to adjust criteria (e.g., change to 14 days)

**Advanced Computed Signal - Data Aggregation:**

```ts
categoryBreakdown = computed(() => {
  const categories = new Map<string, number>();
  
  this.workOrders().forEach(wo => {
    const categoryName = wo.category.description;
    categories.set(categoryName, (categories.get(categoryName) || 0) + 1);
  });
  
  return Array.from(categories.entries())
    .map(([name, count]) => ({ name, count }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 5);
});
```

**Step-by-step execution:**

**Step 1: Create aggregation map**
```ts
const categories = new Map<string, number>();
// Map is perfect for counting: O(1) lookups, any key type
```

**Step 2: Count each category**
```ts
this.workOrders().forEach(wo => {
  const categoryName = wo.category.description;  // e.g., "Plumbing"
  categories.set(
    categoryName,
    (categories.get(categoryName) || 0) + 1
  );
});
```

**How the counting works:**
```ts
// First "Plumbing" order:
categories.get("Plumbing")  // undefined
(undefined || 0)            // 0
0 + 1                       // 1
categories.set("Plumbing", 1)

// Second "Plumbing" order:
categories.get("Plumbing")  // 1
(1 || 0)                    // 1
1 + 1                       // 2
categories.set("Plumbing", 2)
```

**Step 3: Convert Map to Array**
```ts
Array.from(categories.entries())
// Map.entries() returns iterator: [["Plumbing", 15], ["Electrical", 23], ...]
// Array.from() converts to array
```

**Step 4: Transform to objects**
```ts
.map(([name, count]) => ({ name, count }))
// Destructures each [key, value] pair
// Creates object: { name: "Plumbing", count: 15 }
```

**Step 5: Sort descending**
```ts
.sort((a, b) => b.count - a.count)
// If b.count > a.count: positive number → b comes first
// If a.count > b.count: negative number → a comes first
// Result: Highest counts first
```

**Step 6: Take top 5**
```ts
.slice(0, 5)
// Start at index 0, take 5 items
// If fewer than 5 items, returns all
```

**Expert Computed Signal - Complex Business Logic:**

```ts
technicianEfficiency = computed(() => {
  const technicianStats = new Map<string, { completed: number; total: number; avgTime: number }>();
  
  this.workOrders().forEach(wo => {
    if (wo.maintenanceTechnician?.code) {
      const techCode = wo.maintenanceTechnician.code;
      const stats = technicianStats.get(techCode) || { completed: 0, total: 0, avgTime: 0 };
      
      stats.total++;
      if (wo.status.code === 'CMPLTD' && wo.appointmentCompleted) {
        stats.completed++;
        const requestDate = new Date(wo.dateRequested);
        const completionDate = new Date(wo.appointmentCompleted);
        const diffTime = completionDate.getTime() - requestDate.getTime();
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        stats.avgTime += diffDays;
      }
      
      technicianStats.set(techCode, stats);
    }
  });
  
  return Array.from(technicianStats.entries())
    .map(([code, stats]) => ({
      code,
      name: `${code}`,
      completed: stats.completed,
      total: stats.total,
      completionRate: stats.total > 0 ? Math.round((stats.completed / stats.total) * 100) : 0,
      avgTime: stats.completed > 0 ? Math.round(stats.avgTime / stats.completed) : 0
    }))
    .filter(tech => tech.total >= 2)
    .sort((a, b) => b.completionRate - a.completionRate)
    .slice(0, 3);
});
```

**Complex type definition:**
```ts
Map<string, { completed: number; total: number; avgTime: number }>
//  ^^^^^^   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//  Key type  Value type (object with 3 properties)
```

**Optional chaining operator:**
```ts
if (wo.maintenanceTechnician?.code) {
//                           ^^ Safe navigation operator
// Returns undefined if maintenanceTechnician is null/undefined
// Prevents: "Cannot read property 'code' of undefined"
```

**Get or create pattern:**
```ts
const stats = technicianStats.get(techCode) || { completed: 0, total: 0, avgTime: 0 };
//            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//            Try to get existing                  Default if doesn't exist
```

**Accumulator pattern:**
```ts
stats.total++;        // Always increment total
if (completed) {
  stats.completed++;  // Only increment if completed
  stats.avgTime += diffDays;  // Accumulate time (will average later)
}
```

**Time difference calculation:**
```ts
const diffTime = completionDate.getTime() - requestDate.getTime();
// Difference in milliseconds

const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
// Convert milliseconds to days
// Math.ceil() rounds UP (1.1 days → 2 days)
```

**Why Math.ceil() instead of Math.round()?**
- **Business logic**: "Partial days count as full days"
- **User perception**: "2.1 days" feels closer to 3 than 2
- **Conservative**: Better to overestimate time than underestimate

**Complex transformation:**
```ts
.map(([code, stats]) => ({
  code,  // Shorthand for code: code
  name: `${code}`,  // Template literal
  completed: stats.completed,  // Direct mapping
  total: stats.total,
  completionRate: stats.total > 0 
    ? Math.round((stats.completed / stats.total) * 100) 
    : 0,  // Guard against division by zero
  avgTime: stats.completed > 0 
    ? Math.round(stats.avgTime / stats.completed) 
    : 0  // Average of accumulated times
}))
```

**Ternary operator breakdown:**
```ts
condition ? valueIfTrue : valueIfFalse
//        ^              ^
//        If truthy      If falsy
```

**Filter minimum threshold:**
```ts
.filter(tech => tech.total >= 2)
// Only show technicians with at least 2 work orders
// Prevents skewed statistics from single orders
```

**Final sort and slice:**
```ts
.sort((a, b) => b.completionRate - a.completionRate)  // Highest rate first
.slice(0, 3)  // Top 3 performers
```

**Why this is brilliant:**
1. **Single source of truth**: workOrders signal
2. **Automatic updates**: When workOrders changes, ALL stats recalculate
3. **Type-safe**: TypeScript ensures correct data structures
4. **Performant**: Only recalculates when necessary
5. **Declarative**: Describes WHAT to compute, not HOW to manage state
6. **Composable**: Can build complex dashboards from simple computed signals

In the dashboard template, these computed signals are automatically reactive:

```html
<!-- Summary Stats -->
<div class="stat-card stat-card--primary">
  <div class="stat-card__icon stat-card__icon--primary">📈</div>
  <div class="stat-card__content">
    <div class="stat-card__value">{{ totalOrders() }}</div>
    <div class="stat-card__label">Total Work Orders</div>
  </div>
</div>

<div class="stat-card stat-card--warning">
  <div class="stat-card__icon stat-card__icon--warning">🛠️</div>
  <div class="stat-card__content">
    <div class="stat-card__value">{{ totalActiveWorkOrders() }}</div>
    <div class="stat-card__label">Active Work Orders</div>
  </div>
</div>

<div class="stat-card stat-card--success">
  <div class="stat-card__icon stat-card__icon--success">✅</div>
  <div class="stat-card__content">
    <div class="stat-card__value">{{ completionRate() }}%</div>
    <div class="stat-card__label">Completion Rate</div>
  </div>
</div>
```

### **Parent → Child Communication with input()**

The modern, signal-based way to pass data from a parent component to a child is with the `input()` function. It is a direct and more reactive replacement for the traditional `@Input()` decorator. When you use `input()`, the property in the child component becomes a read-only signal (InputSignal) that always holds the latest value passed down from the parent.

**Child Component:**

```ts
// src/app/shared/components/status-badge/status-badge.component.ts
import { Component, input, computed, ChangeDetectionStrategy } from '@angular/core';
import { WorkOrderStatus } from '@shared/models';

@Component({
  selector: 'app-status-badge',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './status-badge.component.html',
  styleUrl: './status-badge.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class StatusBadgeComponent {
  // Creates a required signal input of type WorkOrderStatus | string
  status = input.required<WorkOrderStatus | string>();
  size = input<'sm' | 'md' | 'lg'>('md');

  badgeClass = computed(() => {
    const baseClass = 'badge';
    const statusClass = this.statusClass();
    const sizeClass = this.size() !== 'md' ? `badge--${this.size()}` : '';

    return [baseClass, statusClass, sizeClass].filter(Boolean).join(' ');
  });

  private readonly statusClass = computed(() => {
    const status = this.status();
    switch (status) {
      case WorkOrderStatus.OPEN:
      case 'OPEN':
      case 'OPN':
        return 'badge--status-open';
      case WorkOrderStatus.IN_PROGRESS:
      case 'IN_PROGRESS':
      case 'NPRGRS':
        return 'badge--status-in-progress';
      case WorkOrderStatus.COMPLETED:
      case 'COMPLETED':
      case 'CMPLTD':
        return 'badge--status-completed';
      case WorkOrderStatus.CANCELLED:
      case 'CANCELLED':
      case 'CNCLD':
        return 'badge--status-cancelled';
      default:
        return 'badge--status-open';
    }
  });

  statusText = computed(() => {
    const status = this.status();
    switch (status) {
      case WorkOrderStatus.OPEN:
      case 'OPEN':
      case 'OPN':
        return 'Open';
      case WorkOrderStatus.IN_PROGRESS:
      case 'IN_PROGRESS':
      case 'NPRGRS':
        return 'In Progress';
      case WorkOrderStatus.COMPLETED:
      case 'COMPLETED':
      case 'CMPLTD':
        return 'Completed';
      case WorkOrderStatus.CANCELLED:
      case 'CANCELLED':
      case 'CNCLD':
        return 'Cancelled';
      default:
        return 'Open';
    }
  });
}
```

**Parent Component Template:**

```html
<!-- In work-order-list.component.html -->
<app-status-badge
  [status]="workOrder.status.code"
  size="sm">
</app-status-badge>
```

This approach makes component inputs inherently reactive. Instead of using the `ngOnChanges` lifecycle hook to react to input changes, one can now use a computed signal or an effect that directly depends on the input signal, leading to cleaner and more declarative code.

Looking at `WorkOrderDetailComponent`, we see a complete example using `input.required()` with effects:

```ts
// src/app/features/work-orders/components/work-order-detail/work-order-detail.component.ts
export class WorkOrderDetailComponent extends BaseComponent {
  id = input.required<string>(); // Required input signal

  private readonly workOrderService = inject(WorkOrderService);
  private readonly router = inject(Router);

  workOrder = signal<WorkOrder | null>(null);

  constructor() {
    super();

    // Effect to load work order when id changes
    effect(() => {
      const workOrderId = this.id();
      if (workOrderId) {
        this.loadWorkOrder(workOrderId);
      } else {
        this.router.navigate(['/work-orders']);
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

### 🔍 **Detailed Code Breakdown: Signal Inputs and Effects**

This component demonstrates the power of modern Angular input signals combined with effects:

**Input Signal Declaration:**

```ts
id = input.required<string>();
```

**Breaking this down:**
- `input.required<string>()` - Creates a **required** input signal
- `<string>` - Type parameter: value must be a string
- `.required` - Compiler error if parent doesn't provide this input
- **Returns**: `InputSignal<string>` (read-only signal)

**Comparison with old @Input():**

```ts
// ❌ Old way (pre-v17):
@Input() id!: string;  // Not reactive, requires ngOnChanges

ngOnChanges(changes: SimpleChanges) {
  if (changes['id'] && changes['id'].currentValue) {
    this.loadWorkOrder(changes['id'].currentValue);
  }
}

// ✅ New way (v17+):
id = input.required<string>();  // Reactive, use effect instead

effect(() => {
  const workOrderId = this.id();
  this.loadWorkOrder(workOrderId);
});
```

**Benefits of input() over @Input():**
1. **Reactive by default**: Changes automatically propagate
2. **Type-safe**: Better TypeScript inference
3. **No lifecycle hooks needed**: Use effects or computed instead
4. **Composable**: Can use in computed signals directly
5. **Read-only**: Can't accidentally modify input value

**Service Injection:**

```ts
private readonly workOrderService = inject(WorkOrderService);
private readonly router = inject(Router);
```

**Pattern breakdown:**
- `private` - Only accessible within this component
- `readonly` - Cannot reassign (immutability principle)
- `inject()` - Modern DI function (no constructor injection needed)
- `WorkOrderService` - Type parameter for type safety

**Effect for Side Effects:**

```ts
effect(() => {
  const workOrderId = this.id();
  if (workOrderId) {
    this.loadWorkOrder(workOrderId);
  } else {
    this.router.navigate(['/work-orders']);
  }
});
```

**What is an effect?**
- Function that runs automatically when signals it reads change
- Used for **side effects** (API calls, navigation, logging, etc.)
- **NOT** for deriving state (use `computed()` for that)

**Effect execution flow:**

1. **First run**: Executes immediately when component initializes
2. **Reads signal**: `this.id()` establishes dependency
3. **Angular tracks**: "This effect depends on `id` signal"
4. **Signal changes**: Parent component changes `[id]` binding
5. **Effect re-runs**: Automatically executes again with new value

**Guard clause in effect:**

```ts
if (workOrderId) {
  this.loadWorkOrder(workOrderId);
} else {
  this.router.navigate(['/work-orders']);
}
```

**Why this guard?**
- **Defensive programming**: Handles empty/null/undefined
- **Navigation fallback**: If no ID, redirect to list
- **TypeScript narrowing**: After `if`, TypeScript knows `workOrderId` is truthy

**When effect runs:**

```
Component Created
    ↓
Constructor runs
    ↓
effect() registered
    ↓
Effect runs immediately
    ↓
Reads id() signal → "123"
    ↓
Calls loadWorkOrder("123")
    ↓
... user navigates to different work order ...
    ↓
Parent updates [id] binding → "456"
    ↓
id signal changes
    ↓
Effect runs again
    ↓
Calls loadWorkOrder("456")
```

**Async Method with Error Handling:**

```ts
private async loadWorkOrder(id: string): Promise<void> {
  const workOrder = await this.handleAsync(
    () => firstValueFrom(this.workOrderService.getWorkOrderById(parseInt(id))),
    'Failed to load work order'
  );

  if (workOrder) {
    this.workOrder.set(workOrder);
  }
}
```

**`async` keyword:**
- Allows using `await` inside function
- Function automatically returns `Promise`
- Makes async code look synchronous

**Type signature breakdown:**
```ts
private async loadWorkOrder(id: string): Promise<void>
//      ^^^^^                ^^^^^^^     ^^^^^^^^^^^^^^
//      Makes function async   Input     Output type (wrapped in Promise)
```

**`handleAsync()` wrapper:**
- Inherited from `BaseComponent`
- Handles loading state, error handling, logging
- **DRY principle**: Don't repeat error handling in every method

**`firstValueFrom()` operator:**
```ts
firstValueFrom(this.workOrderService.getWorkOrderById(parseInt(id)))
```

**What this does:**
1. `getWorkOrderById()` returns `Observable<WorkOrder>`
2. `firstValueFrom()` converts Observable to Promise
3. Takes first emitted value, then completes
4. `await` waits for Promise to resolve

**Why convert Observable to Promise?**
- **Simpler**: `await` is cleaner than `.subscribe()`
- **One value**: We only expect one work order, not a stream
- **Error handling**: Can use try/catch with async/await

**`parseInt(id)` conversion:**
```ts
parseInt(id)
//      ^^^ string from route parameter
// Converts "123" → 123 (number)
// API expects number, route provides string
```

**Null check pattern:**
```ts
if (workOrder) {
  this.workOrder.set(workOrder);
}
```

**Why check?**
- `handleAsync()` might return null/undefined on error
- **Defensive**: Don't set signal to invalid value
- **Type safety**: Prevents null reference errors

**Component inheritance:**
```ts
export class WorkOrderDetailComponent extends BaseComponent {
```

**What `extends` gives us:**
- Inherits all properties and methods from `BaseComponent`
- `handleAsync()` method for consistent async handling
- `destroyRef` for cleanup (used with `takeUntilDestroyed`)
- Shared loading/error state management
- **DRY principle**: Common patterns in one place

**Constructor pattern:**
```ts
constructor() {
  super();  // MUST call parent constructor first
  
  effect(() => { /* ... */ });  // Register effect
}
```

**`super()` explained:**
- Calls parent class (`BaseComponent`) constructor
- **Required**: Can't use `this` before calling `super()`
- Ensures parent class is properly initialized

**Effect vs Computed:**

```ts
// ❌ Can't use computed for side effects:
workOrder = computed(() => {
  const id = this.id();
  this.loadWorkOrder(id);  // ERROR: Can't make async calls!
  return null;  // Computed must return synchronously
});

// ✅ Use effect for side effects:
effect(() => {
  const id = this.id();
  this.loadWorkOrder(id);  // ✓ Async calls OK in effects
});
```

**Key differences:**

| Feature | Computed | Effect |
|---------|----------|--------|
| Returns value | ✅ Yes | ❌ No |
| Side effects | ❌ No | ✅ Yes |
| Async operations | ❌ No | ✅ Yes |
| Read from template | ✅ Yes | ❌ No |
| Auto cleanup | ✅ Yes | ✅ Yes |
| Memoized | ✅ Yes | ❌ No |

**Real-world usage example:**

```html
<!-- Parent component template -->
<app-work-order-detail [id]="selectedWorkOrderId" />

<!-- When selectedWorkOrderId changes: -->
<!-- 1. id signal updates -->
<!-- 2. Effect runs -->
<!-- 3. New work order loads -->
<!-- 4. UI updates automatically -->
```

**Why this pattern is powerful:**
1. **No manual cleanup**: Effect automatically disposes when component destroyed
2. **Reactive**: Input changes → effect runs → data loads → UI updates
3. **Type-safe**: Compiler ensures id is provided and correct type
4. **Testable**: Easy to mock services and test effect behavior
5. **Declarative**: Code describes WHAT to do, not HOW to manage state

### **Introduction to Services and Dependency Injection**

A **service** is a class designed to organize and share business logic, models, or data and functions with other parts of an application. It helps to keep components lean by abstracting away tasks like fetching data from a server or logging.

* **Creation:** Use the CLI: `ng generate service services/work-order`. This creates a class with an `@Injectable()` decorator.  
* **Providing the Service:** To make a service available throughout the application, it must be "provided." In a modern standalone application, this is done in `app.config.ts`. Services with `providedIn: 'root'` are automatically registered globally.

```ts
// src/app/services/work-order.service.ts
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { WorkOrder } from '@shared/models';
import { ApiService } from './api.service';

@Injectable({
  providedIn: 'root' // This registers the service globally
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
        return {
          success: true,
          data: workOrders,
          pagination: { /* ... */ },
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
      dateRequested: request.dateRequested
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

* **Injecting the Service:** To use a service within a component, you use dependency injection. The modern and recommended way is to use the `inject()` function.

```ts
// In a component class
import { inject } from '@angular/core';
import { WorkOrderService } from '@app/services/work-order.service';

export class WorkOrderListComponent implements OnInit {
  private readonly workOrderService = inject(WorkOrderService);
  private readonly lookupService = inject(LookupService);
  
  workOrders = signal<WorkOrder[]>([]);
  isLoading = signal<boolean>(true);

  private loadWorkOrders(): void {
    this.isLoading.set(true);

    this.workOrderService.getWorkOrders().pipe(
      takeUntilDestroyed(this.destroyRef)
    ).subscribe({
      next: (response: any) => {
        this.workOrders.set(response.data);
        this.isLoading.set(false);
      },
      error: (error) => {
        console.error('Failed to load work orders:', error);
        this.isLoading.set(false);
      }
    });
  }
}
```

## **Practical Exercise: Building the Work Order Dashboard**

Let's walk through creating a complete dashboard component that demonstrates all these concepts:

### Step 1: Create the Dashboard Component

```bash
ng g c features/dashboard --standalone
```

### Step 2: Component with Signals and Computed Properties

```ts
// src/app/features/dashboard/dashboard.component.ts
import { Component, OnInit, signal, computed, inject, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { WorkOrderService } from '@app/services/work-order.service';
import { WorkOrder, WorkOrderStatus } from '@shared/models';
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
  private readonly workOrderService = inject(WorkOrderService);

  ngOnInit(): void {
    this.loadDashboardData();
  }

  private loadDashboardData(): void {
    this.setLoading(true);
    this.workOrderService.getWorkOrders()
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: (response) => {
          this.workOrders.set(response.data);
          this.setLoading(false);
        },
        error: (error) => {
          console.error('Error loading dashboard data:', error);
          this.setLoading(false);
        }
      });
  }

  get welcomeMessage(): string {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning!';
    if (hour < 18) return 'Good afternoon!';
    return 'Good evening!';
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

  totalActiveWorkOrders = computed(() => 
    this.openOrders() + this.inProgressOrders()
  );

  completionRate = computed(() => {
    const total = this.totalOrders();
    if (total === 0) return 0;
    return Math.round((this.completedOrders() / total) * 100);
  });
}
```

### Step 3: Template with Event Binding and Computed Signals

```html
<!-- src/app/features/dashboard/dashboard.component.html -->
<div class="dashboard">
  <!-- Header Card -->
  <div class="header-card">
    <div class="header-content">
      <div class="header-text">
        <h1 class="page-title">{{ welcomeMessage }}</h1>
        <p class="page-subtitle">Here's a summary of the current maintenance status on campus.</p>
      </div>
      <div class="header-actions">
        <a routerLink="/work-orders/create" class="action-button action-button--primary">
          <div class="action-button__icon">+</div>
          <div class="action-button__content">
            <div class="action-button__title">Create New</div>
            <div class="action-button__subtitle">Work Order</div>
          </div>
        </a>
      </div>
    </div>
  </div>

  <!-- Loading State -->
  @if (isLoading()) {
    <div class="loading-container">
      <app-loading-spinner size="lg" message="Loading dashboard data..."></app-loading-spinner>
    </div>
  }

  <!-- Summary Stats Grid -->
  @if (!isLoading()) {
    <section class="stats-section">
      <h2 class="section-title">Overview</h2>
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-card__value">{{ totalOrders() }}</div>
          <div class="stat-card__label">Total Work Orders</div>
        </div>

        <div class="stat-card">
          <div class="stat-card__value">{{ totalActiveWorkOrders() }}</div>
          <div class="stat-card__label">Active Work Orders</div>
        </div>

        <div class="stat-card">
          <div class="stat-card__value">{{ completionRate() }}%</div>
          <div class="stat-card__label">Completion Rate</div>
        </div>
      </div>
    </section>
  }
</div>
```

This comprehensive example demonstrates:

1. **Signal Creation**: Using `signal()` for reactive state management
2. **Service Injection**: Using `inject()` for dependency injection
3. **Event Binding**: Responding to user interactions
4. **Computed Signals**: Deriving values from other signals
5. **Modern Control Flow**: Using `@if` for conditional rendering
6. **Service Pattern**: Encapsulating business logic in services
7. **RxJS Integration**: Using `takeUntilDestroyed()` for automatic subscription management
8. **OnPush Change Detection**: Optimizing performance with change detection strategy
