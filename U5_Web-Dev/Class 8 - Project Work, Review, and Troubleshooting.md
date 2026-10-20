# Class 8: Project Work, Review, and Troubleshooting

> **Working Day 2: Consolidation & Integration Workshop**
> This is our final session of the Web Development module before Thanksgiving break. We do not introduce new framework features today. This class is dedicated to consolidating your full-stack slice from Homework 1 through Homework 6, auditing accessibility and keyboard navigation, verifying clean-install instructions in your project README, and troubleshooting with instructors.
> *(Thursday, November 26 is Thanksgiving — no class).*

> **Reference Application Grounding**:
> All architectural standards and best practices reviewed today are demonstrated in [Mr Fix It UI](https://github.com/WSU-kduncan/mr-fixit-ui):
> - `src/app/features/work-orders/` (complete master-detail flow: list, detail, and form)
> - `src/app/services/work-order.service.ts` (central domain service)
> - `src/app/shared/components/` (accessible status badges and loading indicators)

---

## Consolidating the Full-Stack Slice

Over the past seven classes, you built a modern, standalone Angular application from the ground up:

1. **Class 1**: Web fundamentals, project bootstrapping, CLI toolchain, and the anatomy of modern Angular.
2. **Class 2**: Component decomposition, scoped SCSS, and modern control flow (`@if`, `@for`).
3. **Class 3**: Reactivity with Signals (`signal`, `computed`), event bindings, and injectable services.
4. **Class 4**: Asynchronous HTTP data fetching with `HttpClient` and Observable-to-Signal bridges (`toSignal`).
5. **Class 5**: *Working Day 1* — CORS diagnostics, Network tab inspection, and connection resilience.
6. **Class 6**: The full round trip: master-detail routing, Reactive Forms, and HTTP `POST` submission.
7. **Class 7**: Production engineering: automated Jest testing and client-side pagination.

Today's goal is to ensure your entire stack functions as a cohesive, resilient product.

---

## Section 1: Reviewing the Complete Data Loop

Before handing off your project or submitting final coursework, trace the complete data cycle in your application:

```
[ User Interaction ] 
       │ (clicks button, types into reactive form)
       ▼
[ Component State ] 
       │ (signals update, form validation evaluates)
       ▼
[ Domain Service ] 
       │ (manages business logic, dispatches HTTP call)
       ▼
[ Gateway / HttpClient ] 
       │ (serializes JSON, transmits request)
       ▼
[ Spring Boot API & Database ] 
       │ (persists entity, returns 200/201 response)
       ▼
[ UI Confirmation ] 
       │ (signals update, router navigates, list refreshes)
```

Every layer has a distinct responsibility. When something fails, follow this chain step by step to identify where the break occurred.

---

## Section 2: The Clean-Install Verification

A project is only ready for review if another software engineer can clone the repository, install dependencies, and run it with zero friction.

### Clean-Install Checklist

Test your repository in a fresh directory:

1. **Prerequisites**: Does your `README.md` clearly state that **Node.js 22+** is required?
2. **Installation Command**: Does `npm ci` (or `npm install`) succeed without dependency errors?
3. **Run Command**: Does `npm start` start the local server and open cleanly at `http://localhost:4200`?
4. **Backend URL**: Does your `README.md` or `environment.ts` document the exact backend server URL (`http://localhost:8080/...`) expected by your services?
5. **Clear Commit History**: Do your git commits reflect incremental progress rather than a single monolithic commit at the end?

---

### Checkpoint: Clean-Install Sanity Check

> **Question**: Why is `npm ci` preferred over `npm install` for verifying a clean install?
>
> **Answer**: `npm ci` strictly adheres to `package-lock.json`, deleting any existing `node_modules` and installing exact versions. `npm install` may attempt to update versions within range prefixes (`^`), which can cause inconsistencies between teammates' machines.

---

## Section 3: Accessibility and Polish Audit

A solid frontend application handles keyboard users, screen readers, and clear visual cues gracefully.

### 1. Keyboard Navigation
- Unplug or ignore your mouse and navigate your entire application flow using only `Tab`, `Shift+Tab`, `Enter`, and `Space`.
- Can every form input, dropdown, link, and button be focused and activated?
- Are links marked with `<a routerLink="...">` and action buttons marked with `<button type="button">`?

### 2. Visible Focus Indicators
- Does every active element show a clear, visible focus outline when tabbed into?
- Avoid setting `outline: none` in CSS without providing an explicit `:focus-visible` replacement.

### 3. Accessible Form Controls
- Does every `<input>`, `<select>`, and `<textarea>` have an associated `<label for="...">` with a matching `id`?
- Placeholders are brief hints, not labels. A field with only a `placeholder` attribute fails basic accessibility standards.

### 4. Asynchronous Error Notifications
- When an HTTP request fails, does a visible error alert appear on the screen with `role="alert"`?
- Relying solely on `console.error()` leaves users staring at an unresponsive screen when the server is down.

---

## Section 4: Route Guards vs. Backend Security

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

### Essential Security Boundary

| Assumption | Engineering Reality |
| --- | --- |
| "A route guard secures my application." | Route guards execute entirely in the **browser**. Anyone can open DevTools, disable scripts, or issue an HTTP request directly with curl or Postman. |
| "I don't need backend authentication if my routes are guarded." | Backend APIs must **always** enforce authentication and authorization on every endpoint. Client guards exist strictly for UI navigation and UX flow. |

---

## Section 5: Guided Workshop & Troubleshooting Quick-Reference

Spend the remainder of class working with your team on completing and polishing Homework 1 through Homework 6. Instructors will circulate for 1-on-1 assistance.

| Issue | What to Check | Solution |
| --- | --- | --- |
| **Form doesn't submit** | Invalid form controls | Inspect `form.valid`. Log `form.errors` or check individual control `hasError()` states to identify invalid fields. |
| **Double submit on button click** | Missing submit state guard | Track an `isSubmitting = signal(false)` flag and bind `[disabled]="form.invalid || isSubmitting()"` to the submit button. |
| **Signal not updating UI** | Direct array mutation | Never push directly into an array inside a signal (`items().push(x)`). Use `.update(arr => [...arr, x])` to emit a new reference. |
| **Memory leaks from subscriptions** | Unclosed observables | Use `toSignal()` where possible, or pass `{ injector }` or `takeUntilDestroyed()`. |
| **Route parameter not binding** | Missing router config | Verify `provideRouter(routes, withComponentInputBinding())` is present in `app.config.ts`. |
