# Homework 6 - Full CRUD Interaction

## Purpose / Objectives
> The purpose of this assignment is to connect a frontend form to a backend service to perform data mutations (Create, Read, and Update/Delete). The skills being reinforced are:
> * Building typed forms with `ReactiveFormsModule`.
> * Implementing service methods for HTTP mutation requests (`POST`, `PUT`, or `DELETE`).
> * Refreshing UI state after a successful data mutation on the server.

## Description

Make a branch off of your GROUP UI repository or off of `lastname-homework5` named `lastname-homework6`. Perform the following tasks on this branch.

> **Note on DELETE vs. Status Mutations**: Not all application domains support or make sense with hard deletion. For instance, maintenance work orders, medical logs, and financial transactions are often closed, cancelled, or archived rather than deleted. Discuss your API capabilities with the instructional team on handoff day. If your team's application does not implement a `DELETE` endpoint, you may fulfill the second mutation requirement using a `PUT` or `PATCH` operation (such as status updates or item edits).

### 1. READ: Verify Data Display
1. Ensure your main list component correctly fetches and displays items from the backend API as completed in Homework 5.

### 2. CREATE: Build Reactive Form
1. Generate a standalone form component and add `ReactiveFormsModule` to its `imports` array.
2. Use `FormBuilder` to create a `FormGroup` for your form, making at least one field required with `Validators.required`.
3. Build an HTML `<form>` and bind it to your `FormGroup`, including a submit button that is disabled when the form is invalid.
4. In your data service, create a method like `createItem(item)` that sends an HTTP `POST` request to your API.
5. Implement an `onSubmit()` method in the form component to call the service's `createItem()` method with the form value.

### 3. DELETE or UPDATE: Add Second Data Mutation
Depending on your application domain and the endpoints confirmed during handoff day:

- **Option A (DELETE)**: In your data service, create a method like `deleteItem(id)` that sends an HTTP `DELETE` request. In your list or detail component, add a "Delete" button that invokes this method with the item ID.
- **Option B (UPDATE / Status Change)**: If your domain does not support deletion, create an `updateItem(id, updatePayload)` method in your service sending an HTTP `PUT` or `PATCH` request (for example, updating an order status from "OPEN" to "IN_PROGRESS" or "CLOSED"). Add an action button or edit form that triggers this update.

### 4. Update UI State
1. After every successful Create, Update, or Delete operation, ensure the displayed list of items refreshes to reflect the latest server state (such as re-fetching the list or updating the signal collection).

### 5. git add, commit, and push
1. Push your commits, including the new form component files, updated service, and modified list/detail components, to your `lastname-homework6` branch in your GROUP UI repository.

# Rubric

Assignment score: X / 6 points

- `[ ]` (READ) Data is successfully fetched and displayed from the backend API.
- `[ ]` (CREATE) A reactive form validates user input and sends a `POST` request to create records.
- `[ ]` (DELETE or UPDATE) The UI executes a second mutation (`DELETE` request, or approved `PUT`/`PATCH` update if delete is not in domain) via the service.
- `[ ]` The UI list correctly refreshes after successful create and mutation operations.
- `[ ]` The data service includes typed methods for both mutations.
- `[ ]` Work is committed with clear messages and pushed to the designated branch.

**Feedback:**
