# Class 6: Data Round Trip & Full-Stack Display

> **Reference Application Grounding**:
> All practical demonstrations and code samples in this session are grounded in the reference repository [Mr Fix It UI](https://github.com/WSU-kduncan/mr-fixit-ui):
> - `src/app/features/work-orders/components/work-order-form/` (complete reactive form with validation and submission)
> - `src/app/services/work-order.service.ts` (`createWorkOrder()` method delegating to `ApiService`)
> - `src/app/shared/guards/demo-auth.guard.ts` (functional navigation guard)

---

## The Write Lifecycle: From Form Input to Database Record

In Class 4, we connected the read path of our application: the browser requested data, Spring Boot queried the database, and the Angular template displayed the collection.

Today, we complete the full-stack circle by building the **write path**:

1. The user navigates to a creation screen.
2. The user inputs data into form fields.
3. The client validates input locally and gives immediate visual feedback.
4. On submit, the component serializes form controls into a typed payload.
5. An HTTP `POST` request transmits the payload to Spring Boot.
6. The backend validates and persists the new record in the database.
7. The client updates application state and redirects to the new record or refreshes the list.

Mastering this end-to-end loop turns static dashboards into full CRUD applications.

---

## Section 1: Master-Detail Navigation and Route Parameters

Real-world applications organize data into master-detail flows. In `mr-fixit-ui`, the route configuration connects list, creation, and detail views:

```typescript
// src/app/app.routes.ts
import { Routes } from '@angular/router';
import { demoAuthGuard } from './shared/guards/demo-auth.guard';

export const routes: Routes = [
  {
    path: 'work-orders',
    children: [
      { path: '', redirectTo: 'list', pathMatch: 'full' },
      { 
        path: 'list', 
        loadComponent: () => import('./features/work-orders/components/work-order-list/work-order-list.component')
          .then(m => m.WorkOrderListComponent) 
      },
      { 
        path: 'create', 
        canActivate: [demoAuthGuard], 
        loadComponent: () => import('./features/work-orders/components/work-order-form/work-order-form.component')
          .then(m => m.WorkOrderFormComponent) 
      },
      { 
        path: ':id', 
        loadComponent: () => import('./features/work-orders/components/work-order-detail/work-order-detail.component')
          .then(m => m.WorkOrderDetailComponent) 
      }
    ]
  }
];
```

### Route Parameter Input Binding

When `withComponentInputBinding()` is configured in `src/app/app.config.ts`, route parameters bind directly to component `input()` signals without needing manual `ActivatedRoute` subscriptions:

```typescript
// src/app/features/work-orders/components/work-order-detail/work-order-detail.component.ts
import { Component, input } from '@angular/core';

@Component({
  selector: 'app-work-order-detail',
  standalone: true,
  templateUrl: './work-order-detail.component.html'
})
export class WorkOrderDetailComponent {
  // Automatically populated from the ':id' URL path segment
  readonly id = input.required<string>();
}
```

---

## Section 2: Building a Reactive Form with Validation

Angular provides **Reactive Forms** (`FormGroup`, `FormControl`, `Validators`) for programmatic control over validation, touch tracking, and value serialization.

In `WorkOrderFormComponent`, a typed `FormGroup` models user input:

```typescript
// src/app/features/work-orders/components/work-order-form/work-order-form.component.ts
import { Component, inject, signal } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { WorkOrderService } from '../../../../services/work-order.service';

@Component({
  selector: 'app-work-order-form',
  standalone: true,
  imports: [ReactiveFormsModule], // Mandatory import for reactive forms
  templateUrl: './work-order-form.component.html',
  styleUrl: './work-order-form.component.scss'
})
export class WorkOrderFormComponent {
  private readonly fb = inject(FormBuilder);
  private readonly workOrderService = inject(WorkOrderService);
  private readonly router = inject(Router);

  readonly isSubmitting = signal(false);
  readonly errorMessage = signal<string | null>(null);

  readonly form: FormGroup = this.fb.group({
    title: ['', [Validators.required, Validators.minLength(5)]],
    description: ['', [Validators.required, Validators.maxLength(500)]],
    categoryId: ['', Validators.required],
    buildingId: ['', Validators.required]
  });

  onSubmit(): void {
    if (this.form.invalid || this.isSubmitting()) {
      // Reveal validation errors for untouched fields
      this.form.markAllAsTouched();
      return;
    }

    this.isSubmitting.set(true);
    this.errorMessage.set(null);

    const payload = this.form.value;

    this.workOrderService.createWorkOrder(payload).subscribe({
      next: (createdOrder) => {
        this.isSubmitting.set(false);
        this.router.navigate(['/work-orders', createdOrder.id]);
      },
      error: (err) => {
        this.isSubmitting.set(false);
        this.errorMessage.set('Failed to save work order. Please verify your inputs and try again.');
      }
    });
  }

  onCancel(): void {
    this.router.navigate(['/work-orders']);
  }
}
```

### Essential Form Mechanics

1. **Why we call `markAllAsTouched()`**: If a user immediately clicks the Submit button without clicking into any inputs, the form is invalid, but none of the controls have been touched yet. Calling `markAllAsTouched()` forces error messages to render so the user understands what needs fixing.
2. **Preventing Double Submissions**: Never leave the submit button clickable while an HTTP request is in progress. Managing an `isSubmitting = signal(false)` flag and binding `[disabled]="form.invalid || isSubmitting()"` prevents users from triggering duplicate POST requests.

---

## Section 3: Template Layout and Accessible Validation Feedback

A clean form gives immediate feedback without overwhelming the user:

```html
<!-- src/app/features/work-orders/components/work-order-form/work-order-form.component.html -->
<form [formGroup]="form" (ngSubmit)="onSubmit()" class="form-container">
  <h2>Create Work Order</h2>

  @if (errorMessage()) {
    <div class="alert alert--danger" role="alert">
      {{ errorMessage() }}
    </div>
  }

  <div class="form-field">
    <label for="title">Title *</label>
    <input 
      id="title" 
      type="text" 
      formControlName="title" 
      [class.has-error]="form.get('title')?.invalid && form.get('title')?.touched"
    />
    @if (form.get('title')?.hasError('required') && form.get('title')?.touched) {
      <span class="field-error" role="alert">Title is required.</span>
    }
    @if (form.get('title')?.hasError('minlength') && form.get('title')?.touched) {
      <span class="field-error" role="alert">Title must be at least 5 characters.</span>
    }
  </div>

  <div class="form-actions">
    <button type="button" (click)="onCancel()">Cancel</button>
    <button type="submit" [disabled]="form.invalid || isSubmitting()">
      @if (isSubmitting()) {
        Saving...
      } @else {
        Submit Work Order
      }
    </button>
  </div>
</form>
```

### Why We Check `touched` Before Showing Errors

Always guard error messages with `&& form.get('controlName')?.touched`. If you only check `control.invalid`, required fields will glow red the instant the page opens before the student has touched the keyboard. Checking `touched` keeps the initial screen clean until the user focuses and leaves the field.

---

### Checkpoint: Form State & Validation

> **Question**: Why does Angular track `touched` and `dirty` separately on form controls?
>
> **Answer**: `touched` becomes true when a control loses focus (blur), indicating the user visited it. `dirty` becomes true when the user actually changes the control's value. This lets you decide whether to show an error on blur or only after an edit.

---

## Section 4: Client Navigation Guards vs. Backend Security

In `mr-fixit-ui`, `/work-orders/create` is protected by `canActivate: [demoAuthGuard]`:

```typescript
// src/app/shared/guards/demo-auth.guard.ts
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { DemoAuthService } from '../../services/demo-auth.service';

export const demoAuthGuard: CanActivateFn = () => {
  const authService = inject(DemoAuthService);
  const router = inject(Router);

  if (authService.isSignedIn()) {
    return true;
  }

  // Redirect to dashboard with reason parameter if not authenticated
  return router.createUrlTree(['/dashboard'], { queryParams: { reason: 'auth-required' } });
};
```

### Client Guards vs. Backend Authorization

Keep this distinction clear:

- **Route Guards are UI navigation checks**: They prevent an unauthenticated user from stumbling into an incomplete or privileged view in the browser. They exist to provide a good user experience.
- **Route Guards are NOT API security**: Any client can bypass Angular completely and send an HTTP `POST` to `http://localhost:8080/api/work_orders` using curl or Postman.
- **Real security must live on the server**: Spring Security, JWT validation, and database access controls protect your data regardless of what the frontend does.

---

### Checkpoint: Security Boundaries

> **Question**: If an Angular route guard blocks an unauthorized user from viewing the create page, can that user still create a record in the database?
>
> **Answer**: Yes, if the Spring Boot API is not secured. A client guard only prevents browser navigation to that component; it does not protect the HTTP API endpoints.

---

## Section 5: Live Walkthrough in Mr Fix It UI

Let's observe this write path in action:

1. Navigate to `http://localhost:4200/work-orders/create`.
2. Inspect the form: identify the required fields and initial states.
3. Open the DevTools Network tab.
4. Click **Submit** while the form is empty:
   - Notice that no HTTP request leaves the browser because client validation halts the submit handler.
   - Notice that untouched fields now highlight with clear validation messages because `markAllAsTouched()` was called.
5. Enter valid data and click **Submit**:
   - Observe the `POST` request in the Network tab.
   - Inspect the request payload to see how the form values were serialized.
   - Observe the `201 Created` or `200 OK` response status.
   - Verify that Angular navigates to the new record and the updated list displays the new data.

---

## Section 6: In-Class Application: Homework 6

Use the remaining class time to implement Homework 6 in your team's project:

### Homework 6: Full CRUD Interaction

1. **Create View & Navigation**: Add a route for creating resources (e.g., `/items/create`) and add a navigation link from your list view.
2. **Reactive Form**: Build a typed `FormGroup` with at least two input fields. Apply `Validators.required` and at least one secondary rule (`minLength`, `maxLength`, or pattern).
3. **Validation Feedback**: Display inline error messages when fields are both invalid and touched.
4. **Service POST Method**: Implement a `POST` method in your data service that sends the form payload to your Spring Boot API.
5. **State Synchronization**: On successful submit, navigate back to the list view or detail view, and ensure the newly created item appears in the UI.
6. **Error Alert**: Display a visible server error banner on the page if the HTTP `POST` request fails.
7. **Scope Note on DELETE vs. Status Updates**: Not all applications make use of deletion. If your domain model does not support hard deletes (e.g., maintenance work orders, medical logs, or financial audit records), status changes or edits via `PUT`/`PATCH` satisfy the second mutation requirement. Confirm your endpoint support with the instructional team on handoff day.
