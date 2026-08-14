# Assignment 1 - HTML, CSS & Modern Templates

## Purpose / Objectives
> The purpose of this assignment is to practice the fundamentals of creating and extending a standalone Angular component. The skills being reinforced are:
> * Generating components with the Angular CLI.
> * Adding HTML structure and scoped SCSS styling.
> * Using the modern built-in `@for` and `@if` control flow syntax to render dynamic data.

## Description

Make sure you have cloned / pulled the latest changes from your GROUP UI repository - remember from homework 0 one team member should have initialized the angular project for this repository.

Make a **branch** off of your GROUP UI repository named `lastname-homework1`.  Perform the following tasks on this branch.

### 1. Generate New Component
1.  Use the Angular CLI to generate a new standalone component relevant to your project's theme (e.g., `user-list`, `product-card`).

> As a group, much like with the API section, determine if you would rather each work on a different component, all work on one or two members pair up on one to compare methods. The Web Dev series of homeworks will have you work up to making a full CRUD interaction - connect a frontend form to a backend service to perform a full set of data manipulations (Create, Read, Update, Delete).

### 2. Display the Component
1.  Add the new component's selector to an existing component's template (like `app.component.html`) to make it visible on the page.

### 3. Create Data Array
1.  In your new component's TypeScript file (`.ts`), create a property that holds an array of objects.
2.  Each object must have at least an `id` property and a `name` property.

### 4. Render Data with @for
1.  In the component's HTML file (`.html`), use a `@for` loop to iterate over your array and render a list item `<li>` for each object.
2.  You must use the mandatory `track` expression with each object's unique `id`.

### 5. Style the Component
1.  In the component's CSS file (`.css`), create a style class (e.g., adds a border or color) and apply it to the list items rendered by the `@for` loop.

### 6. Add Conditional Logic
1.  Use an `@if` block to display a message only when your data array has items in it.
2.  (Optional Stretch Goal) Add an `@empty` block to your `@for` loop that displays a message when the data array is empty.

### 7. git add, commit, and push
1.  Push your commits, including all files for the newly generated component (`.ts`, `.html`, `.css`) and any modified template files, to your `lastname-homework1` branch in your GROUP UI repository.

# Rubric

Assignment score: X / 5 points

- `[ ]` A new standalone component is generated and displayed in the application.
- `[ ]` A data array is correctly defined in the component's class.
- `[ ]` The `@for` loop is implemented correctly, including the mandatory `track` expression.
- `[ ]` Scoped CSS styling is applied to the component's template.
- `[ ]` An `@if` block is used to conditionally render content.

**Feedback:**
