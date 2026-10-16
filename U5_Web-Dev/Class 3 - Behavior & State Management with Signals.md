# Class 3 — Behavior & State Management with Signals

> **Reference Application Grounding (`wsu-test`)**:
> All practical demonstrations and code samples in this session are grounded in `/Users/edjenkins/Documents/GitHub/WSU/2025/wsu-test`.
> Specific reference files:
> - `src/app/services/work-order.service.ts` (shared signal store and computed metrics summary)
> - `src/app/features/dashboard/dashboard.component.ts` (consuming service signals and deriving dashboard statistics)
> - `src/app/shared/components/status-badge/status-badge.component.ts` (signal inputs with `input.required<string>()`)

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

#### Student Survival Pitfall: The Direct Mutation Trap
A common beginner bug when working with arrays or objects in signals:
```typescript
// Broken: Direct mutation does NOT notify Angular!
this.workOrders().push(newOrder); 
// Angular will NOT detect this change, and the UI will NOT update!

// Correct: Always produce a new array reference with .update()
this.workOrders.update(orders => [...orders, newOrder]);
```
**Golden Rule**: Never mutate data inside a signal directly. Always use `.set(newValue)` or `.update(prev => ...)` to supply a new reference!

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
- **Performance**: In templates, binding to a `computed()` signal is vastly superior to binding to a class method (e.g. `{{ calculateTotal() }}`), which executes on every single change detection cycle.

### 3. Side Effects with `effect()`

An `effect()` runs side-effect logic whenever the signals it reads change. Use effects only for external system synchronization:
- Writing to `localStorage`.
- Logging analytics events.
- Interfacing with third-party charting libraries.

**Critical Rule**: Do not use `effect()` to update other signals. Use `computed()` instead to derive state. Setting signals inside an effect easily introduces infinite cycles and runtime errors.

> **Simpler Lab Reference in `wsu-test`**:
> Want to see `effect()` safely synchronize a note to `localStorage`? Open `http://localhost:4200/labs/signal-effects` (Lab 09) in `wsu-test` (`src/app/features/labs/signal-effects-lab/`).

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

## Section 1. Reactivity with Angular Signals in `wsu-test`

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

#### Student Survival Pitfall: Forgetting Parentheses in Templates
In template interpolation, you must write `{{ totalOrders() }}` with parentheses. If you write `{{ totalOrders }}`, Angular will output the raw TypeScript function reference (`function() { ... }`) or throw a compilation error.

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

> **Simpler Lab Reference in `wsu-test`**:
> Want to see how a debounced search input handles real-time user typing cleanly? Open `http://localhost:4200/labs/rx-search` (Lab 08) in `wsu-test` (`src/app/features/labs/rx-search-lab/`).

## Section 3. Component Communication: Signal Inputs and Outputs

Components communicate across parent-child boundaries using reactive inputs and outputs.

> **Simpler Lab Reference in `wsu-test`**:
> Want to see parent-child priority chips with `input()` down and `output()` up in an isolated sandbox? Open `http://localhost:4200/labs/parent-child` (Lab 04) in `wsu-test` (`src/app/features/labs/parent-child-lab/`).
> For two-way signal binding with `model()`, see `http://localhost:4200/labs/model-binding` (Lab 05).

### Signal Inputs: `input()` and `input.required()`

Modern Angular replaces the legacy `@Input()` decorator with signal inputs:

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

Here is the store pattern from `wsu-test` (`src/app/services/work-order.service.ts`):

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

> **Simpler Lab Reference in `wsu-test`**:
> Want to see how dependent state (like a room dropdown resetting when a building changes) works cleanly without manual event juggling? Open `http://localhost:4200/labs/linked-signal` (Lab 06) in `wsu-test` (`src/app/features/labs/linked-signal-lab/`).
> To see how to eliminate impossible UI states with a discriminated union `{ status: 'loading' | 'error' | 'success' }`, open `http://localhost:4200/labs/ui-state` (Lab 07).

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

## Lab References: Simpler Isolated Examples in `wsu-test`

In `wsu-test`, navigate to `http://localhost:4200/labs` to open the **Learning Studio** catalog.

- **Lab 04 — Parent and Child Communication (`/labs/parent-child`)**:
  - **Route**: `http://localhost:4200/labs/parent-child`
  - **Source Code**: `src/app/features/labs/parent-child-lab/`
  - **What it demonstrates**: Priority chips receiving values via `input()` and emitting updates back to the parent through `output()`.
  - **Why consult this lab**: The cleanest, simplest example of unidirectional component data flow without any service or HTTP code.

- **Lab 05 — `model()` Two-Way Binding (`/labs/model-binding`)**:
  - **Route**: `http://localhost:4200/labs/model-binding`
  - **Source Code**: `src/app/features/labs/model-binding-lab/`
  - **What it demonstrates**: Two-way signal binding between parent and child components using the `model()` API and `[(value)]` syntax.
  - **Why consult this lab**: Compare modern `model()` with separate `input()` / `output()` pairs.

- **Lab 06 — `linkedSignal` Dependent State (`/labs/linked-signal`)**:
  - **Route**: `http://localhost:4200/labs/linked-signal`
  - **Source Code**: `src/app/features/labs/linked-signal-lab/`
  - **What it demonstrates**: Building and room picker where the selected room automatically resets to a valid default when the selected building changes.
  - **Why consult this lab**: Solves the classic problem of stale child selections in dependent dropdowns.

- **Lab 07 — Discriminated UI State (`/labs/ui-state`)**:
  - **Route**: `http://localhost:4200/labs/ui-state`
  - **Source Code**: `src/app/features/labs/ui-state-lab/`
  - **What it demonstrates**: Modeling UI state as a single discriminated union signal `{ status: 'loading' | 'error' | 'success' }` handled via `@switch`.
  - **Why consult this lab**: Eliminates buggy combinations like `isLoading === true && hasError === true`.

- **Lab 08 — Debounced Search & RxJS Interop (`/labs/rx-search`)**:
  - **Route**: `http://localhost:4200/labs/rx-search`
  - **Source Code**: `src/app/features/labs/rx-search-lab/`
  - **What it demonstrates**: Real-time typeahead search comparing raw signal binding (which spams requests) with a debounced RxJS pipeline converted to a signal via `toSignal()`.
  - **Why consult this lab**: Shows how to bridge RxJS streams into signals for user typing inputs.

- **Lab 09 — `effect()` and `afterNextRender` (`/labs/signal-effects`)**:
  - **Route**: `http://localhost:4200/labs/signal-effects`
  - **Source Code**: `src/app/features/labs/signal-effects-lab/`
  - **What it demonstrates**: Using `effect()` safely to synchronize component state to browser `localStorage`.
  - **Why consult this lab**: Explains when `effect()` is appropriate and why it must not be used to compute dependent state.
