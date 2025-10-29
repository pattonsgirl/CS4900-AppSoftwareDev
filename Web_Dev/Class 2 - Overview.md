## **🧠 Class 2 — Behavior & State Management with Signals**

### **Goal**

Understand how to add dynamic functionality to components using event binding and manage application state reactively with Angular Signals using real examples from the WSU Work Order Management application. Introduce services for logic encapsulation and modern, signal-based component inputs.

### **Topics**

#### **What are Signals? The New Reactive Primitive**

Angular Signals are the new foundation for reactivity in the framework. A signal is a wrapper around a value that can notify interested consumers when that value changes. This system allows Angular to perform highly efficient, fine-grained updates to the UI. Instead of checking an entire component for changes, Angular knows exactly which parts of the DOM depend on a specific signal and updates only those parts when the signal's value is modified. This approach simplifies the mental model for developers: change a value, and the UI updates automatically, without the need to manually manage subscriptions or change detection cycles.

#### **Writable Signals**

A writable signal is a signal whose value can be changed directly.

**Creation:** Create signals using the `signal()` function from `@angular/core`, providing an initial value.

```ts
// In a component class
isLoading = signal(false);
workOrders = signal<WorkOrder[]>([]);
currentPage = signal(1);
```

**Reading:** Call signals like functions to read their value. This syntax is how Angular tracks dependencies.

```html
<p>The current count is: {{ isLoading() }}</p>

@if (isLoading()) {
  <app-loading-spinner />
}
```

**Updating:** Two primary methods for updating writable signals:

* **.set(newValue)**: Replaces the current value with a new one.
  ```ts
  this.isLoading.set(true);
  this.workOrders.set(response.data);
  ```

* **.update(updateFn)**: Computes a new value based on the current value. Safer for state transitions that depend on the previous state.
  ```ts
  this.currentPage.update(page => page + 1);
  this.filtersCollapsed.update(collapsed => !collapsed);
  ```

**Real-World Example from WSU Application:**

```ts
// WorkOrderListComponent
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
    this.isLoading.set(true); // Set loading state

    this.workOrderService.getWorkOrders().pipe(
      takeUntilDestroyed(this.destroyRef)
    ).subscribe({
      next: (response: any) => {
        this.workOrders.set(response.data); // Update data
        this.applyFilters();
        this.isLoading.set(false); // Clear loading state
      },
      error: (error) => {
        console.error('Failed to load work orders:', error);
        this.isLoading.set(false); // CRITICAL: Also clear on error!
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

**Key Patterns:**
- **Loading pattern**: Set `true` before async operation, `false` in both success and error handlers
- **Type safety**: Explicitly type signals with generics `signal<Type>(initialValue)`
- **Immutability**: For objects/arrays, create new references to trigger updates
- **Toggle pattern**: Use `.update()` for boolean toggles

#### **Event Binding ((click), (input))**

Event binding allows components to respond to user actions. The syntax uses parentheses around the event name, such as `(click)` or `(input)`. This binding connects a DOM event to a method in the component's TypeScript class.

**Real Examples from Work Order List:**

```html
<!-- Refresh Button -->
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

```ts
// Component methods
export class WorkOrderListComponent {
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

#### **Computed Signals**

A computed signal is a read-only signal that derives its value from other signals. It automatically updates whenever any of its dependency signals change. Computed signals are both lazily evaluated (the calculation only runs when the value is requested) and memoized (the result is cached and only recalculated if a dependency changes), making them highly efficient.

**Simple Examples:**

```ts
// Pagination calculations
workOrders = signal<WorkOrder[]>([]);
totalCount = signal(0);
pageSize = signal(10);
currentPage = signal(1);

totalPages = computed(() => Math.ceil(this.totalCount() / this.pageSize()));
startIndex = computed(() => (this.currentPage() - 1) * this.pageSize());
endIndex = computed(() => Math.min(this.startIndex() + this.pageSize(), this.totalCount()));
```

**Complex Examples from Dashboard Component:**

```ts
// DashboardComponent computed statistics
export class DashboardComponent implements OnInit {
  workOrders = signal<WorkOrder[]>([]);

  // Simple counts
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

  // Chained computed signals
  totalActiveWorkOrders = computed(() => 
    this.openOrders() + this.inProgressOrders()
  );

  // Computed with guard clause
  completionRate = computed(() => {
    const total = this.totalOrders();
    if (total === 0) return 0; // Prevents division by zero
    return Math.round((this.completedOrders() / total) * 100);
  });

  // Complex date logic
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

  // Data aggregation with Map
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

  // Complex business logic
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
      .filter(tech => tech.total >= 2) // Minimum threshold
      .sort((a, b) => b.completionRate - a.completionRate)
      .slice(0, 3); // Top 3 technicians
  });
}
```

**Template Usage:**

```html
<!-- Summary Stats -->
<div class="stat-card stat-card--primary">
  <div class="stat-card__value">{{ totalOrders() }}</div>
  <div class="stat-card__label">Total Work Orders</div>
</div>

<div class="stat-card stat-card--warning">
  <div class="stat-card__value">{{ totalActiveWorkOrders() }}</div>
  <div class="stat-card__label">Active Work Orders</div>
</div>

<div class="stat-card stat-card--success">
  <div class="stat-card__value">{{ completionRate() }}%</div>
  <div class="stat-card__label">Completion Rate</div>
</div>
```

**Key Patterns:**
- **Lazy evaluation**: Only calculates when value is read
- **Memoization**: Caches result until dependencies change
- **Chaining**: Computed signals can depend on other computed signals
- **Guard clauses**: Prevent errors (division by zero, null checks)
- **Data transformation**: Map, filter, sort, slice operations

#### **Parent → Child Communication with input()**

The modern, signal-based way to pass data from a parent component to a child is with the `input()` function. It is a direct and more reactive replacement for the traditional `@Input()` decorator. When you use `input()`, the property in the child component becomes a read-only signal (InputSignal) that always holds the latest value passed down from the parent.

**Child Component (StatusBadgeComponent):**

```ts
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
  // Required signal input
  status = input.required<WorkOrderStatus | string>();
  
  // Optional input with default
  size = input<'sm' | 'md' | 'lg'>('md');

  // Computed signals based on inputs
  badgeClass = computed(() => {
    const baseClass = 'badge';
    const statusClass = this.statusClass();
    const sizeClass = this.size() !== 'md' ? `badge--${this.size()}` : '';
    return [baseClass, statusClass, sizeClass].filter(Boolean).join(' ');
  });

  private readonly statusClass = computed(() => {
    const status = this.status();
    switch (status) {
      case 'OPN': return 'badge--status-open';
      case 'NPRGRS': return 'badge--status-in-progress';
      case 'CMPLTD': return 'badge--status-completed';
      case 'CNCLD': return 'badge--status-cancelled';
      default: return 'badge--status-open';
    }
  });

  statusText = computed(() => {
    const status = this.status();
    switch (status) {
      case 'OPN': return 'Open';
      case 'NPRGRS': return 'In Progress';
      case 'CMPLTD': return 'Completed';
      case 'CNCLD': return 'Cancelled';
      default: return 'Open';
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

**Using Effects with Input Signals (WorkOrderDetailComponent):**

```ts
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

**Benefits of input() over @Input():**
1. **Reactive by default**: Changes automatically propagate
2. **Type-safe**: Better TypeScript inference
3. **No lifecycle hooks needed**: Use effects or computed instead
4. **Composable**: Can use in computed signals directly
5. **Read-only**: Can't accidentally modify input value

**Effect vs Computed:**

| Feature | Computed | Effect |
|---------|----------|--------|
| Returns value | ✅ Yes | ❌ No |
| Side effects | ❌ No | ✅ Yes |
| Async operations | ❌ No | ✅ Yes |
| Read from template | ✅ Yes | ❌ No |
| Auto cleanup | ✅ Yes | ✅ Yes |
| Memoized | ✅ Yes | ❌ No |

#### **Introduction to Services and Dependency Injection**

A **service** is a class designed to organize and share business logic, models, or data and functions with other parts of an application. It helps to keep components lean by abstracting away tasks like fetching data from a server or logging.

**Creation:** Use the CLI:

```bash
ng generate service services/work-order
```

This creates a class with an `@Injectable()` decorator.

**Service Example (WorkOrderService):**

```ts
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { WorkOrder } from '@shared/models';
import { ApiService } from './api.service';

@Injectable({
  providedIn: 'root' // Registers service globally
})
export class WorkOrderService {
  constructor(private apiService: ApiService) {}

  /**
   * Get all work orders
   * Endpoint: GET /work_order
   */
  getWorkOrders(pagination?: PaginationParams): Observable<PaginatedResponse<WorkOrder>> {
    return this.apiService.get<BackendWorkOrderDto[]>('work_order').pipe(
      map(response => ({
        success: true,
        data: response.data,
        pagination: { /* ... */ },
        timestamp: new Date()
      })),
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

**Injecting the Service (Modern Pattern):**

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

**Key Service Patterns:**
- **`providedIn: 'root'`**: Singleton service available app-wide
- **Modern injection**: Use `inject()` function instead of constructor injection
- **RxJS operators**: Use `pipe()`, `map()`, `catchError()` for data transformation
- **Error handling**: Always include error handlers
- **Type safety**: Use TypeScript generics for API responses

#### **Practical Exercise: Building the Work Order Dashboard**

Comprehensive hands-on example demonstrating all concepts by creating a dashboard component.

**Step 1: Generate Component**

```bash
ng g c features/dashboard --standalone
```

**Step 2: Component with Signals and Computed Properties**

```ts
import { Component, OnInit, signal, computed, inject, ChangeDetectionStrategy } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { WorkOrderService } from '@app/services/work-order.service';

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

  // Computed statistics
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

**Step 3: Template with Signals**

```html
<div class="dashboard">
  <!-- Loading State -->
  @if (isLoading()) {
    <app-loading-spinner size="lg" message="Loading dashboard data..."></app-loading-spinner>
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

**Concepts Demonstrated:**
1. **Signal Creation**: Using `signal()` for reactive state management
2. **Service Injection**: Using `inject()` for dependency injection
3. **Event Binding**: Responding to user interactions
4. **Computed Signals**: Deriving values from other signals
5. **Modern Control Flow**: Using `@if` for conditional rendering
6. **Service Pattern**: Encapsulating business logic in services
7. **RxJS Integration**: Using `takeUntilDestroyed()` for automatic subscription management
8. **OnPush Change Detection**: Optimizing performance with change detection strategy
