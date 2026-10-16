# Class 6 — Data Round Trip & Full-Stack Display

## Setting the Stage: The Complete Write Lifecycle

In Class 4, we connected the read path of our application: the browser requested data, the server queried the database, and the UI displayed the returned collection.

Today, we complete the full-stack circle by building the **write path**:
1. The user navigates to a routed create view.
2. The user enters data into a form.
3. The client validates user input in real time and provides immediate visual feedback.
4. On submit, the application serializes the form values into a typed JSON payload.
5. An HTTP `POST` request sends the payload to the backend API.
6. The server persists the new record to the database and returns a response.
7. The client updates application state and either navigates to the new record or refreshes the active list.

This complete interaction is the cornerstone of full-stack web applications.

## Master-Detail Navigation and Route Parameters

Enterprise applications organize data into master-detail flows. In `wsu-test`, our route table connects list, create, and detail views:

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

With `withComponentInputBinding()` enabled in `app.config.ts`, route parameters bind directly to component `input()` signals without requiring `ActivatedRoute` subscriptions:

```typescript
// src/app/features/work-orders/components/work-order-detail/work-order-detail.component.ts
import { Component, input } from '@angular/core';

@Component({ ... })
export class WorkOrderDetailComponent {
  // Automatically populated from the ':id' URL path segment
  readonly id = input.required<string>();
}
```

## Form Architectures: Reactive Forms vs. Signal Forms

Angular provides two primary approaches for handling user input:

1. **Reactive Forms (`FormGroup`, `FormControl`, `Validators`)**:
   - The established standard in Angular applications.
   - Provides explicit, programmatic control over validation, pristine/dirty tracking, and value serialization.
   - Recommended for complex data-entry screens with dynamic rules.
2. **Signal Forms**:
   - Modern signal-native form handling currently emerging in Angular.
   - Offers fine-grained reactive validation directly driven by signals (demonstrated in Lab 14).

**Teaching Guidance**: Teach the shared concepts first: form model, synchronous validation, submission states, and error presentation. Students use Reactive Forms in `wsu-test`, and may explore Signal Forms as an optional extension.

## Section 1. Building a Reactive Form with Validation

In `WorkOrderFormComponent`, a typed `FormGroup` models user input:

```typescript
// src/app/features/work-orders/components/work-order-form/work-order-form.component.ts
import { Component, inject, signal } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { WorkOrderService } from '../../../../services/work-order.service';

@Component({
  selector: 'app-work-order-form',
  imports: [ReactiveFormsModule],
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
      this.form.markAllAsTouched();
      return;
    }

    this.isSubmitting.set(true);
    this.errorMessage.set(null);

    const payload = this.form.value;

    this.workOrderService.createWorkOrder(payload).subscribe({
      next: (createdOrder) => {
        this.isSubmitting.set(false);
        // Navigate to the list or detail view on success
        this.router.navigate(['/work-orders', createdOrder.id]);
      },
      error: (err) => {
        this.isSubmitting.set(false);
        this.errorMessage.set('Failed to save work order. Please verify your inputs and try again.');
      }
    });
  }
}
```

## Section 2. Form Template and Accessible Validation Feedback

A clean form provides immediate, accessible validation feedback:

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
    <button type="button" (click)="router.navigate(['/work-orders'])">Cancel</button>
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

Checkpoint:
> "Why do we check `touched` before displaying field error messages?"
> Because if errors displayed immediately when the page loaded, the user would see red validation errors before they even had a chance to type.

## Section 3. Client Navigation Guards vs. Server Security

In `wsu-test`, `/work-orders/create` is protected by `canActivate: [demoAuthGuard]`:

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

### The Golden Rule of Route Guards

> **A route guard is a browser navigation check. It is NOT API security.**
> 
> Anyone with curl, Postman, or browser DevTools can issue an HTTP `POST` directly to `http://localhost:8080/mr-fixit-service/work_order`. 
> Route guards exist exclusively to enhance user experience by preventing users from navigating to screens they are not ready to use. 
> Real security must be enforced on the backend using Spring Security or token validation.

## Section 4. Live Demo in `wsu-test`

1. Navigate to `http://localhost:4200/work-orders/create`.
2. Inspect the form: note required fields and dropdown lookups.
3. Open DevTools Network tab.
4. Click **Submit** with an empty form:
   - Notice that no HTTP request leaves the browser because client validation blocks invalid submissions.
   - Notice the touched input fields highlight with validation error messages.
5. Fill in valid data and click **Submit**:
   - Observe the `POST` request in the Network tab.
   - Inspect the Request Payload JSON.
   - Observe the `201 Created` or `200 OK` response.
   - Verify that Angular automatically routes to the new record or updates the list.

## Section 5. Transfer into Students Repo

The last 20 minutes are dedicated to implementing Homework 5 in each student's project:

### Homework 5: Full CRUD Interaction

1. **Create View & Navigation**: Add a dedicated route for creating resources (such as `/items/create`) and wire up `<a routerLink="...">` from your list view.
2. **Reactive Form**: Build a typed `FormGroup` with at least two input fields, applying `Validators.required` and at least one secondary validation rule (minlength, pattern, or range).
3. **Validation Errors**: Display clear error messages next to controls when fields are invalid and touched.
4. **Service POST Method**: Implement a `POST` method in your data service that sends the form payload to your Spring Boot API.
5. **State Synchronization**: On successful submit, navigate back to the list view or detail view, and ensure the newly created item appears in the UI.
6. **Error Handling**: Display a visible server error banner on the page if the HTTP `POST` request fails.
7. **Scope Note**: Full CRUD update (`PUT`) and delete (`DELETE`) operations are optional stretch extensions if your backend API already supports them. Do not force PUT/DELETE against endpoints that do not exist.

## After Class (Ungraded Resources)

- `/labs/signal-forms` (Lab 14): Exploring modern Signal Forms alongside Reactive Forms.
- `/labs/form-validators` (Lab 15): Custom synchronous, cross-field, and asynchronous validators.
- `/labs/unsaved-changes` (Lab 16): Preventing accidental data loss using `canDeactivate` route guards.
- `/labs/role-guard` (Lab 17): Role-based client navigation guards.
