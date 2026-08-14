## **🔁 Class 4 — Data Round Trip & Full-Stack Display**

### **Goal**

Connect the frontend form, data service, and backend server to perform full CRUD (Create, Read, Update, Delete) operations using the WSU Work Order Management system. Understand how to manage and refresh application state after server-side changes.

### **Topics**

#### **Fetching Data on ngOnInit**

While `toSignal` automatically triggers the data fetch upon component initialization, it's important to understand the `ngOnInit` lifecycle hook. This hook is a method that Angular calls once, right after creating a component. It's a common place to perform initial data fetching or setup logic.

**Component Lifecycle Sequence:**

```
1. Constructor
    ↓
2. Input properties set (@Input or input())
    ↓
3. ngOnInit() ← Perfect for data fetching
    ↓
4. Component fully initialized
    ↓
5. Change detection runs
    ↓
... component lifetime ...
    ↓
7. ngOnDestroy
```

**Dashboard Component Example:**

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

**Why ngOnInit and not constructor?**

```ts
// ❌ Constructor - TOO EARLY for data fetching:
constructor() {
  // Component inputs NOT YET available
  // Child components NOT YET created
  // DOM NOT YET rendered
  // Should only initialize properties
}

// ✅ ngOnInit - PERFECT for data fetching:
ngOnInit(): void {
  // Component inputs ARE available
  // Component IS fully initialized
  // Safe to start async operations
}
```

**Key Concepts:**

**`implements OnInit`:**
- Compile-time check ensures you implement `ngOnInit()` method
- Documentation for other developers
- Type safety (TypeScript error if you misspell)

**Loading Pattern:**
1. **Set loading state FIRST** (`isLoading.set(true)`) - Immediate UI feedback
2. **Call service method** - Returns cold Observable
3. **Auto-cleanup with takeUntilDestroyed** - Prevents memory leaks
4. **Subscribe with handlers** - Success and error callbacks
5. **ALWAYS clear loading in error handler** - Prevent spinner forever

**Complete Data Flow:**

```
User navigates to dashboard
    ↓
Router creates DashboardComponent
    ↓
Constructor runs (inject services)
    ↓
ngOnInit() fires
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
User sees work order list
```

#### **Displaying Data with @for**

As established in previous classes, the `@for` block is the modern way to render a list of items. When displaying data fetched from a server, the pattern is straightforward:

1. The service returns an Observable from an HttpClient call.
2. The component converts this Observable to a signal using `toSignal` or subscribes and updates a signal.
3. The template binds to this signal with a `@for` loop, using `track` on a unique identifier from the data.

**Work Order List Template Example:**

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

**Component Tracking Function:**

```ts
trackByWorkOrderId(index: number, workOrder: WorkOrder): number {
  return workOrder.orderNumber;
}
```

**Why tracking is critical:**
- Provides unique identifier for each list item
- Enables efficient DOM updates (only changed items re-rendered)
- Prevents unnecessary component recreation on data changes

#### **Creating and Submitting Forms with Reactive Forms**

This class builds upon Reactive Forms by integrating them with backend services. The process involves creating a form model in the component, binding it to an HTML form, and handling the submission event.

**Form Model (Component):**

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
      studentId: [1, [Validators.required]] // In a real app, from auth
    });
  }
}
```

**Form View (Template):**

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

**Key Form Concepts:**

**`[formGroup]="workOrderForm"`:**
- Links template form to component form model
- Enables two-way data binding for all controls

**`formControlName="title"`:**
- Connects input to specific form control
- Matches property name in FormBuilder.group()

**`(ngSubmit)="onSubmit()"`:**
- Form submission event handler
- Fires when user submits form (Enter key or button click)
- Prevents default browser form submission

**Form Validation:**
- `Validators.required` - Field must have value
- `Validators.minLength(5)` - Minimum character length
- `Validators.maxLength(25)` - Maximum character length
- `[class.invalid]` - Adds CSS class when field is invalid
- `@if (isFieldInvalid())` - Shows error message conditionally

#### **Posting Form Data and Refreshing State**

When the user submits the form, the `onSubmit` method is called. This method is responsible for taking the form's value and passing it to a service that will send it to the backend.

**Submission Handler (Component):**

```ts
// src/app/features/work-orders/components/work-order-form/work-order-form.component.ts
onSubmit(): void {
  // Step 1: Validation guard
  if (!this.workOrderForm.valid) {
    this.markFormGroupTouched(this.workOrderForm);
    return;
  }

  // Step 2: Set submission state
  this.isSubmitting.set(true);
  this.errorMessage.set('');
  this.successMessage.set('');

  // Step 3: Extract and transform form data
  const formValue = this.workOrderForm.value;
  this.createWorkOrder(formValue);
}

private createWorkOrder(formValue: any): void {
  // Transform flat form data to nested API structure
  const request: WorkOrderCreateRequest = {
    title: formValue.title,
    description: formValue.description,
    categoryId: formValue.categoryId,
    room: {  // Nested object for API
      buildingId: formValue.buildingId,
      roomNumber: formValue.roomNumber
    },
    studentId: formValue.studentId,
    statusCode: 'OPN',  // Default status
    dateRequested: formValue.dateRequested,
    maintenanceTechnicianCode: null,  // Not assigned yet
    appointmentScheduled: null,
    completionNotes: null
  };

  // Send POST request to server
  this.workOrderService.createWorkOrder(request).pipe(
    takeUntilDestroyed(this.destroyRef)
  ).subscribe({
    next: (workOrder: any) => {
      // Success: Show message and navigate
      this.successMessage.set('Work order created successfully!');
      this.isSubmitting.set(false);
      
      // Navigate to detail page after delay
      setTimeout(() => {
        this.router.navigate(['/work-orders', workOrder.orderNumber]);
      }, 1500);
    },
    error: (error) => {
      // Error: Show message and keep form data
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

**Form Submission Flow:**

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
    ├─ Wait 1.5 seconds (user reads message)
    └─ Navigate to detail page
14. Response Error:
    ├─ Log error
    ├─ Show error message
    ├─ Clear loading state
    └─ Keep form data (user can retry)
```

**Why Transform Data?**

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

**Why Preserve Form Data on Error?**

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
  // Much better UX
}
```

**Create Method (Service):**

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

**Work Order List Component:**

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

**Template with Refresh Button:**

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

**Why Re-fetch Instead of Local Update?**

1. **Simplicity**: Easy to implement and understand
2. **Reliability**: Guaranteed to match server state
3. **Server-side changes**: Captures any backend modifications
4. **No sync issues**: No risk of frontend/backend mismatch
5. **Beginner-friendly**: Less complex than local state management

#### **Component-Driven Design for CRUD**

This class brings all the pieces together into a tangible application. A good pattern is to structure components around CRUD functionality:

**1. ListComponent - Read & Initiate Delete**

Responsible for displaying the list of items and initiating delete operations.

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

**2. FormComponent - Create & Update**

Reusable component for both creating new items and editing existing ones. Takes optional `input()` to pre-populate the form for editing.

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
  // Optional input for edit mode
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

**3. DetailComponent - Read Single Item**

Displays detailed information about a single item.

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

#### **Using BaseComponent for Common Functionality**

Our WSU project uses a `BaseComponent` class that provides common functionality like loading states and error handling:

```ts
// src/app/shared/utils/base-component.ts
@Injectable()
export abstract class BaseComponent {
  protected readonly destroyRef = inject(DestroyRef);
  protected readonly errorBoundary = inject(ErrorBoundaryService);

  // Common loading and error states using signals
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

**Benefits of BaseComponent:**
- **DRY principle**: Common patterns in one place
- **Consistent error handling**: Same approach across all components
- **Loading states**: Centralized loading management
- **Type safety**: Generic methods ensure type correctness
- **Easy testing**: Mock BaseComponent for unit tests

#### **Complete CRUD Flow Examples**

Let's trace complete operations from UI to server and back:

**Create Flow:**
1. User navigates to `/work-orders/create`
2. Router loads `WorkOrderFormComponent`
3. User fills out form and clicks submit
4. `onSubmit()` calls `workOrderService.createWorkOrder()`
5. Service sends POST request to backend
6. Backend creates work order and returns created object
7. Component receives response and navigates to detail page
8. Detail page displays the newly created work order

**Read Flow:**
1. User navigates to `/work-orders`
2. Router loads `WorkOrderListComponent`
3. `ngOnInit()` calls `loadWorkOrders()`
4. Service sends GET request to backend
5. Backend returns array of work orders
6. Component updates `workOrders` signal
7. Template's `@for` loop renders the list

**Update Flow (Future Enhancement):**
1. User navigates to `/work-orders/edit/:id`
2. Router loads `WorkOrderFormComponent` with id parameter
3. Component loads existing work order data
4. Form is pre-populated with current values
5. User makes changes and submits
6. Service sends PUT/PATCH request to backend
7. Backend updates work order
8. Component navigates to detail page

**Delete Flow (Future Enhancement):**
1. User clicks delete button on a work order
2. Component calls `workOrderService.deleteWorkOrder(id)`
3. Service sends DELETE request to backend
4. Backend deletes work order
5. Component refreshes list by calling `loadWorkOrders()`
6. Updated list (without deleted item) is displayed

### **Summary**

This comprehensive class demonstrates:

1. **ngOnInit Lifecycle Hook**: Understanding component initialization and data fetching timing
2. **Loading States**: Managing UI feedback during async operations
3. **Form Creation**: Using FormBuilder with validators for type-safe forms
4. **Form Submission**: Handling validation, transformation, and HTTP POST
5. **Error Handling**: Graceful failure with user-friendly messages
6. **State Management**: Refreshing data after server changes
7. **Component Architecture**: Organizing CRUD operations across components
8. **BaseComponent Pattern**: Sharing common functionality
9. **Complete CRUD Flows**: End-to-end data operations
10. **Real-world Patterns**: Production-ready code from WSU application

This provides a complete foundation for building full-stack CRUD applications in modern Angular.
