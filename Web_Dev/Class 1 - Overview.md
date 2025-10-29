## **🧱 Class 1 — Foundations: Standalone Components & Modern Templates**

### **Goal**

Understand the separation of concerns between structure (HTML), style (SCSS), and behavior (TypeScript). Introduce Angular's modern, standalone component architecture, the new built-in control flow syntax, and build an interactive form using the WSU Work Order Management application.

### **Topics**

#### **What is HTML? What is CSS/SCSS? What is JavaScript?**

* **HTML (HyperText Markup Language):** The standard language for creating the structure and content of web pages. It uses tags (e.g., `<p>`, `<div>`, `<h1>`) to define elements like paragraphs, containers, and headings.

* **CSS/SCSS (Cascading Style Sheets / Sassy CSS):** The language used to describe the presentation and styling of HTML documents. SCSS is a preprocessor that extends CSS with features like variables, nesting, and mixins, making styling more efficient and maintainable. SCSS is a superset of CSS (all CSS is valid SCSS) and compiles into browser-readable CSS.

* **JavaScript (and TypeScript):** The programming language that enables interactive and dynamic behavior on web pages. **TypeScript** is a superset of JavaScript that adds static typing, which helps catch errors during development and improves code quality. Angular is written in TypeScript, which is then compiled into JavaScript to run in the browser.

#### **How Angular Uses .component.ts, .html, and .scss Files**

Angular components encapsulate these three technologies into a cohesive, reusable unit.

* **.component.ts:** The TypeScript file contains the component's logic, data (properties), and behavior (methods). It is decorated with `@Component` to provide metadata to Angular.
* **.component.html:** The HTML file defines the component's view, or template. It contains the structure that will be rendered to the DOM.
* **.component.scss:** The SCSS file contains styles that are **scoped** specifically to that component's template. This means styles defined here will not leak out and affect other parts of the application, promoting modularity.

#### **Live Coding: Creating and Using Your First Standalone Component**

Hands-on demonstration of creating a `WorkOrderCardComponent` using the Angular CLI:

```bash
ng generate component components/work-order-card --standalone
# or shorthand: ng g c components/work-order-card --standalone
```

**Key Steps:**
1. CLI generates component files with `standalone: true` automatically
2. Import the new component into parent component's TypeScript file
3. Add to parent's `imports` array in `@Component` decorator
4. Use component's selector in parent's template
5. Demonstrate modern `@if` directive (no imports needed!)

This exercise illustrates the core principle of standalone dependency management.

#### **The Role of Standalone Components**

In modern Angular (v17+), standalone components are the default and primary building block. A standalone component is a self-contained unit that manages its own dependencies without needing to be declared in an NgModule. This is achieved by setting `standalone: true` in the `@Component` decorator and using the `imports` array to specify any other components, directives, or pipes it uses in its template. This approach makes dependencies explicit and localized, which improves the ability of build tools to remove unused code (tree-shaking) and makes it easier to understand a component in isolation.

```ts
// Example standalone component
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-work-order-card',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './work-order-card.component.html',
  styleUrl: './work-order-card.component.scss'
})
export class WorkOrderCardComponent {
  // Component logic goes here
}
```

#### **Introducing Built-in Control Flow**

Since Angular v17, a new, more intuitive control flow syntax is available directly in templates. This syntax is more performant and does not require importing CommonModule for basic conditional and loop rendering.

**`@if` / `@else if` / `@else`**

For conditional rendering. The syntax closely mirrors standard JavaScript, making it easy to learn.

```html
@if (workOrder.status.code === 'OPN') {
  <p>This work order is open and ready for assignment</p>
} @else if (workOrder.status.code === 'NPRGRS') {
  <p>This work order is currently in progress</p>
} @else {
  <p>This work order has been completed or cancelled</p>
}
```

**`@for` and the `track` Property**

For rendering lists of items. The `@for` block requires a track expression, which is a mandatory performance optimization.

```html
<ul>
  @for (workOrder of workOrders; track workOrder.orderNumber) {
    <li>{{ workOrder.title }} - {{ workOrder.status.description }}</li>
  } @empty {
    <p>There are no work orders to display.</p>
  }
</ul>
```

The `@for` block also includes an optional `@empty` block to display content when the collection is empty, and provides helpful contextual variables like `$index`, `$first`, and `$last`.

**Why `track` is Mandatory and Critical:**

The `track` expression provides Angular with a unique identifier for each list item. When data changes, Angular uses this key to efficiently update the DOM:

- **Without tracking**: Any list change forces Angular to rebuild ALL DOM elements (expensive!)
- **With tracking**: Angular performs "diffing" to update only what changed (performant!)

**Best Practices:**
- **Dynamic collections**: Track by unique, stable property (e.g., `workOrder.orderNumber`)
- **Static collections**: Can use `track $index` (but avoid for dynamic lists)

Making `track` mandatory is Angular's opinionated philosophy in action—enforcing performance best practices by default.

**`@switch` / `@case` / `@default`**

For scenarios with multiple conditions, `@switch` provides a clean alternative to a long chain of `@if` / `@else if` blocks.

```html
@switch (workOrder.status.code) {
  @case ('OPN') { <app-open-status-badge /> }
  @case ('NPRGRS') { <app-in-progress-status-badge /> }
  @case ('CMPLTD') { <app-completed-status-badge /> }
  @case ('CNCLD') { <app-cancelled-status-badge /> }
  @default { <app-unknown-status-badge /> }
}
```

#### **The Four Types of Data Binding**

Data binding connects the component's TypeScript logic (model) with its HTML template (view):

**1. Interpolation `{{ data }}`**

One-way: component → template. Renders property values as text content.

```html
<h1>{{ workOrder.title }}</h1>
<p>Order Number: {{ workOrder.orderNumber }}</p>
```

**2. Property Binding `[property]="data"`**

One-way: component → template. Binds component property to element/component/directive property.

```html
<img [src]="workOrder.imageUrl" [alt]="workOrder.title">
<button [disabled]="!workOrder.canEdit">Edit Work Order</button>
<app-status-badge [status]="workOrder.status.code"></app-status-badge>
```

**3. Event Binding `(event)="handler()"`**

One-way: template → component. Responds to user actions by calling component methods.

```html
<button (click)="editWorkOrder(workOrder.orderNumber)">Edit</button>
<button (click)="deleteWorkOrder(workOrder.orderNumber)">Delete</button>
```

Special `$event` variable contains event information (e.g., `$event.target.value` for input events).

**4. Two-Way Binding `[(property)]="data"`**

Bidirectional: component ↔ template. "Banana in a box" syntax `[()]` creates continuous synchronization between view and component. Commonly used with forms via `ngModel` directive.

```html
<input [(ngModel)]="workOrder.title" placeholder="Work Order Title">
<textarea [(ngModel)]="workOrder.description" placeholder="Description"></textarea>
```

#### **Building an Interactive Work Order Management UI**

Comprehensive hands-on example demonstrating all concepts by building a `WorkOrderFormComponent`:

**Component Features:**
- Signal-based state management (`formData`, `categories`, `statuses`, `buildings`)
- Computed properties for validation (`isFormValid`)
- Modern dependency injection with `inject(WorkOrderService, LookupService)`
- Service integration for CRUD operations and dropdown data
- Two-way data binding with `[(ngModel)]` on all form fields
- Form submission handling with loading states
- Error handling and user feedback

**Template Techniques:**
- Form submission with `(ngSubmit)="onSubmit()"`
- Error message display using `@if` and `@for`
- Dropdown populations using `@for` with proper `track` expressions
- Conditional button text based on `isSubmitting()` state
- Dynamic `[disabled]` binding: `[disabled]="!isFormValid() || isSubmitting()"`
- Property binding on form controls (`[value]`, `[id]`, etc.)
- Accessibility with proper `<label for="">` associations

**Styling with SCSS:**
- Component-scoped styles (won't leak to other components)
- Responsive design with media queries for mobile
- Modern CSS Grid for form layout (`grid-template-columns: 1fr 1fr`)
- Flexbox for button groups
- Interactive states (`:hover`, `:focus`, `:disabled`)
- Smooth transitions for better UX

**Key Patterns Demonstrated:**
- Interface definition for type safety (`WorkOrderFormData`)
- Generic method with TypeScript constraints (`updateField<K extends keyof>`)
- Observable subscription with `next` and `error` handlers
- Immutable state updates with signal `.set()` and `.update()`
- Form reset after successful submission
- Preventing double-submission with `isSubmitting` flag

This comprehensive example ties together standalone components, signals, data binding, control flow, services, and styling into a complete, production-ready pattern used throughout the WSU Work Order Management application.

#### **Modern vs Legacy Syntax Comparison**

The following table helps navigate older documentation or codebases:

| Concept | Modern Syntax (v17+) | Legacy Syntax (pre-v17) | Key Benefit of Modern Approach |
| :---- | :---- | :---- | :---- |
| Conditional Rendering | `@if (condition) {... }` | `<div *ngIf="condition">...</div>` | No CommonModule import needed; more intuitive JS-like syntax. |
| List Rendering | `@for (item of items; track item.id)` | `<li *ngFor="let item of items">` | Mandatory track for performance; built-in @empty block. |
| Dependency Management | `imports: [...]` on component | `declarations/imports` on NgModule | Explicit, localized dependencies per component; better tree-shaking. |
| Component Inputs | `myInput = input()` | `@Input() myInput` | Reactive by nature (Signal-based); integrates with modern state management. |
