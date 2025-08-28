**# Assignment 4 - Full CRUD Interaction

## Purpose / Objectives

> The purpose of this assignment is to connect a frontend form to a backend service to perform a full set of data manipulations (Create, Read, Update, Delete). The skills being reinforced are:
> -   Building forms with `ReactiveFormsModule`.
> -   Implementing service methods for `POST`, `PUT`, and `DELETE` HTTP requests.
> -   Refreshing UI state after a successful data mutation on the server.

## Description

Perform the following tasks in your course **homework** repository.

1.  **READ**: Ensure your main list component correctly fetches and displays all items from the backend API as completed in the previous assignment.
2.  **CREATE**:
    -   Generate a new standalone "form" component and add `ReactiveFormsModule` to its `imports` array.
    -   Use `FormBuilder` to create a `FormGroup` for your form, making at least one field required with `Validators.required`.
    -   Build an HTML `<form>` and bind it to your `FormGroup`, including a submit button that is disabled when the form is invalid.
    -   In your data service, create a method `createItem(item)` that performs an HTTP `POST` request.
    -   Implement an `onSubmit()` method in the form component to call the service's `createItem()` method with the form's value.
3.  **DELETE**:
    -   In your data service, create a method `deleteItem(id)` that performs an HTTP `DELETE` request.
    -   In your list component, add a "Delete" button for each item that calls the service's `deleteItem(id)` method when clicked.
4.  **Update UI State**: After every successful Create, Update, or Delete operation, ensure the list of items is refreshed to show the latest data from the server. A simple way to achieve this is to re-trigger the initial `GET` request.
5.  **(Optional Stretch Goal) UPDATE**: In your service, create an `updateItem(item)` method (HTTP `PUT`). Modify your form component to accept an optional item ID from the route, populate the form using `.patchValue()`, and have `onSubmit()` call `updateItem()` instead of `createItem()` when editing.

## Deliverable(s)

Push your commits, including the new form component files and the updated service and list component files, to your course **homework** repository.

# Rubric

Assignment score: X / 6 points

-   `[ ]` (READ) Data is successfully fetched and displayed.
-   `[ ]` (CREATE) A reactive form can create and POST new items to the server.
-   `[ ]` (DELETE) UI includes functionality to delete items, which calls the service.
-   `[ ]` The UI list correctly refreshes after Create and Delete operations.
-   `[ ]` The data service is expanded with `POST` and `DELETE` HTTP methods.
-   `[ ]` Good commit structure based on the completion of CRUD components.

**Feedback:****
