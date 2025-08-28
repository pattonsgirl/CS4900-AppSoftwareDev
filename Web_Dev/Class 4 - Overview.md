## **🔁 Class 4 — Data Round Trip & Full-Stack Display**

### 

### **Goal**

Connect the frontend form, data service, and backend server to perform full CRUD (Create, Read, Update, Delete) operations. Understand how to manage and refresh application state after server-side changes.

### **Topics**

#### **Fetching Data on ngOnInit**

While `toSignal` automatically triggers the data fetch upon component initialization, it's important to understand the `ngOnInit` lifecycle hook. This hook is a method that Angular calls once, right after creating a component. It's a common place to perform initial data fetching or setup logic. With the `toSignal` pattern, this is handled implicitly, but the concept remains relevant for more complex setup scenarios.

#### **Displaying Data with @for**

As established in previous classes, the `@for` block is the modern way to render a list of items. When displaying data fetched from a server, the pattern is straightforward:

1. The service returns an Observable from an HttpClient call.  
2. The component converts this Observable to a signal using toSignal.  
3. The template binds to this signal with a `@for` loop, using track on a unique identifier from the data (e.g., `item.id`).

#### **Creating and Submitting Forms with Reactive Forms**

This class builds upon the introduction to Reactive Forms by integrating them with a backend service. The process involves creating a form model in the component, binding it to an HTML form, and handling the submission event.

**Form Model (Component):** Use `FormBuilder` to define the structure of the form, including initial values and validators.

```ts
import { FormBuilder, Validators } from '@angular/forms';

//...
private fb = inject(FormBuilder);
itemForm = this.fb.group({
  name: ['', Validators.required],
  description: ['']
});
```

**Form View (Template):** Bind the form model to the template using the `[formGroup]` and `formControlName` directives. The `(ngSubmit)` event on the `<form>` element is used to call a submission handler method in the component.

```html
<form [formGroup]="itemForm" (ngSubmit)="onSubmit()">
  <input formControlName="name" placeholder="Name">
  <input formControlName="description" placeholder="Description">
  <button type="submit" [disabled]="itemForm.invalid">Save</button>
</form>
```

#### **Posting Form Data and Refreshing State**

When the user submits the form, the `onSubmit` method is called. This method is responsible for taking the form's value and passing it to a service that will send it to the backend.

**Submission Handler (Component):**

```ts
onSubmit() {
  if (this.itemForm.valid) {
    const newItemData = this.itemForm.value;
    this.dataService.createItem(newItemData).subscribe(() => {
      // After successful creation, refresh the data
      this.refreshItemList();
    });
  }
}
```

**Create Method (Service):** The service encapsulates the HTTP POST logic.

```ts
// In DataService
createItem(itemData: any): Observable<any> {
  return this.http.post('https://api.example.com/items', itemData);
}
```

#### **Updating Local State After Server Changes**

After a create, update, or delete operation, the data on the server has changed, but the data in the frontend's state (our signal) is now stale. The simplest and most reliable way to synchronize the state for a beginner's course is to **re-fetch the entire list** from the server.

While more advanced state management libraries offer strategies for locally mutating the state (e.g., adding the new item to the array directly), a re-fetch guarantees that the UI reflects the true state of the database. This pattern is often implemented by having a private Subject in the service that can be triggered to re-fetch the data, and a public signal that components consume.

A simplified approach for this course:

1. The component calls the service method (e.g., createItem).  
2. The component subscribes to the returned Observable.  
3. In the subscribe callback (which runs upon success), the component calls another method (e.g., refreshList) that re-initializes the signal by calling the service's getItems() method again.

#### **Component-Driven Design for CRUD**

This session brings all the pieces together into a tangible application. A good pattern is to structure components around CRUD functionality:

**ListComponent:** Responsible for displaying the list of items (Read) and initiating Delete operations.

**FormComponent:** A reusable component for both creating new items (Create) and editing existing ones (Update). It can take an optional input() to pre-populate the form for editing.
