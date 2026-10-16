# Class 8 — Project Work, Review, and Troubleshooting

> **Working Day 2 — No New Material Presented.**
> This is our final session of the Web Development module before Thanksgiving break. We do not introduce new framework features today. This class is dedicated to consolidating the full-stack slice from Homework 1 through Homework 5, auditing accessibility and keyboard navigation, verifying clean-install instructions in your project README, and 1-on-1 instructor troubleshooting.
> *(Thursday, November 26 is Thanksgiving — no class).*

> 💡 **Reference Application Grounding (`wsu-test`)**:
> All architectural standards and best practices reviewed today are demonstrated in `/Users/edjenkins/Documents/GitHub/WSU/2025/wsu-test`.
> Specific reference files:
> - `src/app/features/work-orders/` (complete master-detail flow: list, detail, and form)
> - `src/app/services/work-order.service.ts` (central domain service)
> - `src/app/shared/components/` (accessible status badges and loading indicators)

## Setting the Stage: Consolidating the Full-Stack Slice

Over the past seven classes, you built a modern, standalone Angular application:
1. **Class 1**: Project bootstrap, CLI toolchain, and modern application structure.
2. **Class 2**: Component decomposition, scoped SCSS, and modern control flow (`@if`, `@for`).
3. **Class 3**: Reactivity with Signals (`signal`, `computed`), event bindings, and injectable services.
4. **Class 4**: Asynchronous HTTP data fetching with `HttpClient` and Observable-to-Signal bridges.
5. **Class 5**: *Working Day 1* — CORS diagnostics, Network tab debugging, and connection resilience.
6. **Class 6**: The full round trip: master-detail routing, Reactive Forms, and HTTP `POST` submission.
7. **Class 7**: Production engineering: automated Jest testing and client-side pagination.

Today's goal is to ensure that your application functions as a cohesive, resilient product.

## Section 1. Connecting the Full-Stack Architecture

Review the complete data loop in your project:

```
[ User Interaction ] 
       │ (clicks button, types in form)
       ▼
[ Component State ] 
       │ (signals update, reactive form validates)
       ▼
[ Domain Service ] 
       │ (manages business logic, dispatches HTTP call)
       ▼
[ Gateway / HttpClient ] 
       │ (JSON serialized, sent over network)
       ▼
[ Spring Boot API & Database ] 
       │ (persists entity, returns 200/201 response)
       ▼
[ UI Confirmation ] 
       │ (signal store updates, router navigates, list refreshes)
```

## Section 2. The Clean-Install Mindset and README Verification

A project is only complete if another software engineer can clone the repository, install dependencies, and run it without tribal knowledge.

### Clean-Install Audit Checklist

Open a fresh terminal, clone your repository into a temporary directory, and verify:
1. **Prerequisites**: Does your `README.md` clearly state that **Node.js 22+** is required?
2. **Installation Command**: Does `npm ci` (or `npm install`) succeed without dependency resolution errors?
3. **Execution Command**: Does `npm start` launch the development server and print the local URL (`http://localhost:4200`)?
4. **Backend URL**: Does your `README.md` or `environment.ts` document the exact backend server URL (`http://localhost:8080/...`) expected by your services?
5. **Clear Commit History**: Do your git commits reflect incremental progress rather than a single monolithic "final commit"?

## Section 3. Accessibility and UI Polish Audit

Front-end engineering is not just about moving data; it is about delivering an accessible, resilient user experience.

### 1. Keyboard Navigation
- Disconnect your mouse and tab through your entire user flow (home -> list -> create -> submit).
- Can every interactive element be reached with `Tab` and activated with `Enter` or `Space`?
- Are links marked as `<a routerLink="...">` and buttons marked as `<button type="button">`?

### 2. Visible Focus Rings
- Does every active control display a clear, visible focus outline?
- **Defect**: Removing outlines with `outline: none` in CSS without supplying an explicit `:focus-visible` replacement fails accessibility compliance.

### 3. Accessible Form Controls
- Does every `<input>`, `<select>`, and `<textarea>` have an associated `<label for="...">`?
- Placeholders are hints, not labels. A form control with only a `placeholder` attribute fails accessibility criteria.

### 4. Asynchronous Error Notifications
- When an HTTP request fails, does the error message appear on the page inside an element with `role="alert"`?
- Logging errors exclusively to `console.error()` leaves users confused when requests fail.

> 🧪 **Simpler Lab Reference in `wsu-test`**:
> Want to see Angular CDK `LiveAnnouncer` announce screen-reader messages and `FocusMonitor` manage keyboard focus rings cleanly? Open `http://localhost:4200/labs/cdk-a11y` (Lab 21) in `wsu-test` (`src/app/features/labs/cdk-a11y-lab/`).
> For accessible modal dialogs with focus trapping, open `http://localhost:4200/labs/cdk-dialog` (Lab 22).
> For the comprehensive clean code engineering checklist, open `http://localhost:4200/labs/angular-standards` (Lab 23).

## Section 4. Route Guards Reality Check

In Class 6, we examined `canActivate` route guards:

```typescript
// src/app/shared/guards/demo-auth.guard.ts
export const demoAuthGuard: CanActivateFn = () => {
  const auth = inject(DemoAuthService);
  const router = inject(Router);

  if (auth.isSignedIn()) return true;
  return router.createUrlTree(['/dashboard'], { queryParams: { reason: 'auth-required' } });
};
```

### Critical Misconception to Avoid

| What Some Developers Believe | The Architectural Reality |
| --- | --- |
| "My route guard makes my app secure." | Route guards execute purely in the **browser**. Any user can open DevTools, disable JavaScript, or send an HTTP request directly with curl or Postman. |
| "I don't need backend authentication if my route is guarded." | Backend APIs must **always** enforce authentication and authorization on every endpoint. Client guards exist strictly for user experience navigation flow. |

## Section 5. Guided Studio Time & Troubleshooting Matrix

Use the remainder of the session to repair gaps in your application slice. Instructors will circulate for 1-on-1 and group assistance.

### Final Troubleshooting Matrix

| Issue | What to Check | Solution |
| --- | --- | --- |
| **Form doesn't submit** | Invalid form controls | Check `form.valid`. Log `form.errors` or individual control `hasError()` states to console. |
| **Double submit on click** | Missing submit guard | Set an `isSubmitting = signal(false)` flag and disable the submit button while in flight. |
| **Signal not updating UI** | Direct mutation | Never push directly into an array inside a signal (`items().push(x)`). Use `.update(arr => [...arr, x])`. |
| **Memory leaks on unsubscribe** | Long-lived observables | Ensure component subscriptions use `takeUntilDestroyed(this.destroyRef)`. |
| **Route parameter not updating** | Missing input binding | Verify `provideRouter(routes, withComponentInputBinding())` is in `app.config.ts`. |

## Lab References: Simpler Isolated Examples in `wsu-test`

In `wsu-test`, navigate to `http://localhost:4200/labs` to open the **Learning Studio** catalog.

- **Lab 21 — CDK Accessibility (`/labs/cdk-a11y`)**:
  - **Route**: `http://localhost:4200/labs/cdk-a11y`
  - **Source Code**: `src/app/features/labs/cdk-a11y-lab/`
  - **What it demonstrates**: Using Angular CDK `LiveAnnouncer` to read debounced search result counts to screen readers, and `FocusMonitor` for keyboard focus state.
  - **Why consult this lab**: Best practice guide for production accessibility compliance.

- **Lab 22 — CDK Dialog (`/labs/cdk-dialog`)**:
  - **Route**: `http://localhost:4200/labs/cdk-dialog`
  - **Source Code**: `src/app/features/labs/cdk-dialog-lab/`
  - **What it demonstrates**: Accessible modal dialogs with focus trapping, `Escape` key listeners, and background scroll blocking.
  - **Why consult this lab**: Shows how to implement confirmation modals cleanly without third-party component libraries.

- **Lab 23 — Angular Standards Checklist (`/labs/angular-standards`)**:
  - **Route**: `http://localhost:4200/labs/angular-standards`
  - **Source Code**: `src/app/features/labs/angular-standards-lab/`
  - **What it demonstrates**: A comprehensive, interactive engineering standards checklist covering folder architecture, signal immutability, SRP, DRY, testing standards, and accessibility.
  - **Why consult this lab**: The ultimate pre-submission rubric review before turning in your final application.
