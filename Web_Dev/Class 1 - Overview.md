## **🧱 Class 1 — Foundations: Standalone Components & Modern Templates**

### **Goal**

Understand the separation of concerns between structure (HTML), style (CSS), and behavior (TypeScript). Introduce Angular's modern, standalone component architecture and the new built-in control flow syntax.

### **Topics**

#### **What is HTML? What is CSS? What is JavaScript?**

* **HTML (HyperText Markup Language):** The standard language for creating the structure and content of web pages. It uses tags (e.g., `<p>`, `<div>`, `<h1>`) to define elements like paragraphs, containers, and headings.  
* **CSS (Cascading Style Sheets):** The language used to describe the presentation and styling of a document written in HTML. It controls colors, fonts, layout, and spacing.  
* **JavaScript (and TypeScript):** The programming language that enables interactive and dynamic behavior on web pages. **TypeScript** is a superset of JavaScript that adds static typing, which helps catch errors during development and improves code quality. Angular is written in TypeScript, which is then compiled into JavaScript to run in the browser.

#### **How Angular Uses .component.ts, .html, and .css Files**

Angular components encapsulate these three technologies into a cohesive, reusable unit.

* **.component.ts:** The TypeScript file contains the component's logic, data (properties), and behavior (methods). It is decorated with `@Component` to provide metadata to Angular.  
* **.component.html:** The HTML file defines the component's view, or template. It contains the structure that will be rendered to the DOM.  
* **.component.css:** The CSS file contains styles that are **scoped** specifically to that component's template. This means styles defined here will not leak out and affect other parts of the application, promoting modularity.

#### 

#### **The Role of Standalone Components**

In modern Angular (v17+), standalone components are the default and primary building block. A standalone component is a self-contained unit that manages its own dependencies without needing to be declared in an NgModule. This is achieved by setting standalone: true in the `@Component` decorator and using the imports array to specify any other components, directives, or pipes it uses in its template. This approach makes dependencies explicit and localized, which improves the ability of build tools to remove unused code (tree-shaking) and makes it easier to understand a component in isolation.

```ts
// src/app/some-list/some-list.component.ts
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common'; // Example import

@Component({
  selector: 'app-some-list',
  standalone: true,
  imports: [CommonModule], // Dependencies are declared here
  templateUrl: './some-list.component.html',
  styleUrl: './some-list.component.css'
})
export class SomeListComponent {
  // Component logic goes here
}
```

#### **Introducing Built-in Control Flow**

Since Angular v17, a new, more intuitive control flow syntax is available directly in templates. This syntax is more performant and does not require importing CommonModule for basic conditional and loop rendering.

* **`@if` / `@else if` / `@else`:** For conditional rendering. The syntax closely mirrors standard JavaScript, making it easy to learn.

```html
@if (isLoggedIn) {
  <p>Welcome back, user!</p>
} @else {
  <p>Please log in.</p>
}
```

**`@for` and the `track` Property:** For rendering lists of items. The `@for` block requires a track expression, which is a mandatory performance optimization. track tells Angular how to uniquely identify each item in the collection, allowing it to perform minimal DOM updates when the list changes (e.g., items are added, removed, or reordered). This enforcement of a performance best practice is a significant improvement over the old `*ngFor` directive, where the equivalent `trackBy` was optional and often overlooked by beginners.

```html
<ul>  @for (item of items; track item.id) {    <li>{{ item.name }}</li>  } @empty {    <li>No items available.</li>  }</ul>
```

The `@for` block also includes an optional `@empty` block to display content when the collection is empty, and provides helpful contextual variables like `$index`, `$first`, and `$last`.

* **`@switch` / `@case` / `@default`:** For scenarios with multiple conditions, `@switch` provides a clean alternative to a long chain of `@if` / `@else if` blocks.

```html
@switch (user.role) {  @case ('admin') { <admin-dashboard /> }  @case ('editor') { <editor-dashboard /> }  @default { <viewer-dashboard /> }}
```

The following table provides a clear comparison to help students navigate older documentation or codebases they may encounter.

| Concept | Modern Syntax (v17+) | Legacy Syntax (pre-v17) | Key Benefit of Modern Approach |
| :---- | :---- | :---- | :---- |
| Conditional Rendering | @if (condition) {... } | \<div \*ngIf="condition"\>...\</div\> | No CommonModule import needed; more intuitive JS-like syntax. |
| List Rendering | @for (item of items; track item.id) | \<li \*ngFor="let item of items"\> | Mandatory track for performance; built-in @empty block. |
| Dependency Management | imports: \[...\] on component | declarations/imports on NgModule | Explicit, localized dependencies per component; better tree-shaking. |
| Component Inputs | myInput \= input() | @Input() myInput | Reactive by nature (Signal-based); integrates with modern state management. |
