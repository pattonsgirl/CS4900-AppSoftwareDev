# Class 2 — File and Component Structure

## Setting the Stage: From Monolithic Pages to Component Architecture

In traditional web development, a webpage was often authored as a single HTML document with sprawling CSS stylesheets and global JavaScript scripts attached. As applications scaled in complexity, this monolithic model became fragile. Changing a CSS rule in one file would unintentionally break button styling across three other pages. Modifying a JavaScript function could crash unrelated widgets sharing the same global scope.

Modern front-end engineering solves this by breaking user interfaces down into encapsulated, self-contained building blocks called **components**. 

Each component represents a distinct slice of user experience, packaging its visual layout, styling, and business logic into a single cohesive unit. Angular components adhere strictly to this philosophy:
1. **Encapsulation**: Styles written for a component do not bleed into the rest of the application.
2. **Reusability**: A well-designed component can be instantiated multiple times across different screens.
3. **Composability**: Complex views are constructed by nesting simpler components inside larger parent containers.

## Core Principles: Separation of Concerns

Angular structures each component around three distinct responsibilities:

1. **Structure (HTML)**: Defines the semantic elements on the page, including headings, paragraphs, lists, tables, inputs, and buttons. HTML provides the structural skeleton and accessibility anchors.
2. **Presentation (SCSS)**: Governs visual aesthetics, typography, color palettes, responsive layouts, borders, and spacing. Component SCSS is scoped locally to avoid global style collisions.
3. **Behavior and State (TypeScript)**: Houses properties, data collections, event listeners, and business logic. TypeScript enforces static types so structural mistakes are caught during compilation rather than in the user's browser.

### What is HTML? What is CSS/SCSS? What is TypeScript?

- **HTML (HyperText Markup Language)**: The foundational markup standard for creating web content. It uses semantic tags (`<header>`, `<main>`, `<section>`, `<article>`, `<button>`) to convey meaning to browsers and assistive technologies.
- **CSS (Cascading Style Sheets) & SCSS (Sassy CSS)**: CSS describes how HTML elements are visually presented. SCSS is a preprocessor superset of CSS that compiles directly to standard CSS. It adds features like rule nesting, variables, and mixins, keeping large stylesheets modular and DRY.
- **TypeScript**: A strongly typed superset of JavaScript developed by Microsoft. TypeScript adds static type annotations, interfaces, and compile-time checks, transforming front-end development from fragile scripting into reliable software engineering.

## Modern Project Folder Architecture

The reference application `wsu-test` demonstrates a clean, scalable folder layout designed for enterprise Angular applications:

```
wsu-test/
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
│       ├── features/               # Screen-level feature modules
│       │   ├── dashboard/          # Metrics summary screen
│       │   ├── work-orders/        # Work orders list, detail, and form screens
│       │   └── labs/               # Supplemental educational topic labs
│       ├── shared/                 # Reusable cross-feature assets
│       │   ├── components/         # Reusable UI widgets (status-badge, loading-spinner)
│       │   ├── models/             # Domain TypeScript interfaces and types
│       │   └── utils/              # Helper utilities and state builders
│       └── services/               # Singleton domain services (work-order, lookup, api)
```

### Folder Responsibilities

- **`features/`**: Feature folders organized by business domain. Each subfolder represents a complete screen or user flow with its own components and child routes.
- **`shared/components/`**: Presentational building blocks used across multiple features. These widgets receive data from parents and emit user actions. They do not fetch data directly from HTTP backends.
- **`shared/models/`**: Central contracts and interfaces defining backend DTOs, domain models, and UI configurations.
- **`services/`**: Centralized data access and business logic services that communicate with APIs and maintain application state.

## The Component File Trio

In an Angular project, a component lives inside its own folder and consists of up to four files:

1. `*.component.ts`: The TypeScript class decorated with `@Component`. It stores properties, handles events, and manages local state.
2. `*.component.html`: The HTML template defining the DOM structure and rendering properties with interpolation and control flow blocks.
3. `*.component.scss`: Component-scoped stylesheet. Angular scopes these rules directly to the component template.
4. `*.component.spec.ts`: Unit test file executed with Jest.

## Section 1. Component Composition and the Imports Array

Modern Angular applications are standalone by default. When a parent component wants to render a child component in its template, it must explicitly declare that child in its `@Component` `imports` array.

### Step 1: Define the Child Component

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
  imports: [StatusBadgeComponent],
  templateUrl: './work-order-list.component.html',
  styleUrl: './work-order-list.component.scss'
})
export class WorkOrderListComponent {
  // In-memory mock list for Class 2
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

Checkpoint:
> "What happens if you use `<app-status-badge>` in your template without adding `StatusBadgeComponent` to `imports`?"
> The Angular compiler throws a template error stating that `app-status-badge` is not a known element.

## Section 2. Template Syntax and Data Binding

Angular connects TypeScript properties with HTML markup using declarative binding syntax:

### 1. Interpolation `{{ expression }}`
Interpolation evaluates an expression, converts the result to a string, and renders it into the text node:
```html
<h3>{{ order.title }}</h3>
<p>Total Items: {{ mockOrders.length }}</p>
<p>Expression: {{ 2 + 2 }}</p>
```

### 2. Property Binding `[property]="expression"`
Property binding evaluates the right-hand side as a TypeScript expression and binds the result to the DOM element property:
```html
<!-- Binds button disabled state -->
<button type="button" [disabled]="mockOrders.length === 0">Export Orders</button>

<!-- Dynamically binds element id -->
<div [id]="'order-card-' + order.id"></div>
```

### 3. Class and Style Binding
Conditionally applies CSS classes or inline style rules based on component state:
```html
<!-- Applies class 'is-urgent' if isUrgent evaluates to true -->
<div class="card" [class.is-urgent]="order.isUrgent"></div>

<!-- Sets inline style width dynamically -->
<div class="progress-bar" [style.width.%]="completionPercentage"></div>
```

## Section 3. Modern Built-In Control Flow

Modern Angular introduces native control flow blocks directly into the template engine. They eliminate structural directives like `*ngIf` and `*ngFor` and require zero module imports.

### Conditional Rendering with `@if`

`@if` evaluates a boolean expression and inserts or removes elements from the DOM:

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

The `@for` block renders a template repeatedly for each element in an iterable collection:

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
- **Without tracking**: Angular would destroy and recreate every DOM node in the list on any array modification, causing scroll jumps, lost input focus, and expensive browser layout recalculations.
- **With tracking**: Angular uses the unique identifier from the `track` expression (such as `order.id`) to reuse existing DOM elements, updating only the specific nodes that changed.
- **Golden rule**: Always track by a unique primary key (`track order.id`). Only track by index (`track $index`) if the collection is static and will never be sorted, filtered, or prepended.

#### Contextual Variables in `@for`

Inside an `@for` loop, Angular provides built-in contextual loop variables:
- `$index`: Zero-based index of the current item.
- `$count`: Total number of items in the collection.
- `$first`: Boolean indicating if this is the first item.
- `$last`: Boolean indicating if this is the last item.
- `$even`: Boolean indicating if the current index is even.
- `$odd`: Boolean indicating if the current index is odd.

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

Angular allows declaring reusable template variables directly inside HTML markup using `@let`:

```html
@let orderCount = mockOrders.length;
@let hasPending = orderCount > 0;

@if (hasPending) {
  <p>You have {{ orderCount }} active items to review.</p>
}
```

## Section 4. Live Demo in `wsu-test`

Open the running application at `http://localhost:4200/work-orders/list`.

1. Open `src/app/features/work-orders/components/work-order-list/work-order-list.component.html`.
2. Inspect the outer `@if` statement that chooses between loading, error, and table display.
3. Observe how `@for (order of workOrders(); track order.orderNumber)` loops through rows.
4. Locate the child component `<app-status-badge [status]="order.status.code" />` inside the row template.
5. Open `work-order-list.component.scss` and demonstrate scoped styling: rules written here do not affect the header or sidebar.
6. Narrow the browser window to verify responsive layout behavior with Flexbox and CSS Grid.

### Accessibility Checkpoints for Class 2

- Ensure headings follow a logical semantic order (`h1` -> `h2` -> `h3`).
- Navigation links must be `<a routerLink="...">`, not clickable `<div>` elements.
- Action controls must be `<button type="button">`, not clickable `<span>` elements.
- Never set `outline: none` in CSS without supplying an accessible `:focus-visible` alternative.

## Section 5. Transfer into Students Repo

The last 20 minutes of class are dedicated to students applying these patterns to **their own** application.

### Homework 2: HTML, CSS & Modern Templates

Students build on the repository verified in Homework 1:
1. **Generate a Component**: Use the CLI to generate a new standalone feature component (`ng g c components/item-list`).
2. **Display the Component**: Add the new component to the root template or route configuration so it renders on screen.
3. **Define Mock Data**: Create a TypeScript interface describing their domain entity and populate a mock array in the component class.
4. **Render with `@for`**: Loop over the mock collection using `@for` with a mandatory unique `track` expression.
5. **Add Conditional Logic**: Use `@if` and `@switch` to conditionally render details or badges based on item properties.
6. **Scoped Styles**: Write clean SCSS rules in the component stylesheet using Flexbox or Grid.
7. **Git Commit & Push**: Commit the changes with a clear message and push to GitHub.

## After Class (Ungraded Resources)

- `/labs/control-flow` (Lab 01): Interactive playground for `@if`, `@for`, `@switch`, and `@let`.
- `/labs/content-projection` (Lab 02): Building reusable shell components with multi-slot `<ng-content>`.
- `/labs/pipes` (Lab 03): Built-in formatting pipes (`DatePipe`, `CurrencyPipe`) and custom pure pipes.
