# Class 3 — Behavior & State Management with Signals

## Setting the Stage: The Evolution of Reactivity in Angular

To understand modern Angular state management, it helps to understand how change detection evolved across framework generations:

1. **AngularJS (1.x)**: Used dirty-checking cycles across a global `$scope` tree. Every user interaction triggered an evaluation of every watcher in the application. As views grew, performance deteriorated.
2. **Angular 2 through 15**: Relied on **Zone.js**, a library that monkey-patches browser asynchronous APIs (such as `setTimeout`, `fetch`, and click handlers). When an asynchronous event resolved, Zone.js alerted Angular to check every component tree from top to bottom. While effective, it added runtime overhead and made debugging change detection timing notoriously difficult.
3. **Modern Angular (16+)**: Introduced **Signals**, a fine-grained reactive primitive. Instead of guessing when to re-render entire components, Angular now knows the exact DOM nodes that depend on a specific value. When that signal changes, only the dependent DOM updates.

## Core Concepts: Angular Signals

A signal is a reactive wrapper around a value that notifies consumers when that value changes:

- **Predictable**: State transitions occur synchronously and explicitly.
- **Glitch-Free**: Computed dependencies resolve in topological order, avoiding intermediate inconsistent states.
- **Zoneless-Ready**: Signals enable Angular to run completely without Zone.js, yielding faster startup times and smaller bundles.

### 1. Writable Signals

A writable signal holds mutable state that you read and update directly:

```typescript
import { signal } from '@angular/core';

// Declare a signal with an initial value
const count = signal(0);

// Read the value by executing the signal as a function
console.log(count()); // 0

// Replace the value with .set()
count.set(5);

// Update based on the current value with .update()
count.update(current => current + 1);
console.log(count()); // 6
```

### 2. Computed Signals (Derived State)

Computed signals derive their value from other signals. They are read-only, lazily evaluated, and memoized:

```typescript
import { signal, computed } from '@angular/core';

const price = signal(100);
const taxRate = signal(0.08);

// Automatically recalculates whenever price or taxRate changes
const total = computed(() => price() * (1 + taxRate()));
```

**Why `computed()` matters:**
- **Memoization**: If dependent signals have not changed, `computed()` returns the cached result without recalculating.
- **Pure Expressions**: Keeps templates clean by replacing complex calculation methods with derived reactive state.

### 3. Side Effects with `effect()`

An `effect()` runs side-effect logic whenever the signals it reads change. Use effects only for external system synchronization:
- Writing to `localStorage`.
- Logging analytics events.
- Interfacing with third-party charting libraries.

**Rule**: Do not use `effect()` to update other signals. Use `computed()` instead to derive state.

## The "Why" of Services and Dependency Injection

As applications grow, multiple components need access to the same business data. If each component managed its own independent copy of an array, changes made on one screen would never reflect on another.

**Separation of Concerns**:
- **Components** should be lightweight presentation layers responsible only for displaying UI and capturing user interactions.
- **Services** are singleton classes that encapsulate domain models, business operations, and shared state.

### Understanding Dependency Injection (DI)

Dependency Injection is an architectural pattern implementing **Inversion of Control**. Instead of a component instantiating its own dependencies using `new WorkOrderService()`, it declares its dependency requirements, and Angular's Injector provides the singleton instance.

#### Analogy: Ordering at a Restaurant
- **Without DI**: You enter a restaurant kitchen, hunt down ingredients, light the grill, and cook your own meal. You are tightly coupled to the kitchen layout.
- **With DI**: You sit at the table and tell the waiter what you need. The waiter delivers the prepared meal. You do not need to know how the kitchen is organized; you only interact with the contract.

## Section 1. Reactivity with Angular Signals

Open `src/app/features/dashboard/dashboard.component.ts` in `wsu-test`.

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

Checkpoint:
> "Why do we read `totalOrders()` with parentheses in the template?"
> Because `totalOrders` is a signal function. Calling `totalOrders()` subscribes the template node to updates from that signal.

## Section 2. Event Binding and User Interaction

Event binding syntax `(event)="handler($event)"` sends user actions from the HTML DOM to TypeScript component methods:

```html
<button type="button" (click)="refreshList()">Refresh</button>
<input type="text" (input)="onSearchInput($event)" placeholder="Search orders..." />
```

In the component class, event handlers update signals:

```typescript
// Handling button click to toggle a filter
filtersCollapsed = signal(false);

toggleFilters(): void {
  this.filtersCollapsed.update(collapsed => !collapsed);
}
```

## Section 3. Component Communication: Signal Inputs and Outputs

Components communicate across parent-child boundaries using reactive inputs and outputs.

### Signal Inputs: `input()` and `input.required()`

Modern Angular replaces the `@Input()` decorator with signal inputs:

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

In modern Angular, services declare `@Injectable({ providedIn: 'root' })` so a single application-wide singleton is shared across all components:

```typescript
// src/app/services/work-order.service.ts
import { Injectable, signal } from '@angular/core';

export interface WorkOrder {
  id: number;
  title: string;
  statusCode: string;
}

@Injectable({
  providedIn: 'root'
})
export class WorkOrderService {
  // Private writable signal holding source-of-truth state
  private readonly _workOrders = signal<WorkOrder[]>([
    { id: 1, title: 'Fix broken lock', statusCode: 'OPN' },
    { id: 2, title: 'Replace HVAC filter', statusCode: 'NPRGRS' }
  ]);

  // Public read-only exposure
  readonly workOrders = this._workOrders.asReadonly();

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

The last 20 minutes are dedicated to implementing Homework 3 in each student's project:

### Homework 3: Component Logic, Signals & Services

1. **Create a Domain Service**: Generate a service (`ng g s services/item`) marked with `providedIn: 'root'`. Move the mock data array out of the component and into a writable signal in the service.
2. **Inject the Service**: In your list component, inject the service using `inject(ItemService)` and read the signal collection.
3. **Add Computed State**: Implement at least one `computed()` signal (such as filtered items count, completed percentage, or active summary).
4. **Build a Child Component**: Create a reusable presentational child component with `input()` or `input.required()` signals. Render it inside your list template.
5. **Add User Interaction**: Add a button or event listener that mutates signal state with `.update()`.
6. **Configure Navigation**: Add a second route in `app.routes.ts` and verify navigation with `routerLink`.

## After Class (Ungraded Resources)

- `/labs/parent-child` (Lab 04): Exploring `input()` down and `output()` up before two-way binding.
- `/labs/model-binding` (Lab 05): Two-way binding with `model()`.
- `/labs/linked-signal` (Lab 06): Managing dependent dropdown selections that reset automatically.
- `/labs/ui-state` (Lab 07): Modeling explicit `{ status: 'loading' | 'error' | 'success' }` discriminated unions.
- `/labs/rx-search` (Lab 08): Debounced search inputs bridging RxJS streams into signals.
- `/labs/signal-effects` (Lab 09): Synchronizing signal state to `localStorage` using `effect()`.
