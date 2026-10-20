# Class 2: File and Component Structure

> **Reference Application Grounding**:
> All practical demonstrations and code samples in this session are grounded in the reference repository [Mr Fix It UI](https://github.com/WSU-kduncan/mr-fixit-ui).
> Specific reference files:
>
> - `src/app/shared/components/status-badge/status-badge.component.ts` (reusable presentational component)
> - `src/app/features/work-orders/components/work-order-list/` (feature container demonstrating template control flow)
> - `src/app/shared/models/work-order.model.ts` (domain TypeScript contracts)

## Why Components? Breaking Down the Page

In Class 1, we introduced the three layers of the web: HTML for structure, CSS for presentation, and JavaScript/TypeScript for behavior.

If you build an entire web app in one or two monolithic HTML pages with a giant stylesheet, small changes quickly cause bugs. Changing a button rule on one page accidentally breaks layouts across three other screens.

Modern web engineering solves this by breaking the interface into **components**. A component is a self-contained building block that bundles its own HTML, SCSS, and TypeScript together:

1. **Scoped styling**: CSS written inside a component only applies to that component. It will not bleed into the rest of the application.
2. **Reusability**: You can drop the same component into multiple screens without duplicating code.
3. **Composability**: Large screens are built by snapping smaller, simpler components together.

## Where Files Live in the Project

The reference application `mr-fixit-ui` organizes files into clear folders:

```
mr-fixit-ui/
├── src/
│   ├── index.html                  # Top-level host HTML document
│   ├── main.ts                     # Application bootstrap entry point
│   ├── styles.scss                 # Global reset and shared layout utilities
│   └── app/
│       ├── app.ts                  # Root shell component class
│       ├── app.html                # Root shell template (<router-outlet />)
│       ├── app.scss                # Shell layout styles
│       ├── app.config.ts           # Application-level providers
│       ├── app.routes.ts           # Route definitions mapping URLs to components
│       ├── features/               # Screen-level feature folders
│       │   ├── dashboard/          # Metrics summary screen
│       │   └── work-orders/        # Work orders list, detail, and form screens
│       ├── shared/                 # Reusable cross-feature assets
│       │   ├── components/         # Reusable UI widgets (status-badge, loading-spinner)
│       │   ├── models/             # Domain TypeScript interfaces and types
│       │   └── utils/              # Helper utilities
│       └── services/               # Central data access and domain services
```

### Folder Responsibilities

- `features/`: Folders grouped by business domain. Each subfolder represents a complete screen or user flow (such as `dashboard` or `work-orders`).
- `shared/components/`: Reusable widgets used across multiple screens (such as `status-badge` or `loading-spinner`). These receive data from parent components and render it.
- `shared/models/`: TypeScript interfaces and types defining the shape of your data.
- `services/`: Services that communicate with your API and manage shared data (covered in Class 3 and Class 4).

## What Lives Inside a Component Folder

In Angular, each component typically has four files:

1. `*.component.ts`: The TypeScript class decorated with `@Component`. It holds data properties and methods.
2. `*.component.html`: The HTML template defining the structure.
3. `*.component.scss`: Component-scoped stylesheet.
4. `*.component.spec.ts`: Automated unit test file.

## Section 1. Component Composition and the Imports Array

Modern Angular applications are standalone. When a parent component renders a child component in its template, it must declare that child in its `@Component` `imports` array.

### Step 1: Define the Child Component

Here is `StatusBadgeComponent` from `mr-fixit-ui` (`src/app/shared/components/status-badge/status-badge.component.ts`):

```typescript
// src/app/shared/components/status-badge/status-badge.component.ts
import { Component, input } from '@angular/core';

@Component({
  selector: 'app-status-badge',
  imports: [],
  template: `
    <span class="badge" [class]="'badge--' + status().toLowerCase()">
      {{ status() }}
    </span>
  `,
  styles: [`
    .badge {
      display: inline-block;
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 12px;
      font-weight: 700;
      text-transform: uppercase;
    }
    .badge--opn { background: #e3f2fd; color: #0d47a1; }
    .badge--nprgrs { background: #fff3e0; color: #e65100; }
    .badge--cmpltd { background: #e8f5e9; color: #1b5e20; }
    .badge--cncld { background: #ffebee; color: #b71c1c; }
  `]
})
export class StatusBadgeComponent {
  readonly status = input.required<string>();
}
```

### Step 2: Import the Child in the Parent Component

```typescript
// src/app/features/work-orders/components/work-order-list/work-order-list.component.ts
import { Component } from '@angular/core';
import { StatusBadgeComponent } from '../../../../shared/components/status-badge/status-badge.component';

@Component({
  selector: 'app-work-order-list',
  imports: [StatusBadgeComponent], // Must be listed here
  templateUrl: './work-order-list.component.html',
  styleUrl: './work-order-list.component.scss'
})
export class WorkOrderListComponent {
  // In-memory mock list for practicing templates
  mockOrders = [
    { id: 101, title: 'Fix broken lock in Dorm 102', statusCode: 'OPN' },
    { id: 102, title: 'Replace HVAC air filters', statusCode: 'NPRGRS' },
    { id: 103, title: 'Repair leaking faucet in Lab 304', statusCode: 'CMPLTD' }
  ];
}
```

### Step 3: Render the Child Selector in the Parent Template

```html
<!-- src/app/features/work-orders/components/work-order-list/work-order-list.component.html -->
<section class="work-order-list">
  <h2>Assigned Work Orders</h2>

  <div class="cards-grid">
    @for (order of mockOrders; track order.id) {
      <article class="order-card">
        <header class="order-header">
          <span class="order-number">#{{ order.id }}</span>
          <app-status-badge [status]="order.statusCode" />
        </header>
        <p class="order-title">{{ order.title }}</p>
      </article>
    }
  </div>
</section>
```

#### Student Survival Pitfall: Missing Imports

If you use `<app-status-badge>` in your template without adding `StatusBadgeComponent` to the `imports: [...]` array of `@Component`, Angular will fail with:

```
NG8001: 'app-status-badge' is not a known element.
```

Whenever you see `'X' is not a known element`, immediately check the `imports` array in your `*.component.ts` file.

Checkpoint:

> "If the terminal prints `NG8001: 'app-status-badge' is not a known element`, what is missing?"  
> `StatusBadgeComponent` is not listed in the parent component's `imports` array.

## Section 2. Template Syntax and Data Binding

Angular connects TypeScript properties with HTML markup using declarative binding syntax:

### 1. Interpolation `{{ expression }}`

Interpolation evaluates a TypeScript expression, converts the result to text, and renders it into the page:

```html
<h3>{{ order.title }}</h3>
<p>Total Items: {{ mockOrders.length }}</p>
<p>Expression: {{ 2 + 2 }}</p>
```

### 2. Property Binding `[property]="expression"`

Property binding evaluates an expression and binds the result to a DOM element property:

```html
<!-- Binds button disabled state -->
<button type="button" [disabled]="mockOrders.length === 0">Export Orders</button>

<!-- Dynamically binds element id -->
<div [id]="'order-card-' + order.id"></div>
```

### 3. Class and Style Binding

Conditionally applies CSS classes or inline style rules based on component state:

```html
<!-- Applies class 'is-urgent' if isUrgent is true -->
<div class="card" [class.is-urgent]="order.isUrgent"></div>

<!-- Sets inline style width dynamically -->
<div class="progress-bar" [style.width.%]="completionPercentage"></div>
```

## Section 3. Modern Built-In Control Flow

Modern Angular introduces native control flow blocks directly into templates. They replace legacy directives like `*ngIf` and `*ngFor` and require zero imports.

### Conditional Rendering with `@if`

`@if` evaluates a condition and renders elements only when that condition is true:

```html
@if (mockOrders.length > 0) {
  <p>Displaying {{ mockOrders.length }} work orders.</p>
} @else if (isLoading) {
  <p>Loading work orders...</p>
} @else {
  <p>No work orders found.</p>
}
```

### Collections with `@for` and Mandatory `track`

The `@for` block renders a template repeatedly for each item in an array:

```html
<ul class="order-items">
  @for (order of mockOrders; track order.id) {
    <li class="item-row">
      <span class="id">#{{ order.id }}</span>
      <span class="title">{{ order.title }}</span>
    </li>
  } @empty {
    <li class="empty-row">No work orders recorded in the system.</li>
  }
</ul>
```

#### Why `track` is Mandatory

When an array updates, Angular needs to know which elements were added, removed, or moved:

- **Without tracking**: Angular would destroy and recreate every DOM element in the list on any array update, causing page flicker, lost scroll position, and unnecessary browser repaints.
- **With tracking**: Angular uses the unique identifier from `track` (such as `order.id`) to reuse existing DOM elements, updating only the specific nodes that changed.

Checkpoint:

> "Why does Angular require a `track` expression on every `@for` loop?"  
> So it can update or move individual DOM elements without re-rendering the entire list.

### Contextual Loop Variables

Inside an `@for` loop, Angular provides built-in variables:

- `$index`: Zero-based index of the current item.
- `$count`: Total number of items in the collection.
- `$first`: True if this is the first item.
- `$last`: True if this is the last item.
- `$even`: True if the current index is even.
- `$odd`: True if the current index is odd.

```html
@for (order of mockOrders; track order.id) {
  <div class="card" [class.card--even]="$even">
    <span>Item {{ $index + 1 }} of {{ $count }}: {{ order.title }}</span>
  </div>
}
```

### Multi-Branch Switching with `@switch`

`@switch` replaces chains of `@else if` when matching against discrete values:

```html
@switch (order.statusCode) {
  @case ('OPN') {
    <span class="badge badge--open">Open</span>
  }
  @case ('NPRGRS') {
    <span class="badge badge--progress">In Progress</span>
  }
  @case ('CMPLTD') {
    <span class="badge badge--complete">Completed</span>
  }
  @default {
    <span class="badge badge--unknown">Unknown Status</span>
  }
}
```

### Template Local Variables with `@let`

Angular allows declaring reusable template variables directly inside HTML using `@let`:

```html
@let orderCount = mockOrders.length;
@let hasPending = orderCount > 0;

@if (hasPending) {
  <p>You have {{ orderCount }} active items to review.</p>
}
```

## Section 4. Live Demo in Mr Fix It UI

Open the running application at `http://localhost:4200/work-orders/list`.

1. Open `src/app/features/work-orders/components/work-order-list/work-order-list.component.html`.
2. Inspect the outer `@if` statement that chooses between loading, error, and table display.
3. Observe how `@for (order of workOrders(); track order.orderNumber)` loops through rows.
4. Locate the child component `<app-status-badge [status]="order.status.code" />` inside the row template.
5. Open `work-order-list.component.scss` and verify scoped styling: rules written here do not affect the header or sidebar.
6. Narrow the browser window to verify responsive layout behavior with Flexbox or CSS Grid.

### Accessibility Checkpoints for Class 2

- Ensure headings follow a logical order (`h1` then `h2` then `h3`).
- Navigation links must be `<a routerLink="...">`, not clickable `<div>` elements.
- Buttons must be `<button type="button">`, not clickable `<span>` elements.
- Never set `outline: none` in CSS without providing an accessible `:focus-visible` alternative.

## Section 5. Transfer into Students Repo

The last 20 minutes of class are for students to apply these patterns to their own application.

### Homework 2: HTML, CSS & Modern Templates

Students build on the repository verified in Homework 1:

1. **Generate a Component**: Use the CLI to generate a new standalone feature component (`ng g c components/item-list`).
2. **Display the Component**: Add the new component to the root template or route configuration so it renders on screen.
3. **Define Mock Data**: Create a TypeScript interface describing their domain entity and populate a mock array in the component class.
4. **Render with** `@for`: Loop over the mock collection using `@for` with a mandatory unique `track` expression.
5. **Add Conditional Logic**: Use `@if` and `@switch` to conditionally render details or badges based on item properties.
6. **Scoped Styles**: Write clean SCSS rules in the component stylesheet using Flexbox or Grid.
7. **Git Commit & Push**: Commit the changes with a clear message and push to GitHub.
