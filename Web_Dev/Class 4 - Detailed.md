# **🔁 Class 4 — Data Round Trip & Full-Stack Display**

## **Goal**

Connect the frontend form, data service, and backend server to perform full CRUD (Create, Read, Update, Delete) operations using the WSU Work Order Management system. Understand how to manage and refresh application state after server-side changes.

## **Topics**

### **Fetching Data on ngOnInit**

While `toSignal` automatically triggers the data fetch upon component initialization, it's important to understand the `ngOnInit` lifecycle hook. This hook is a method that Angular calls once, right after creating a component. It's a common place to perform initial data fetching or setup logic. With the `toSignal` pattern, this is handled implicitly, but the concept remains relevant for more complex setup scenarios.

Looking at our `DashboardComponent`, we see the classic pattern:

```ts
// src/app/features/dashboard/dashboard.component.ts
export class DashboardComponent implements OnInit {
  workOrders = signal<WorkOrder[]>([]);
  isLoading = signal<boolean>(true);
  
  private readonly workOrderService = inject(WorkOrderService);

  ngOnInit(): void {
    this.loadDashboardData(); // Initial data fetch
  }

  private loadDashboardData(): void {
    this.isLoading.set(true);
    
    this.workOrderService.getWorkOrders()
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: (response) => {
          this.workOrders.set(response.data);
          this.isLoading.set(false);
        },
        error: (error) => {
          console.error('Error loading dashboard data:', error);
          this.isLoading.set(false);
        }
      });
  }
}
```

### 🔍 **Detailed Code Breakdown: ngOnInit Lifecycle Hook**

The `ngOnInit` lifecycle hook is fundamental to Angular component initialization. Let's understand it deeply:

**Component Lifecycle Sequence:**

```
1. Constructor
    ↓
2. Input properties set (@Input or input())
    ↓
3. ngOnInit() ← We are here
    ↓
4. Component fully initialized
    ↓
5. Change detection runs
    ↓
6. ngOnChanges (if inputs change)
    ↓
... component lifetime ...
    ↓
7. ngOnDestroy
```

**Why ngOnInit and not constructor?**

```ts
// ❌ Constructor - TOO EARLY for data fetching:
constructor() {
  // Component inputs NOT YET available
  // Child components NOT YET created
  // DOM NOT YET rendered
  // Should only initialize properties
  this.workOrderService = inject(WorkOrderService);
}

// ✅ ngOnInit - PERFECT for data fetching:
ngOnInit(): void {
  // Component inputs ARE available
  // Component IS fully initialized
  // Safe to start async operations
  this.loadDashboardData();
}
```

**The `implements OnInit` declaration:**

```ts
export class DashboardComponent implements OnInit {
//                            ^^^^^^^^^^^^^^^^
//                            TypeScript interface
```

**What `implements OnInit` does:**
- **Compile-time check**: Ensures you implement `ngOnInit()` method
- **Documentation**: Signals to other developers this component uses lifecycle hook
- **Type safety**: TypeScript error if you misspell `ngOnInit`

```ts
// ✅ Correct:
ngOnInit(): void { }

// ❌ Would cause TypeScript error:
ngOnInitt(): void { }  // Typo!
// Error: Class 'DashboardComponent' incorrectly implements interface 'OnInit'
```

**Method signature:**

```ts
ngOnInit(): void {
//        ^^^^^^
//        Returns nothing (void)
```

**Why `void` return type?**
- Angular doesn't use the return value
- Lifecycle hooks are **callbacks** (Angular calls them, you don't)
- **Side effects only**: Loading data, setting up timers, etc.

**Inside loadDashboardData():**

```ts
private loadDashboardData(): void {
  this.isLoading.set(true);  // Step 1: Set loading state
  
  this.workOrderService.getWorkOrders()  // Step 2: Call service
    .pipe(takeUntilDestroyed(this.destroyRef))  // Step 3: Auto-cleanup
    .subscribe({  // Step 4: Subscribe to Observable
      next: (response) => {  // Success handler
        this.workOrders.set(response.data);
        this.isLoading.set(false);
      },
      error: (error) => {  // Error handler
        console.error('Error loading dashboard data:', error);
        this.isLoading.set(false);
      }
    });
}
```

**Step 1: Set loading state FIRST**

```ts
this.isLoading.set(true);
```

**Why set loading before making request?**
1. **Immediate UI feedback**: User sees loading spinner instantly
2. **Prevent race conditions**: If user triggers multiple loads, each starts with loading = true
3. **Clear state**: Always know if operation is in progress
4. **UX best practice**: Never leave user wondering if something is happening

**Step 2: Call service method**

```ts
this.workOrderService.getWorkOrders()
```

**What this returns:**
- `Observable<PaginatedResponse<WorkOrder>>`
- **Cold Observable**: HTTP request NOT sent yet
- **Lazy**: Nothing happens until `.subscribe()` is called

**Step 3: Auto-cleanup with takeUntilDestroyed**

```ts
.pipe(takeUntilDestroyed(this.destroyRef))
```

**What is `destroyRef`?**
```ts
protected readonly destroyRef = inject(DestroyRef);
// DestroyRef is Angular 16+ way to know when component destroys
```

**What `takeUntilDestroyed()` does:**
- RxJS operator that automatically unsubscribes when component destroys
- **Prevents memory leaks**: Cancels HTTP request if component destroyed before response
- **Replaces ngOnDestroy cleanup**: No need to manually unsubscribe

**The memory leak problem it solves:**

```ts
// ❌ WITHOUT takeUntilDestroyed - MEMORY LEAK:
ngOnInit(): void {
  this.workOrderService.getWorkOrders().subscribe({
    next: (response) => {
      this.workOrders.set(response.data);  // Component might be destroyed!
    }
  });
  // If user navigates away before response:
  // - Subscription still active
  // - Memory not freed
  // - Might try to update destroyed component
}

// ✅ WITH takeUntilDestroyed - SAFE:
ngOnInit(): void {
  this.workOrderService.getWorkOrders()
    .pipe(takeUntilDestroyed(this.destroyRef))  // Auto-cancels on destroy
    .subscribe({
      next: (response) => {
        this.workOrders.set(response.data);  // Only if component still alive
      }
    });
}
```

**Step 4: Subscribe with handlers**

```ts
.subscribe({
  next: (response) => { /* success */ },
  error: (error) => { /* failure */ }
})
```

**Subscribe object breakdown:**

```ts
{
  next: (response) => { ... },    // Called when Observable emits value
  error: (error) => { ... },       // Called if Observable errors
  complete: () => { ... }          // Called when Observable completes (optional)
}
```

**The `next` handler:**

```ts
next: (response) => {
  this.workOrders.set(response.data);
  this.isLoading.set(false);
}
```

**Execution order:**
1. HTTP request succeeds
2. Response arrives: `{ success: true, data: [...], timestamp: ... }`
3. `next` callback fires with response
4. `response.data` extracts array of work orders
5. Signal updated → Change detection triggered → UI updates
6. Loading state cleared → Spinner disappears

**The `error` handler:**

```ts
error: (error) => {
  console.error('Error loading dashboard data:', error);
  this.isLoading.set(false);
}
```

**Critical: ALWAYS clear loading in error handler!**

```ts
// ❌ BAD - Loading spinner never goes away:
error: (error) => {
  console.error('Error:', error);
  // Forgot to set isLoading to false!
  // User sees spinning loader forever
}

// ✅ GOOD - Loading state always cleared:
error: (error) => {
  console.error('Error:', error);
  this.isLoading.set(false);  // User sees error, can retry
}
```

**Why this pattern is everywhere in Angular apps:**

```ts
// Template shows loading spinner:
@if (isLoading()) {
  <app-loading-spinner />
}

// When isLoading() is true:
// 1. Spinner shows
// 2. User knows something is happening
// 3. Can't interact with content (good UX)

// When isLoading() is false:
// 1. Spinner hides
// 2. Content shows (or error message)
// 3. User can interact
```

**Complete data flow:**

```
User navigates to dashboard
    ↓
Router creates DashboardComponent
    ↓
Constructor runs (inject services)
    ↓
Angular sets input properties
    ↓
ngOnInit() fires
    ↓
loadDashboardData() called
    ↓
isLoading.set(true) → Spinner shows
    ↓
HTTP GET /work_order sent
    ↓
... waiting for server ...
    ↓
Server responds with JSON
    ↓
next() callback fires
    ↓
workOrders.set([...]) → List updates
    ↓
isLoading.set(false) → Spinner hides
    ↓
Template re-renders with data
    ↓
User sees work order list
```

**Error flow:**

```
User navigates to dashboard
    ↓
ngOnInit() fires
    ↓
isLoading.set(true) → Spinner shows
    ↓
HTTP GET /work_order sent
    ↓
Server returns 500 error
    ↓
error() callback fires
    ↓
Error logged to console
    ↓
isLoading.set(false) → Spinner hides
    ↓
User sees error message (if you add error UI)
```

**Navigation away flow (why takeUntilDestroyed matters):**

```
User navigates to dashboard
    ↓
ngOnInit() fires
    ↓
HTTP GET /work_order sent
    ↓
... waiting for server (slow network) ...
    ↓
User clicks "back" button (impatient!)
    ↓
Component destroys
    ↓
DestroyRef emits
    ↓
takeUntilDestroyed() sees emit → Unsubscribes
    ↓
HTTP response arrives but is IGNORED
    ↓
No memory leak, no errors
```

### **Displaying Data with @for**

As established in previous classes, the `@for` block is the modern way to render a list of items. When displaying data fetched from a server, the pattern is straightforward:

1. The service returns an Observable from an HttpClient call.  
2. The component converts this Observable to a signal using `toSignal` or subscribes and updates a signal.  
3. The template binds to this signal with a `@for` loop, using `track` on a unique identifier from the data (e.g., `workOrder.orderNumber`).

```html
<!-- src/app/features/work-orders/components/work-order-list/work-order-list.component.html -->
<div class="work-orders-grid">
  @for (workOrder of filteredWorkOrders(); track trackByWorkOrderId($index, workOrder)) {
    <div class="work-order-card">
      <!-- Card Header -->
      <div class="work-order-header">
        <div class="work-order-title-section">
          <a 
            [routerLink]="['/work-orders', workOrder.orderNumber]"
            class="work-order-title">
            {{ workOrder.title }}
          </a>
          <div class="work-order-id">#{{ workOrder.orderNumber }}</div>
        </div>
        <div class="work-order-status">
          <app-status-badge
            [status]="workOrder.status.code"
            size="sm">
          </app-status-badge>
        </div>
      </div>
      
      <!-- Card Content -->
      <div class="work-order-content">
        <div class="detail-row">
          <span class="detail-label">Category:</span>
          <span class="detail-value">{{ workOrder.category.description }}</span>
        </div>
        
        <div class="detail-row">
          <span class="detail-label">Location:</span>
          <div class="location-content">
            <div class="building-name">Building {{ workOrder.room.id.buildingId }}</div>
            <div class="room-number">Room {{ workOrder.room.id.roomNumber }}</div>
          </div>
        </div>
      </div>
    </div>
  }
</div>
```

In the component, we provide the tracking function:

```ts
trackByWorkOrderId(index: number, workOrder: WorkOrder): number {
  return workOrder.orderNumber;
}
```

### **Creating and Submitting Forms with Reactive Forms**

This class builds upon the introduction to Reactive Forms by integrating them with a backend service. The process involves creating a form model in the component, binding it to an HTML form, and handling the submission event.

**Form Model (Component):** Use `FormBuilder` to define the structure of the form, including initial values and validators.

```ts
// src/app/features/work-orders/components/work-order-form/work-order-form.component.ts
export class WorkOrderFormComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly workOrderService = inject(WorkOrderService);
  private readonly router = inject(Router);

  workOrderForm: FormGroup;
  isSubmitting = signal<boolean>(false);
  errorMessage = signal<string>('');
  successMessage = signal<string>('');

  constructor() {
    this.workOrderForm = this.createForm();
  }

  private createForm(): FormGroup {
    return this.fb.group({
      title: ['', [Validators.required, Validators.minLength(5), Validators.maxLength(25)]],
      description: ['', [Validators.required, Validators.minLength(10), Validators.maxLength(300)]],
      categoryId: [1, [Validators.required]],
      buildingId: [1, [Validators.required]],
      roomNumber: ['', [Validators.required]],
      dateRequested: ['', [Validators.required]],
      studentId: [1, [Validators.required]] // In a real app, this would come from auth
    });
  }
}
```

**Form View (Template):** Bind the form model to the template using the `[formGroup]` and `formControlName` directives. The `(ngSubmit)` event on the `<form>` element is used to call a submission handler method in the component.

```html
<!-- src/app/features/work-orders/components/work-order-form/work-order-form.component.html -->
<form [formGroup]="workOrderForm" (ngSubmit)="onSubmit()" class="work-order-form">
  
  <!-- Title Field -->
  <div class="form-field">
    <label for="title" class="field-label required">Title</label>
    <input
      id="title"
      type="text"
      class="field-input"
      [class.invalid]="isFieldInvalid('title')"
      formControlName="title"
      placeholder="Brief description of the issue"
      aria-describedby="title-error">
    @if (isFieldInvalid('title')) {
      <div id="title-error" class="field-error">{{ getFieldError('title') }}</div>
    }
  </div>

  <!-- Description Field -->
  <div class="form-field form-field-full">
    <label for="description" class="field-label required">Description</label>
    <textarea
      id="description"
      class="field-textarea"
      [class.invalid]="isFieldInvalid('description')"
      formControlName="description"
      rows="4"
      placeholder="Detailed explanation of the problem..."
      aria-describedby="description-error"></textarea>
    @if (isFieldInvalid('description')) {
      <div id="description-error" class="field-error">{{ getFieldError('description') }}</div>
    }
  </div>

  <!-- Category Field -->
  <div class="form-field">
    <label for="categoryId" class="field-label required">Category</label>
    <select
      id="categoryId"
      class="field-select"
      [class.invalid]="isFieldInvalid('categoryId')"
      formControlName="categoryId">
      <option value="">Select category...</option>
      @for (option of categoryOptions; track option.value) {
        <option [value]="option.value">{{ option.label }}</option>
      }
    </select>
    @if (isFieldInvalid('categoryId')) {
      <div id="categoryId-error" class="field-error">{{ getFieldError('categoryId') }}</div>
    }
  </div>

  <!-- Form Actions -->
  <div class="form-actions">
    <button
      type="button"
      class="btn btn-secondary"
      (click)="onCancel()">
      Cancel
    </button>
    <button
      type="submit"
      class="btn btn-primary"
      [disabled]="isSubmitting()">
      <span class="btn-icon">➕</span>
      Create Work Order
    </button>
  </div>
</form>
```

### **Posting Form Data and Refreshing State**

When the user submits the form, the `onSubmit` method is called. This method is responsible for taking the form's value and passing it to a service that will send it to the backend.

**Submission Handler (Component):**

```ts
// src/app/features/work-orders/components/work-order-form/work-order-form.component.ts
onSubmit(): void {
  if (!this.workOrderForm.valid) {
    this.markFormGroupTouched(this.workOrderForm);
    return;
  }

  this.isSubmitting.set(true);
  this.errorMessage.set('');
  this.successMessage.set('');

  const formValue = this.workOrderForm.value;
  this.createWorkOrder(formValue);
}

private createWorkOrder(formValue: any): void {
  const request: WorkOrderCreateRequest = {
    title: formValue.title,
    description: formValue.description,
    categoryId: formValue.categoryId,
    room: {
      buildingId: formValue.buildingId,
      roomNumber: formValue.roomNumber
    },
    studentId: formValue.studentId,
    statusCode: 'OPN',
    dateRequested: formValue.dateRequested,
    maintenanceTechnicianCode: null,
    appointmentScheduled: null,
    completionNotes: null
  };

  this.workOrderService.createWorkOrder(request).pipe(
    takeUntilDestroyed(this.destroyRef)
  ).subscribe({
    next: (workOrder: any) => {
      this.successMessage.set('Work order created successfully!');
      this.isSubmitting.set(false);
      
      // Navigate to the newly created work order's detail page
      setTimeout(() => {
        this.router.navigate(['/work-orders', workOrder.orderNumber]);
      }, 1500);
    },
    error: (error) => {
      console.error('Failed to create work order:', error);
      this.errorMessage.set('Failed to create work order. Please try again.');
      this.isSubmitting.set(false);
    }
  });
}

private markFormGroupTouched(formGroup: FormGroup): void {
  Object.keys(formGroup.controls).forEach(key => {
    const control = formGroup.get(key);
    control?.markAsTouched();
  });
}
```

### 🔍 **Detailed Code Breakdown: Form Submission & CRUD Operations**

Let's trace the complete journey of data from form to server and back:

**onSubmit() Method - The Entry Point:**

```ts
onSubmit(): void {
  if (!this.workOrderForm.valid) {
    this.markFormGroupTouched(this.workOrderForm);
    return;
  }

  this.isSubmitting.set(true);
  this.errorMessage.set('');
  this.successMessage.set('');

  const formValue = this.workOrderForm.value;
  this.createWorkOrder(formValue);
}
```

**Step 1: Form Validation Guard**

```ts
if (!this.workOrderForm.valid) {
  this.markFormGroupTouched(this.workOrderForm);
  return;
}
```

**What is `this.workOrderForm.valid`?**
- **Property** from Angular's FormGroup
- **Computed automatically** based on validators
- `true` if ALL controls pass their validators
- `false` if ANY control fails validation

**Validation check examples:**

```ts
// All valid:
{
  title: "Broken sink",        // ✓ Required, 5-25 chars
  description: "Water leak",   // ✓ Required, 10-300 chars  
  categoryId: 1               // ✓ Required
}
// → form.valid = true

// Invalid title (too short):
{
  title: "Bad",                // ✗ Only 3 chars (need 5)
  description: "Water leak",   // ✓ Valid
  categoryId: 1               // ✓ Valid
}
// → form.valid = false
```

**Why call `markFormGroupTouched()`?**

```ts
// Without marking touched:
// User submits invalid form
// Validation errors DON'T show (fields not touched yet)
// User confused: "Why won't it submit?"

// With marking touched:
// User submits invalid form
// All fields marked as "touched"
// Validation errors SHOW in red
// User sees: "Title must be at least 5 characters"
```

**Early return pattern:**

```ts
return;  // Stops function execution here
// Code below doesn't run if form is invalid
// Clean, readable guard clause pattern
```

**Step 2: Set Submission State**

```ts
this.isSubmitting.set(true);
this.errorMessage.set('');
this.successMessage.set('');
```

**Why set THREE different states?**

1. **`isSubmitting.set(true)`:**
   - Disables submit button (prevent double-submit)
   - Shows loading indicator on button
   - User knows action is processing

2. **`errorMessage.set('')`:**
   - Clears any previous error message
   - **Prevents confusion**: "Is that old error or new?"
   - Fresh start for this submission

3. **`successMessage.set('')`:**
   - Clears any previous success message
   - User won't see "Success!" from last submission

**Step 3: Extract Form Value**

```ts
const formValue = this.workOrderForm.value;
```

**What is `.value`?**
- **Property** that returns JavaScript object with all form values
- **Keys** match `formControlName` attributes
- **Values** are current user input

**Example transformation:**

```ts
// Form in browser:
<input formControlName="title" value="Broken sink">
<textarea formControlName="description" value="Water leaking from pipe">
<select formControlName="categoryId" value="1">

// Becomes JavaScript object:
{
  title: "Broken sink",
  description: "Water leaking from pipe",
  categoryId: 1,
  buildingId: 2,
  roomNumber: "101",
  // ... etc
}
```

**createWorkOrder() Method - Data Transformation:**

```ts
private createWorkOrder(formValue: any): void {
  const request: WorkOrderCreateRequest = {
    title: formValue.title,
    description: formValue.description,
    categoryId: formValue.categoryId,
    room: {
      buildingId: formValue.buildingId,
      roomNumber: formValue.roomNumber
    },
    studentId: formValue.studentId,
    statusCode: 'OPN',
    dateRequested: formValue.dateRequested,
    maintenanceTechnicianCode: null,
    appointmentScheduled: null,
    completionNotes: null
  };
  // ...
}
```

**Why transform the data?**

**Form structure (flat):**
```ts
{
  title: "Broken sink",
  buildingId: 2,
  roomNumber: "101",
  categoryId: 1
}
```

**API expects (nested):**
```ts
{
  title: "Broken sink",
  room: {                    // ← Nested object!
    buildingId: 2,
    roomNumber: "101"
  },
  categoryId: 1,
  statusCode: 'OPN',         // ← Added by code
  maintenanceTechnicianCode: null  // ← Default values
}
```

**Why the API needs nested structure:**
- **Database schema**: Room is separate table with composite key
- **Type safety**: Backend expects `Room` object, not flat fields
- **Separation of concerns**: Room data grouped logically

**Adding defaults and nulls:**

```ts
statusCode: 'OPN',  // Always start as "Open"
maintenanceTechnicianCode: null,  // Not assigned yet
appointmentScheduled: null,  // Not scheduled yet
completionNotes: null  // No notes on creation
```

**Why explicitly set to `null`?**
- **API contract**: Backend expects these fields (even if null)
- **Type safety**: Interface requires all properties
- **Documentation**: Clear what's not set yet
- **Database**: NULL is different from missing/undefined

**HTTP POST Request:**

```ts
this.workOrderService.createWorkOrder(request).pipe(
  takeUntilDestroyed(this.destroyRef)
).subscribe({
  next: (workOrder: any) => { /* success */ },
  error: (error) => { /* failure */ }
});
```

**The `.subscribe()` triggers:**
1. Service method called
2. HTTP POST request sent
3. JSON serialization (object → string)
4. Network transmission
5. Server receives and processes
6. Server responds with created work order
7. JSON deserialization (string → object)
8. `next` or `error` callback fires

**Success Handler:**

```ts
next: (workOrder: any) => {
  this.successMessage.set('Work order created successfully!');
  this.isSubmitting.set(false);
  
  setTimeout(() => {
    this.router.navigate(['/work-orders', workOrder.orderNumber]);
  }, 1500);
}
```

**Step-by-step execution:**

1. **Show success message:**
```ts
this.successMessage.set('Work order created successfully!');
// Green banner appears: "✓ Work order created successfully!"
```

2. **Clear loading state:**
```ts
this.isSubmitting.set(false);
// Button re-enabled (though we're about to navigate away)
```

3. **Delayed navigation:**
```ts
setTimeout(() => {
  this.router.navigate(['/work-orders', workOrder.orderNumber]);
}, 1500);
```

**Why `setTimeout()` with 1500ms delay?**
- **User feedback**: Let them SEE the success message
- **Feels polished**: Not jarring instant navigation
- **Read time**: 1.5 seconds to read "Success!"
- **UX pattern**: Common in modern web apps

**Router navigation:**

```ts
this.router.navigate(['/work-orders', workOrder.orderNumber]);
//                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//                     Array of path segments
```

**How this builds URL:**

```ts
// If workOrder.orderNumber = 12345
['/work-orders', 12345]
// Becomes: /work-orders/12345

// Router matches route:
{ path: 'work-orders/:id', component: WorkOrderDetailComponent }
// Loads detail page for work order #12345
```

**Error Handler:**

```ts
error: (error) => {
  console.error('Failed to create work order:', error);
  this.errorMessage.set('Failed to create work order. Please try again.');
  this.isSubmitting.set(false);
}
```

**Error handling checklist:**

✅ **Log to console** (for developers debugging)  
✅ **Show user-friendly message** (for users)  
✅ **Clear loading state** (re-enable form)  
✅ **Preserve form data** (user doesn't lose work!)

**Why preserve form data?**

```ts
// ❌ BAD: Reset form on error
error: (error) => {
  this.workOrderForm.reset();
  // User spent 5 minutes filling form
  // Error happens (network glitch)
  // ALL DATA LOST
  // User VERY ANGRY
}

// ✅ GOOD: Keep form data
error: (error) => {
  this.errorMessage.set('Error. Please try again.');
  // Form still has user's data
  // User can click submit again
  // OR fix validation issue
  // Much better UX
}
```

**markFormGroupTouched() Method:**

```ts
private markFormGroupTouched(formGroup: FormGroup): void {
  Object.keys(formGroup.controls).forEach(key => {
    const control = formGroup.get(key);
    control?.markAsTouched();
  });
}
```

**Breaking down this utility:**

**`Object.keys(formGroup.controls)`:**
```ts
// formGroup.controls = {
//   title: FormControl,
//   description: FormControl,
//   categoryId: FormControl,
//   ...
// }

Object.keys(formGroup.controls)
// Returns: ['title', 'description', 'categoryId', ...]
```

**`.forEach(key => { ... })`:**
```ts
// Loops through each control name:
// key = 'title'
// key = 'description'
// key = 'categoryId'
// etc.
```

**`const control = formGroup.get(key);`:**
```ts
// Gets the FormControl for this field
formGroup.get('title')  // Returns FormControl for title input
```

**`control?.markAsTouched();`:**
- `?.` is **optional chaining** (safe navigation)
- Only calls `markAsTouched()` if control exists
- **Prevents error** if control is null/undefined

**What `markAsTouched()` does:**
- Sets control's `touched` property to `true`
- **Touched** means "user interacted with this field"
- Triggers error messages to show (if invalid)

**Visual effect:**

```html
<!-- BEFORE markAsTouched (untouched, invalid): -->
<input formControlName="title" value="">
<!-- No error showing (even though empty/invalid) -->

<!-- AFTER markAsTouched (touched, invalid): -->
<input formControlName="title" value="" class="invalid">
<div class="error">Title is required</div>
<!-- Error now visible! -->
```

**Complete form submission flow:**

```
1. User fills form
2. User clicks "Submit" button
3. (ngSubmit) event fires
4. onSubmit() called
5. Check: form.valid? 
   ├─ No → Mark all touched, show errors, stop
   └─ Yes → Continue
6. Set isSubmitting = true (button disabled)
7. Clear error/success messages
8. Get form.value (JavaScript object)
9. Transform to API format (nested structure)
10. Call service.createWorkOrder()
11. HTTP POST sent to server
12. ... waiting for response ...
13. Response Success:
    ├─ Show success message
    ├─ Clear loading state
    ├─ Wait 1.5 seconds
    └─ Navigate to detail page
14. Response Error:
    ├─ Log error
    ├─ Show error message
    ├─ Clear loading state
    └─ Keep form data (user can retry)
```

**Why this pattern is production-ready:**
1. **Validation**: Prevents invalid data reaching server
2. **Loading states**: Clear UI feedback during async operations
3. **Error handling**: Graceful failure with user-friendly messages
4. **Data preservation**: Don't lose user's work on errors
5. **Navigation**: Smooth transition to next screen
6. **Type safety**: TypeScript catches errors at compile time
7. **Memory management**: takeUntilDestroyed prevents leaks

**Create Method (Service):** The service encapsulates the HTTP POST logic.

```ts
// src/app/services/work-order.service.ts
createWorkOrder(request: WorkOrderCreateRequest): Observable<WorkOrder> {
  const backendRequest: BackendWorkOrderRequestDto = {
    studentId: request.studentId,
    room: {
      buildingId: request.room.buildingId,
      roomNumber: request.room.roomNumber
    },
    categoryId: request.categoryId,
    statusCode: request.statusCode || 'OPN',
    title: request.title,
    description: request.description,
    dateRequested: request.dateRequested,
    maintenanceTechnicianCode: request.maintenanceTechnicianCode || null,
    appointmentScheduled: request.appointmentScheduled || null,
    completionNotes: request.completionNotes || null
  };

  return this.apiService.post<BackendWorkOrderDto>('work_order', backendRequest).pipe(
    map(response => response.data),
    catchError(error => {
      console.error('Failed to create work order:', error);
      throw error;
    })
  );
}
```

#### **Updating Local State After Server Changes**

After a create, update, or delete operation, the data on the server has changed, but the data in the frontend's state (our signal) is now stale. The simplest and most reliable way to synchronize the state is to **re-fetch the entire list** from the server.

While more advanced state management libraries offer strategies for locally mutating the state (e.g., adding the new item to the array directly), a re-fetch guarantees that the UI reflects the true state of the database.

Looking at our `WorkOrderListComponent`:

```ts
// src/app/features/work-orders/components/work-order-list/work-order-list.component.ts
export class WorkOrderListComponent implements OnInit {
  workOrders = signal<WorkOrder[]>([]);
  filteredWorkOrders = signal<WorkOrder[]>([]);
  isLoading = signal<boolean>(true);

  ngOnInit(): void {
    this.loadWorkOrders(); // Initial load
  }

  private loadWorkOrders(): void {
    this.isLoading.set(true);

    this.workOrderService.getWorkOrders().pipe(
      takeUntilDestroyed(this.destroyRef)
    ).subscribe({
      next: (response: any) => {
        this.workOrders.set(response.data);
        this.applyFilters();
        this.isLoading.set(false);
      },
      error: (error) => {
        console.error('Failed to load work orders:', error);
        this.isLoading.set(false);
      }
    });
  }

  refreshList(): void {
    this.loadWorkOrders(); // Re-fetch from server
  }
}
```

In the template, we provide a refresh button:

```html
<button 
  class="btn btn-info"
  type="button"
  (click)="refreshList()"
  [disabled]="isLoading()"
  aria-label="Refresh work order list">
  <span class="btn-icon">↻</span>
  Refresh
</button>
```

### **Component-Driven Design for CRUD**

This session brings all the pieces together into a tangible application. A good pattern is to structure components around CRUD functionality:

**ListComponent:** Responsible for displaying the list of items (Read) and initiating Delete operations.

```ts
// src/app/features/work-orders/components/work-order-list/work-order-list.component.ts
@Component({
  selector: 'app-work-order-list',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    ReactiveFormsModule,
    StatusBadgeComponent,
    LoadingSpinnerComponent
  ],
  templateUrl: './work-order-list.component.html',
  styleUrl: './work-order-list.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class WorkOrderListComponent implements OnInit {
  // Read functionality
  workOrders = signal<WorkOrder[]>([]);
  filteredWorkOrders = signal<WorkOrder[]>([]);
  
  ngOnInit(): void {
    this.loadWorkOrders();
  }

  private loadWorkOrders(): void {
    // Fetch work orders from server
    this.workOrderService.getWorkOrders().pipe(
      takeUntilDestroyed(this.destroyRef)
    ).subscribe({
      next: (response) => {
        this.workOrders.set(response.data);
        this.applyFilters();
      }
    });
  }

  refreshList(): void {
    this.loadWorkOrders();
  }
}
```

**FormComponent:** A reusable component for both creating new items (Create) and editing existing ones (Update). It can take an optional `input()` to pre-populate the form for editing.

```ts
// src/app/features/work-orders/components/work-order-form/work-order-form.component.ts
@Component({
  selector: 'app-work-order-form',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    ReactiveFormsModule
  ],
  templateUrl: './work-order-form.component.html',
  styleUrl: './work-order-form.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class WorkOrderFormComponent implements OnInit {
  // Optional input for edit mode (future enhancement)
  workOrderId = input<number | null>(null);
  
  workOrderForm: FormGroup;
  isSubmitting = signal<boolean>(false);

  constructor() {
    this.workOrderForm = this.createForm();
  }

  ngOnInit(): void {
    // If editing, load work order data
    const id = this.workOrderId();
    if (id) {
      this.loadWorkOrder(id);
    }
  }

  private loadWorkOrder(id: number): void {
    this.workOrderService.getWorkOrderById(id).subscribe({
      next: (workOrder) => {
        // Populate form with existing data
        this.workOrderForm.patchValue({
          title: workOrder.title,
          description: workOrder.description,
          categoryId: workOrder.category.id,
          buildingId: workOrder.room.id.buildingId,
          roomNumber: workOrder.room.id.roomNumber
        });
      }
    });
  }

  onSubmit(): void {
    if (!this.workOrderForm.valid) return;

    this.isSubmitting.set(true);
    
    const request = this.buildRequest();
    
    this.workOrderService.createWorkOrder(request).subscribe({
      next: (workOrder) => {
        this.successMessage.set('Work order created successfully!');
        this.isSubmitting.set(false);
        
        // Navigate to detail page
        this.router.navigate(['/work-orders', workOrder.orderNumber]);
      },
      error: (error) => {
        this.errorMessage.set('Failed to create work order.');
        this.isSubmitting.set(false);
      }
    });
  }
}
```

**DetailComponent:** Displays detailed information about a single item (Read).

```ts
// src/app/features/work-orders/components/work-order-detail/work-order-detail.component.ts
@Component({
  selector: 'app-work-order-detail',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    StatusBadgeComponent,
    LoadingSpinnerComponent
  ],
  templateUrl: './work-order-detail.component.html',
  styleUrl: './work-order-detail.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class WorkOrderDetailComponent extends BaseComponent {
  id = input.required<string>(); // Route parameter

  private readonly workOrderService = inject(WorkOrderService);
  private readonly router = inject(Router);

  workOrder = signal<WorkOrder | null>(null);

  constructor() {
    super();

    // Effect to load work order when id changes
    effect(() => {
      const workOrderId = this.id();
      if (workOrderId) {
        this.loadWorkOrder(workOrderId);
      } else {
        this.router.navigate(['/work-orders']);
      }
    });
  }

  private async loadWorkOrder(id: string): Promise<void> {
    const workOrder = await this.handleAsync(
      () => firstValueFrom(this.workOrderService.getWorkOrderById(parseInt(id))),
      'Failed to load work order'
    );

    if (workOrder) {
      this.workOrder.set(workOrder);
    }
  }

  onBack(): void {
    this.router.navigate(['/work-orders']);
  }

  formatDate(date: Date | string | null | undefined): string {
    if (!date) return 'Not set';

    const d = new Date(date);
    return d.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  }
}
```

### **Using the BaseComponent for Common Functionality**

Our WSU project uses a `BaseComponent` class that provides common functionality like loading states and error handling:

```ts
// src/app/shared/utils/base-component.ts
@Injectable()
export abstract class BaseComponent {
  protected readonly destroyRef = inject(DestroyRef);
  protected readonly errorBoundary = inject(ErrorBoundaryService);

  // Common loading and error states using Angular signals
  protected readonly isLoading = signal(false);
  protected readonly error = signal<string | null>(null);
  protected readonly hasError = computed(() => this.error() !== null);

  /**
   * Set loading state
   */
  protected setLoading(loading: boolean): void {
    this.isLoading.set(loading);
  }

  /**
   * Handle async operations with automatic loading and error handling
   */
  protected async handleAsync<T>(
    operation: () => Promise<T>,
    errorMessage = 'An error occurred'
  ): Promise<T | null> {
    try {
      this.setLoading(true);
      this.clearError();
      return await operation();
    } catch (error) {
      this.errorBoundary.handleAsyncError(error);
      this.setError(errorMessage);
      return null;
    } finally {
      this.setLoading(false);
    }
  }

  /**
   * Show success message
   */
  protected showSuccess(message: string, autoRemove: boolean = true): void {
    this.errorBoundary.showSuccess(message, autoRemove);
  }
}
```

## **Complete CRUD Flow Example**

Let's trace a complete CRUD operation from UI to server and back:

### Create Flow:
1. User navigates to `/work-orders/create`
2. Router loads `WorkOrderFormComponent`
3. User fills out form and clicks submit
4. `onSubmit()` calls `workOrderService.createWorkOrder()`
5. Service sends POST request to backend
6. Backend creates work order and returns created object
7. Component receives response and navigates to detail page
8. Detail page displays the newly created work order

### Read Flow:
1. User navigates to `/work-orders`
2. Router loads `WorkOrderListComponent`
3. `ngOnInit()` calls `loadWorkOrders()`
4. Service sends GET request to backend
5. Backend returns array of work orders
6. Component updates `workOrders` signal
7. Template's `@for` loop renders the list

### Update Flow (Future Enhancement):
1. User navigates to `/work-orders/edit/:id`
2. Router loads `WorkOrderFormComponent` with id parameter
3. Component loads existing work order data
4. Form is pre-populated with current values
5. User makes changes and submits
6. Service sends PUT/PATCH request to backend
7. Backend updates work order
8. Component navigates to detail page

### Delete Flow (Future Enhancement):
1. User clicks delete button on a work order
2. Component calls `workOrderService.deleteWorkOrder(id)`
3. Service sends DELETE request to backend
4. Backend deletes work order
5. Component refreshes list by calling `loadWorkOrders()`
6. Updated list (without deleted item) is displayed

This comprehensive approach demonstrates how all the pieces work together to create a fully functional CRUD application using modern Angular patterns and the WSU Work Order Management system.
