# Class 7 — Testing with Jest & Client-Side Pagination

> **Wildcard Session — In-Class Demo & Practice (No New Homework Assigned).**
> Automated testing and client-side pagination are covered today as essential production engineering practices. Writing unit tests is optional and not graded for student projects. There is no new homework assigned for this session.

## Setting the Stage: Production Quality and Scalability

In production software development, two concerns quickly emerge as an application matures:
1. **Regression Prevention**: How do we verify that adding a new feature does not silently break existing code without manually clicking through every screen in a browser?
2. **Scalability and Performance**: How does the UI perform when a database returns 500 or 5,000 records instead of 5?

Today's session explores the answers implemented in `wsu-test`: automated testing with Jest and client-side reactive pagination.

## The Jest Testing Environment in Angular

Historically, Angular projects relied on Karma and Jasmine, which launched a full headless Chrome browser for every test execution. In `wsu-test`, we use **Jest**:

- **Fast Execution**: Tests execute directly inside Node.js using `jsdom` (an in-memory virtual DOM), skipping the startup overhead of a browser process.
- **Built-in Mocking**: Provides `jest.fn()` and `jest.spyOn()` without requiring auxiliary libraries.
- **Parallel Execution**: Tests execute across multiple worker threads simultaneously.
- **Standard CLI**: Run the entire suite with `npm test`, or test a single component with `npm test -- status-badge.component.spec.ts`.

## Section 1. Testing Presentational Components with Signal Inputs

Presentational components receive inputs and render DOM elements. In `wsu-test`, `StatusBadgeComponent` maps status codes to labels and styles.

Here is the complete unit test specification:

```typescript
// src/app/shared/components/status-badge/status-badge.component.spec.ts
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { StatusBadgeComponent } from './status-badge.component';

describe('StatusBadgeComponent', () => {
  let fixture: ComponentFixture<StatusBadgeComponent>;

  beforeEach(async () => {
    // 1. Configure the isolated testing module
    await TestBed.configureTestingModule({
      imports: [StatusBadgeComponent]
    }).compileComponents();

    fixture = TestBed.createComponent(StatusBadgeComponent);
  });

  it('should render "Open" label for OPN status', () => {
    // 2. Set signal input values using fixture.componentRef.setInput
    fixture.componentRef.setInput('status', 'OPN');

    // 3. Trigger change detection to update the DOM
    fixture.detectChanges();

    // 4. Assert against the rendered DOM text and classes
    const element: HTMLElement = fixture.nativeElement;
    const badge = element.querySelector('.badge');

    expect(badge).toBeTruthy();
    expect(badge?.textContent?.trim()).toBe('Open');
    expect(badge?.classList.contains('badge--status-open')).toBe(true);
  });

  it('should render "Unknown" label for unmapped status code', () => {
    fixture.componentRef.setInput('status', 'INVALID_CODE');
    fixture.detectChanges();

    const element: HTMLElement = fixture.nativeElement;
    const badge = element.querySelector('.badge');

    expect(badge?.textContent?.trim()).toBe('Unknown');
    expect(badge?.classList.contains('badge--status-unknown')).toBe(true);
  });
});
```

### Key Testing Patterns Demonstrated

- `TestBed.createComponent()`: Creates an isolated component sandbox.
- `fixture.componentRef.setInput(key, value)`: Modern Angular API for setting signal inputs in unit tests.
- `fixture.detectChanges()`: Forces change detection so DOM nodes reflect the latest signal state.
- Asserting the DOM rather than private class fields verifies the user experience directly.

## Section 2. HTTP Contract Testing with `HttpTestingController`

Unit testing HTTP services requires verifying request URLs, methods, and payload mapping without making real network calls.

Angular provides `provideHttpClientTesting()` and `HttpTestingController`:

```typescript
// src/app/features/labs/services/labs-read.service.spec.ts
import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { LabsReadService } from './labs-read.service';

describe('LabsReadService', () => {
  let service: LabsReadService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        LabsReadService,
        provideHttpClient(),
        provideHttpClientTesting()
      ]
    });

    service = inject(LabsReadService);
    httpMock = inject(HttpTestingController);
  });

  afterEach(() => {
    // Verifies that no unexpected HTTP requests remain pending
    httpMock.verify();
  });

  it('should issue a GET request to the correct endpoint and unpack data', () => {
    const mockData = [{ id: 1, name: 'Sample Item' }];

    service.getItems().subscribe(items => {
      expect(items).toEqual(mockData);
    });

    // 1. Expect exactly one HTTP request to the designated URL
    const req = httpMock.expectOne('http://localhost:8080/api/items');
    expect(req.request.method).toBe('GET');

    // 2. Flush mock JSON payload to satisfy the observable
    req.flush(mockData);
  });
});
```

Checkpoint:
> "Why is `httpMock.verify()` placed in `afterEach()`?"
> To ensure that every request emitted by the service was explicitly acknowledged and flushed, detecting accidental duplicate calls or missing expectations.

## Section 3. Client-Side Pagination Architecture and Signal Math

Rendering hundreds of DOM nodes degrades scroll performance and increases browser memory usage. Client-side pagination slices an in-memory array into manageable chunks.

### The Mathematical Foundation

Given:
- $N$: Total number of records (`totalCount`)
- $S$: Page size (`pageSize`, e.g. 10 items per page)
- $P$: Active page index (`currentPage`, 1-based)

Calculations:
$$	ext{totalPages} = \lceil N / S ceil = 	ext{Math.ceil}(N / S)$$
$$	ext{startIndex} = (P - 1) 	imes S$$
$$	ext{endIndex} = \min(	ext{startIndex} + S, N)$$

### Signals Implementation in `WorkOrderListComponent`

```typescript
// src/app/features/work-orders/components/work-order-list/work-order-list.component.ts
import { Component, computed, signal } from '@angular/core';

export class WorkOrderListComponent {
  readonly workOrders = signal<WorkOrder[]>([]);
  readonly currentPage = signal<number>(1);
  readonly pageSize = signal<number>(10);

  // Derived mathematical state
  readonly totalCount = computed(() => this.workOrders().length);
  readonly totalPages = computed(() => Math.ceil(this.totalCount() / this.pageSize()) || 1);

  readonly startIndex = computed(() => (this.currentPage() - 1) * this.pageSize());
  readonly endIndex = computed(() => Math.min(this.startIndex() + this.pageSize(), this.totalCount()));

  // Sliced collection rendered by @for
  readonly pagedWorkOrders = computed(() => 
    this.workOrders().slice(this.startIndex(), this.endIndex())
  );

  onPageChange(page: number): void {
    if (page >= 1 && page <= this.totalPages()) {
      this.currentPage.set(page);
    }
  }

  // Dynamic sliding window of 5 visible page buttons
  getPaginationPages(): number[] {
    const total = this.totalPages();
    const current = this.currentPage();
    const windowSize = 5;

    let start = Math.max(1, current - Math.floor(windowSize / 2));
    let end = Math.min(total, start + windowSize - 1);

    if (end - start + 1 < windowSize) {
      start = Math.max(1, end - windowSize + 1);
    }

    return Array.from({ length: end - start + 1 }, (_, i) => start + i);
  }
}
```

### Accessible Pagination Controls in the Template

```html
<!-- src/app/features/work-orders/components/work-order-list/work-order-list.component.html -->
@if (totalPages() > 1) {
  <nav class="pagination" aria-label="Work orders pagination">
    <button 
      type="button" 
      [disabled]="currentPage() === 1" 
      (click)="onPageChange(currentPage() - 1)"
      aria-label="Previous page"
    >
      Previous
    </button>

    @for (page of getPaginationPages(); track page) {
      <button 
        type="button" 
        [class.is-active]="page === currentPage()"
        [attr.aria-current]="page === currentPage() ? 'page' : null"
        (click)="onPageChange(page)"
      >
        {{ page }}
      </button>
    }

    <button 
      type="button" 
      [disabled]="currentPage() === totalPages()" 
      (click)="onPageChange(currentPage() + 1)"
      aria-label="Next page"
    >
      Next
    </button>
  </nav>
}
```

## Section 4. Architectural Comparison: Pagination vs. Virtual Scroll vs. Defer

| Technique | When to Use | Tradeoff |
| --- | --- | --- |
| **Client-Side Pagination** | 10 to 500 items; user needs explicit page navigation and page URLs | Requires discrete page clicks; does not provide infinite scroll feel |
| **Virtual Scrolling (`@angular/cdk`)** | 1,000 to 50,000 items (e.g. log streams, audit trails) | DOM nodes recycle inside viewport; scrollbar calculation requires fixed row heights |
| **Deferred Loading (`@defer`)** | Heavy below-the-fold components (charts, comment threads) | Renders placeholders until triggered by viewport entry or idle time |

## Section 5. In-Class Practice and Testing Exercises

Spend the remaining class time working through these exercises:
1. **Run the Test Suite**: Open your terminal in `wsu-test` and execute `npm test`. Observe how Jest executes 30+ test suites in seconds.
2. **Examine Edge Cases**: Review `status-badge.component.spec.ts` to see how missing or invalid inputs are handled.
3. **Optional Project Practice**: If your team's application renders large collections, consider incorporating client-side pagination into your list view.

## After Class (Ungraded Resources)

- `/labs/pagination-explorer` (Lab 18): Interactive playground visualizing pagination slices and sliding window math.
- `/labs/virtual-scroll` (Lab 19): Rendering an 8,000-item array using CDK virtual scrolling.
- `/labs/defer-analytics` (Lab 20): Deferring off-screen components using `@defer (on viewport)`.
