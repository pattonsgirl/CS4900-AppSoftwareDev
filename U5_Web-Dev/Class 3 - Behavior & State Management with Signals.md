# Class 3: Behavior & State Management with Signals

> **Reference Application Grounding**:
> All practical demonstrations and code samples in this session are grounded in the reference repository [Mr Fix It UI](https://github.com/WSU-kduncan/mr-fixit-ui).
> Specific reference files:
>
> - `src/app/services/work-order.service.ts` (shared signal store and computed metrics summary)
> - `src/app/features/dashboard/dashboard.component.ts` (consuming service signals and deriving dashboard statistics)
> - `src/app/shared/components/status-badge/status-badge.component.ts` (signal inputs with `input.required<string>()`)

## How Angular Tracks Changes

How does a frontend framework know when your data changes so it can update what the user sees? This process is called **change detection**. Angular has handled this in three distinct phases across its history:

1. **AngularJS (1.x) — Periodic Scans**: The framework periodically scanned every tracked variable in memory, comparing old values against new values in loops. Because every user click or keystroke triggered a scan of every watcher on the page, applications slowed down as views grew larger.
2. **Angular 2 through 15 — Event Interception (Zone.js)**: Angular switched to an internal library called **Zone.js**. Zone.js wrapped browser asynchronous APIs (such as `setTimeout`, HTTP responses, and DOM event listeners) to intercept when events completed. Whenever an asynchronous operation finished, Zone.js alerted Angular to re-evaluate the entire component tree from top to bottom. While automatic, checking full component trees introduced performance overhead and made tracking down unexpected render timings difficult.
3. **Modern Angular (16+) — Direct Reactivity (Signals)**: Instead of guessing or re-checking entire component trees, modern Angular introduces **Signals**. A signal is a direct reactive connection between a value and the specific place in the template that renders it. When a signal changes, Angular updates only the exact DOM node that depends on that value, avoiding unnecessary re-renders.

## Core Concepts: Angular Signals

A signal is a reactive wrapper around a value that notifies consumers when that value changes:

- **Predictable**: State transitions happen immediately and synchronously when updated.
- **Efficient**: Derived calculations only recompute when their source values change.
- **Targeted Updates**: Angular updates only the specific elements connected to the signal, rather than re-evaluating entire component trees.

### 1. Writable Signals

A writable signal holds mutable state that you read and update directly:

```typescript
import { signal } from '@angular/core';

// Declare a signal with an initial value
const count = signal(0);

// Read the value by calling the signal as a function
console.log(count()); // 0

// Replace the value with .set()
count.set(5);

// Update based on the current value with .update()
count.update(current => current + 1);
console.log(count()); // 6
```

#### Student Survival Pitfall: Direct Mutation

A common bug when working with arrays or objects in signals is mutating the existing reference:

```typescript
// Broken: Mutating the array does NOT notify Angular
this.workOrders().push(newOrder); 
// Angular will not detect this change, and the UI will not update.

// Correct: Always supply a new array reference with .update()
this.workOrders.update(orders => [...orders, newOrder]);
```

**Golden Rule**: Never mutate data inside a signal directly. Always use `.set(newValue)` or `.update(prev => ...)` to supply a new reference.

Checkpoint:

> "Why should you never write `this.items().push(newItem)` on an array signal?"  
> Mutating the existing array does not create a new reference, so Angular will not know to update the UI. Always use `.update()`.

### 2. Computed Signals (Derived State)

Computed signals derive their value from other signals. They are read-only, lazily evaluated, and cached:

```typescript
import { signal, computed } from '@angular/core';

const price = signal(100);
const taxRate = signal(0.08);

// Automatically recalculates whenever price or taxRate changes
const total = computed(() => price() * (1 + taxRate()));
```

**Why** `computed()` **matters:**

- **Caching**: If dependent signals have not changed, `computed()` returns the cached result without recalculating.
- **Performance**: In templates, binding to a `computed()` signal is much cleaner than binding to a class method (such as `{{ calculateTotal() }}`), which executes on every single change detection cycle.

### 3. Side Effects with `effect()`

An `effect()` runs side-effect logic whenever the signals it reads change. Use effects only for external system synchronization:

- Writing to `localStorage`.
- Logging analytics events.
- Interfacing with third-party charting libraries.

**Critical Rule**: Do not use `effect()` to update other signals. Use `computed()` instead to derive state. Setting signals inside an effect easily introduces infinite loops and runtime errors.

## Services and Dependency Injection

As applications grow, multiple components need access to the same business data. If each component managed its own independent copy of an array, changes made on one screen would never reflect on another.

**Separation of Concerns**:

- **Components** should be lightweight presentation layers responsible only for displaying UI and capturing user interactions.
- **Services** are singleton classes that encapsulate domain models, business operations, and shared state.

### Understanding Dependency Injection (DI)

Dependency Injection is an architectural pattern implementing **Inversion of Control**. Instead of a component instantiating its own dependencies using `new WorkOrderService()`, it declares its dependency requirements, and Angular provides the shared singleton instance.

#### Analogy: Ordering at a Restaurant

- **Without DI**: You enter a restaurant kitchen, hunt down ingredients, light the grill, and cook your own meal. You are tightly coupled to the kitchen layout.
- **With DI**: You sit at the table and tell the server what you need. The server delivers the prepared meal. You do not need to know how the kitchen is organized; you only interact with the contract.

## Section 1. Reactivity with Angular Signals in Mr Fix It UI

Open `src/app/features/dashboard/dashboard.component.ts` in `mr-fixit-ui`.

Observe how signals and computed values model business metrics:

```typescript
// src/app/features/dashboard/dashboard.component.ts
import { Component, computed, inject } from '@angular/core';
import { WorkOrderService } from '../../services/work-order.service';

@Component({
  selector: 'app-dashboard',
  imports: [],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss'
})
export class DashboardComponent {
  private readonly workOrderService = inject(WorkOrderService);

  // Read the shared signal store from the service
  readonly workOrders = this.workOrderService.workOrders;

  // Derive metrics dynamically using computed()
  readonly totalOrders = computed(() => this.workOrders().length);
  
  readonly openOrders = computed(() => 
    this.workOrders().filter(order => order.status.code === 'OPN').length
  );

  readonly completionRate = computed(() => {
    const total = this.totalOrders();
    if (total === 0) return 0;
    const completed = this.workOrders().filter(o => o.status.code === 'CMPLTD').length;
    return Math.round((completed / total) * 100);
  });
}
```

In the template, read these signals using function-call syntax:

```html
<!-- src/app/features/dashboard/dashboard.component.html -->
<div class="metrics-grid">
  <div class="metric-card">
    <h3>Total Orders</h3>
    <span class="value">{{ totalOrders() }}</span>
  </div>
  <div class="metric-card">
    <h3>Open Work Orders</h3>
    <span class="value">{{ openOrders() }}</span>
  </div>
  <div class="metric-card">
    <h3>Completion Rate</h3>
    <span class="value">{{ completionRate() }}%</span>
  </div>
</div>
```

#### Student Survival Pitfall: Forgetting Parentheses in Templates

In template interpolation, you must write `{{ totalOrders() }}` with parentheses. If you write `{{ totalOrders }}`, Angular will output the raw TypeScript function reference (`function() { ... }`) or throw a compilation error.

Checkpoint:

> "In a template, what happens if you write `{{ totalOrders }}` instead of `{{ totalOrders() }}`?"  
> You display the function reference itself rather than calling the signal to get its current value.

## Section 2. Event Binding and User Interaction

Event binding syntax `(event)="handler($event)"` sends user actions from the HTML DOM to TypeScript component methods:

```html
<button type="button" (click)="toggleFilters()">Toggle Filters</button>
<input type="text" (input)="onSearchInput($event)" placeholder="Search orders..." />
```

In the component class, event handlers update signals:

```typescript
filtersCollapsed = signal(false);

toggleFilters(): void {
  this.filtersCollapsed.update(collapsed => !collapsed);
}
```

## Section 3. Component Communication: Signal Inputs and Outputs

Components communicate across parent-child boundaries using reactive inputs and outputs.

### Signal Inputs: `input()` and `input.required()`

Modern Angular uses signal inputs instead of the legacy `@Input()` decorator:

```typescript
// src/app/shared/components/status-badge/status-badge.component.ts
import { Component, computed, input } from '@angular/core';

@Component({
  selector: 'app-status-badge',
  imports: [],
  template: `
    <span class="badge" [class]="badgeClass()">
      {{ label() }}
    </span>
  `,
  styleUrl: './status-badge.component.scss'
})
export class StatusBadgeComponent {
  // Required input signal passed by the parent
  readonly status = input.required<string>();

  // Optional input with default fallback
  readonly size = input<'sm' | 'md' | 'lg'>('md');

  // Computed state deriving styling from the input signal
  readonly label = computed(() => {
    switch (this.status()) {
      case 'OPN': return 'Open';
      case 'NPRGRS': return 'In Progress';
      case 'CMPLTD': return 'Completed';
      case 'CNCLD': return 'Cancelled';
      default: return 'Unknown';
    }
  });

  readonly badgeClass = computed(() => 
    `badge--${this.status().toLowerCase()} badge--${this.size()}`
  );
}
```

### Event Outputs: `output()`

The child emits events back up to the parent using `output()`:

```typescript
import { Component, output } from '@angular/core';

@Component({
  selector: 'app-item-row',
  imports: [],
  template: `
    <button type="button" (click)="selected.emit(itemId)">Select Item</button>
  `
})
export class ItemRowComponent {
  itemId = 101;
  readonly selected = output<number>();
}
```

Parent template listens to the output:

```html
<app-item-row (selected)="onItemSelected($event)" />
```

## Section 4. Centralized State with Injectable Services and `inject()`

In modern Angular, services declare `@Injectable({ providedIn: 'root' })` so a single application-wide singleton is shared across all components.

Here is the store pattern from `mr-fixit-ui` (`src/app/services/work-order.service.ts`):

```typescript
// src/app/services/work-order.service.ts
import { Injectable, signal, computed } from '@angular/core';
import { WorkOrder, WorkOrderSummary, WorkOrderStatusCode } from '@shared/models';

@Injectable({
  providedIn: 'root'
})
export class WorkOrderService {
  // Private writable signal holding source-of-truth state
  private readonly _workOrders = signal<WorkOrder[]>([
    {
      id: 1,
      orderNumber: 101,
      title: 'Fix broken lock in Dorm 102',
      status: { code: WorkOrderStatusCode.OPEN, label: 'Open' }
    } as WorkOrder
  ]);

  // Public read-only exposure
  readonly workOrders = this._workOrders.asReadonly();

  // Computed summary metrics
  readonly summary = computed<WorkOrderSummary>(() => {
    const orders = this._workOrders();
    return {
      totalOrders: orders.length,
      openOrders: orders.filter(o => o.status.code === WorkOrderStatusCode.OPEN).length,
      inProgressOrders: orders.filter(o => o.status.code === WorkOrderStatusCode.IN_PROGRESS).length,
      completedOrders: orders.filter(o => o.status.code === WorkOrderStatusCode.COMPLETED).length,
      cancelledOrders: 0,
      highPriorityOrders: 0,
      overdueOrders: 0
    };
  });

  addWorkOrder(newOrder: WorkOrder): void {
    this._workOrders.update(orders => [...orders, newOrder]);
  }
}
```

Components inject the service using `inject(ServiceName)`:

```typescript
import { Component, inject } from '@angular/core';
import { WorkOrderService } from '../../services/work-order.service';

@Component({ ... })
export class WorkOrderListComponent {
  private readonly workOrderService = inject(WorkOrderService);
  readonly orders = this.workOrderService.workOrders;
}
```

Checkpoint:

> "Why do we put shared data in an `@Injectable({ providedIn: 'root' })` service instead of storing it directly in a component?"  
> Services are application-wide singletons, so multiple components can share and update the same state without losing data when navigating.

### Routing Between Views

`src/app/app.routes.ts` maps URLs to component screens:

```typescript
export const routes: Routes = [
  { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
  { 
    path: 'dashboard', 
    loadComponent: () => import('./features/dashboard/dashboard.component').then(m => m.DashboardComponent)
  },
  { 
    path: 'work-orders', 
    loadComponent: () => import('./features/work-orders/components/work-order-list/work-order-list.component').then(m => m.WorkOrderListComponent)
  }
];
```

In templates, navigate using `<a routerLink="/dashboard">` rather than `href`. This triggers client-side route transitions without reloading the page.

## Section 5. Transfer into Students Repo

The last 20 minutes are for working with your team on Homework 3:

### Homework 3: Component Decomposition & Task Distribution

1. **Decompose Wireframes**: Review team wireframes from Unit 2 and identify all top-level feature containers and reusable presentational child components.
2. **Document Task Delegation**: Create `COMPONENT_PLAN.md` dividing component ownership across all 3 or 4 team members so work can proceed in parallel.
3. **Scaffold Component Shells**: Each member uses the Angular CLI to generate their assigned components in `features/` or `shared/components/`.
4. **Configure Base Routes**: Connect top-level feature components in `src/app/app.routes.ts` and test URL navigation.
5. **Git Commit & Push**: Commit work to `lastname-homework3` and submit a Pull Request for team review.
