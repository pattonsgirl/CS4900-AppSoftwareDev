# Assignment 2 - Component Logic, Signals & Services

## Purpose / Objectives
> The purpose of this assignment is to manage state and user events using signals, pass data between components, and properly encapsulate shared logic in a service. The skills being reinforced are:
> * Using writable signals and event binding (`(click)`, `(input)`) to create interactive UI.
> * Creating a child component that accepts data via a modern signal `input()`.
> * Refactoring component logic into an injectable service.

## Description

Determine an appropriate merging strategy among your teammates. Are you going to have all team members make a PR for approval after each homework - going the style of the API homeworks? 
Wait til the CRUD flow is complete? Decisions decisions...

Make a **branch** off of your GROUP UI repository OR off of `lastname-homework1` named `lastname-homework2`.  Perform the following tasks on this branch.

### 1. Refactor Logic to a Service
1.  Generate a new service for your data model (e.g., `UserService`, `ProductService`).
2.  Move the signal that holds your array of data and the logic for adding a new item from your component into the new service.
3.  Provide the service to the application in `src/app/app.config.ts`.

### 2. Update List Component with Service and Inputs
1.  In your list component, inject the service and use its methods and signals to display and manage the list.
2.  In the list component's template, add an `<input type="text">` field and an "Add Item" `<button>`.
3.  Use event binding to update a signal as the user types and to call a method that adds the new item to the list via the service when the button is clicked.

### 3. Create Child "Detail" Component
1.  Generate a new standalone "detail" child component (e.g., `user-detail`).
2.  In the child component, create a required signal `input()` to accept an object from your data model.
3.  Its template should display properties from this object (e.g., `<h3>{{ item().name }}</h3>`).

### 4. Integrate Child Component
1.  In your parent list component's `@for` loop, render the new child component for each item, passing the item object to the child's input.

### 5. git add, commit, and push
1.  Push your commits, including the new service file, new child component files, and updated parent component files, to your `lastname-homework2` branch in your GROUP UI repository.

# Rubric

Assignment score: X / 6 points

- `[ ]` Data and related logic are refactored into a provided service.
- `[ ]` Event binding is used to add new items to the list via the service.
- `[ ]` A new child component is created with a signal `input()`.
- `[ ]` The parent component renders the child component and correctly passes data.
- `[ ]` The overall application state is managed correctly through the service.
- `[ ]` Follows good styling practices and has a clear commit structure.

**Feedback:**
