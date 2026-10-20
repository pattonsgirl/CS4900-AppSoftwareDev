# Class 7: Testing with Jest & Client-Side Pagination

> **Wildcard Session: In-Class Exploration & Practice (No New Homework Assigned)**
> Automated testing and client-side pagination are covered today as essential production practices. Writing automated tests is optional and not graded for student project submissions. Use today to learn these techniques, experiment in the reference repo, and polish your team deliverables.

> **Reference Application Grounding**:
> All practical demonstrations and code samples in this session are grounded in the reference repository [Mr Fix It UI](https://github.com/WSU-kduncan/mr-fixit-ui):
> - `src/app/shared/components/status-badge/status-badge.component.spec.ts` (isolated component test spec)
> - `src/app/services/api.service.spec.ts` (HTTP contract test spec)
> - `src/app/features/work-orders/components/work-order-list/work-order-list.component.ts` (client-side pagination math and dynamic sliding window)

---

## Production Quality and Scalability

In production applications, two engineering questions quickly emerge:

1. **Regression Prevention**: How do you verify that adding a new feature does not break existing code without clicking through every screen by hand?
2. **Scalability and Performance**: How does your UI behave when an API returns 200 or 2,000 records instead of 4?

Today we look at how production apps solve both: automated unit testing with Jest and client-side reactive pagination with Angular signals.

---

## Section 1: The Jest Testing Environment

Historically, Angular relied on Karma and Jasmine, which launched a full headless Chrome browser for every test run. In `mr-fixit-ui`, we use **Jest**:

- **Fast In-Memory Execution**: Tests run in Node.js using `jsdom` (an in-memory virtual DOM) rather than waiting for a real browser to boot.
- **Built-in Mocking and Spies**: Native utilities like `jest.fn()` and `jest.spyOn()` handle function mocking out of the box.
- **Parallel Runs**: Tests run across worker threads in parallel.
- **Convenient CLI**: Run tests across the project with `npm test`, or target a single file with `npm test -- status-badge.component.spec.ts`.

---

## Section 2: Testing Presentational Components with Signal Inputs

Presentational components take inputs and render markup. In `mr-fixit-ui`, `StatusBadgeComponent` maps status codes to human-readable labels and badge styles.

Here is the complete unit test from `src/app/shared/components/status-badge/status-badge.component.spec.ts`:

```typescript
// src/app/shared/components/status-badge/status-badge.component.spec.ts
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { StatusBadgeComponent } from './status-badge.component';

describe('StatusBadgeComponent', () => {
  let fixture: ComponentFixture<StatusBadgeComponent>;

  beforeEach(async () => {
    // 1. Configure the isolated test environment
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

    // 4. Assert against the rendered DOM text and CSS classes
    const element: HTMLElement = fixture.nativeElement;
    const badge = element.querySelector('.badge');

    expect(badge).toBeTruthy();
    expect(badge?.textContent?.trim()).toBe('Open');
    expect(badge?.classList.contains('badge--opn')).toBe(true);
  });

  it('should render "Unknown" label for unmapped status code', () => {
    fixture.componentRef.setInput('status', 'INVALID_CODE');
    fixture.detectChanges();

    const element: HTMLElement = fixture.nativeElement;
    const badge = element.querySelector('.badge');

    expect(badge?.textContent?.trim()).toBe('Unknown');
  });
});
```

### Key Testing Principles

- `TestBed.createComponent()`: Creates an isolated instance of the component in a test harness.
- `fixture.componentRef.setInput(key, value)`: The modern Angular API for updating signal inputs in tests.
- `fixture.detectChanges()`: Manually triggers change detection so the rendered HTML reflects the new input state.
- **Test What the User Sees**: Assert against `fixture.nativeElement` (the rendered DOM) rather than querying private TypeScript class properties. If the HTML text is right, the user experience is right.

---

### Checkpoint: Testing Components

> **Question**: Why do we call `fixture.detectChanges()` immediately after calling `fixture.componentRef.setInput()`?
>
> **Answer**: Setting a signal input marks the component as dirty, but does not synchronously redraw the DOM in the test runner. `fixture.detectChanges()` tells Angular to execute change detection and update the rendered HTML so you can assert against it.

---

## Section 3: HTTP Contract Testing with `HttpTestingController`

Unit testing HTTP services requires verifying request URLs, HTTP methods, and payload deserialization without making real network calls to a running backend.

Angular provides `provideHttpClientTesting()` and `HttpTestingController` for this:

```typescript
// src/app/services/api.service.spec.ts
import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { ApiService } from './api.service';

describe('ApiService', () => {
  let service: ApiService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        ApiService,
        provideHttpClient(),
        provideHttpClientTesting()
      ]
    });

    service = TestBed.inject(ApiService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    // Verifies that no unexpected HTTP requests remain pending
    httpMock.verify();
  });

  it('should issue a GET request to the correct endpoint and unpack data', () => {
    const mockData = [{ id: 1, name: 'Sample Item' }];

    service.get('items').subscribe(items => {
      expect(items).toEqual(mockData);
    });

    // 1. Expect exactly one HTTP request to the designated URL
    const req = httpMock.expectOne('http://localhost:8080/mr-fixit-service/items');
    expect(req.request.method).toBe('GET');

    // 2. Flush mock JSON payload to satisfy the observable
    req.flush(mockData);
  });
});
```

### Why `httpMock.verify()` Matters

Always place `httpMock.verify()` inside `afterEach()`. If your service accidentally fires two HTTP calls when it should only fire one, or if an unexpected call was triggered by a side effect, `verify()` flags the unhandled request immediately and fails the test.

---

## Section 4: Client-Side Pagination Architecture and Signal Math

Rendering hundreds of DOM nodes at once slows down page scrolling and increases memory use. When a backend returns a full list, client-side pagination slices the array into manageable pages.

### The Underlying Math

Given:
- \(N\): Total number of items (`totalCount`)
- \(S\): Page size (`pageSize`, e.g. 10 items per page)
- \(P\): Current page index (`currentPage`, 1-based)

The calculations:
- \(\text{totalPages} = \lceil N / S \rceil = \text{Math.ceil}(N / S)\)
- \(\text{startIndex} = (P - 1) \times S\)
- \(\text{endIndex} = \min(\text{startIndex} + S, N)\)

### Reactive Signals Implementation

In `mr-fixit-ui`, `WorkOrderListComponent` uses `computed()` signals so the active slice updates automatically whenever the page or underlying list changes:

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

  // Dynamic sliding window of 5 visible page numbers
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

### Accessible Pagination Template

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

---

## Section 5: Pagination vs. Virtual Scrolling vs. `@defer`

| Technique | When to Use | Tradeoff |
| --- | --- | --- |
| **Client-Side Pagination** | 10 to 500 items; users need clear page numbers and bookmarkable pages | Requires clicking through discrete pages |
| **Virtual Scrolling (`@angular/cdk`)** | 1,000 to 50,000 items (e.g., event logs or audit streams) | Reuses DOM nodes in a scrollable window; requires fixed item heights |
| **Deferred Loading (`@defer`)** | Heavy below-the-fold components (charts, review threads) | Content loads only when triggered by viewport entry or idle time |

---

## Section 6: In-Class Exploration & Practice

Use today's workshop time to try these exercises:

1. **Run the Jest Suite**: In `mr-fixit-ui`, run `npm test` in your terminal. Notice how quickly tests execute compared to opening a browser.
2. **Inspect Edge Cases**: Open `status-badge.component.spec.ts` to see how unexpected status inputs are tested.
3. **Optional Project Feature**: If your application returns large lists, try adding client-side pagination to your list view.
4. **Project Work Time**: Complete Homework 5 or Homework 6 with your team.
