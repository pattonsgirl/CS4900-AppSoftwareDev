# Assignment 2 - Component Logic, Signals & Services

## Purpose / Objectives

> The purpose of this assignment is to manage state and user events using signals, pass data between components, and properly encapsulate shared logic in a service. The skills being reinforced are:
> -   Using writable signals and event binding (`(click)`, `(input)`) to create interactive UI.
> -   Creating a child component that accepts data via a modern signal `input()`.
> -   Refactoring component logic into an injectable service.

## Description

Perform the following tasks in your course **homework** repository.

1.  Generate a new service for your data model (e.g., `UserService`, `ProductService`).
2.  Move the signal that holds your array of data and the logic for adding a new item from your component into the new service.
3.  Provide the service to the application in `src/app/app.config.ts`.
4.  In your list component, inject the service and use its methods and signals to display and manage the list.
5.  In the list component's template, add an `<input type="text">` field and an "Add Item" `<button>`. Use event binding to update a signal as the user types and to call a method that adds the new item to the list via the service when the button is clicked.
6.  Generate a new standalone "detail" child component (e.g., `user-detail`).
7.  In the child component, create a required signal `input()` to accept an object from your data model. Its template should display properties from this object (e.g., `<h3>{{ item().name }}</h3>`).
8.  In your parent list component's `@for` loop, render the new child component for each item, passing the item object to the child's input.

## Deliverable(s)

Push your commits, including the new service file, new child component files, and updated parent component files, to your course **homework** repository.

# Rubric

Assignment score: X / 6 points

-   `[ ]` Data and related logic are refactored into a provided service.
-   `[ ]` Event binding is used to add new items to the list via the service.
-   `[ ]` A new child component is created with a signal `input()`.
-   `[ ]` The parent component renders the child component and correctly passes data.
-   `[ ]` The overall application state is managed correctly through the service.
-   `[ ]` Follows good styling practices and has a clear commit structure.

**Feedback:**
