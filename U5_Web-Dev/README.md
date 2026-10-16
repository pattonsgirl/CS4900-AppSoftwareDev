# Web design module outline

Fall 2026. Eight classes, starting Thursday, October 29. Class 1 is the setup class. Later classes reuse last year's notes where the topic still matches, then we fill in examples from `wsu-test` and the in-class labs.

`wsu-test` at `GitHub/WSU/2025/wsu-test` is the reference app. Last year's notes still clone `mr-fixit-ui`. We keep that clone path for Homework 1 unless we decide students should start from `wsu-test` instead.

## Schedule

| Class | Date | Topic | Homework | Notes |
| --- | --- | --- | --- | --- |
| 1 | Thu Oct 29 | Setup and the anatomy of a modern Angular app | Homework 1 | [Class 1](Class%201%20-%20Setup%20%26%20The%20Anatomy%20of%20a%20Modern%20Angular%20App.md) |
| 2 | Tue Nov 3 | File and component structure | Homework 2 | [Class 2](Class%202%20-%20File%20and%20Component%20Structure.md) |
| 3 | Thu Nov 5 | Behavior and state with signals | Homework 3 | [Class 3](Class%203%20-%20Behavior%20%26%20State%20Management%20with%20Signals.md) |
| 4 | Tue Nov 10 | HTTP requests and async | Homework 4 | [Class 4](Class%204%20-%20HTTP%20Requests%20%26%20Async%20Programming.md) |
| 5 | Thu Nov 12 | Working Day 1: Project work & digesting HTTP (no new material) | Finish HW 4 | [Class 5](Class%205%20-%20Project%20Work%20%26%20Digesting%20HTTP.md) |
| 6 | Tue Nov 17 | Data round trip and full-stack display | Homework 5 | [Class 6](Class%206%20-%20Data%20Round%20Trip%20%26%20Full-Stack%20Display.md) |
| 7 | Thu Nov 19 | Wildcard: Testing with Jest and client-side pagination | In class | [Class 7](Class%207%20-%20Testing%20with%20Jest%20%26%20Client-Side%20Pagination.md) |
| 8 | Tue Nov 24 | Working Day 2: Project work, review, troubleshooting (no new material) | Group UI | [Class 8](Class%208%20-%20Project%20Work%2C%20Review%2C%20and%20Troubleshooting.md) |
|  | Thu Nov 26 | No class. Thanksgiving |  |  |

Homework 1 through 4 follow Classes 1 through 4. Homework 5 follows the data round trip class on November 17. November 12 is a working session for the HTTP class, because that is where the questions pile up. November 24 is the later project day, after the round trip and the wildcard class. The group project compilation is the module deliverable after that.

## Class 1. Setup and the anatomy of a modern Angular app

The class note is the lesson plan: [Class 1 - Setup & The Anatomy of a Modern Angular App](Class%201%20-%20Setup%20%26%20The%20Anatomy%20of%20a%20Modern%20Angular%20App.md). Students should leave with a running demo, the boot files named, and Homework 1 started in their own repo.

Teach in the room:

- Three processes: browser, Angular on port 4200, Spring on port 8080.
- `npm ci` and `npm start`. Node 22+.
- `src/index.html`, `src/main.ts`, `src/app/app.config.ts`, `src/app/app.routes.ts`, `src/app/app.ts`, `src/environments/environment.ts`.
- Click dashboard, list, and create. Then a live-reload edit.
- Last 20 minutes in their project. They do not copy `wsu-test`.

Leave for later: signals, interceptors, the create guard, and HTTP. Name the guard. Do not explain it.

## Class 2. File and component structure

The class note is [Class 2 - File and Component Structure](Class%202%20-%20File%20and%20Component%20Structure.md). Students learn where code lives and how one component uses another. They need enough template syntax to finish Homework 2. They do not need signals, services, forms, or HTTP yet.

Teach in the room:

- The folder map. `features/` for screens, `shared/components/` for pieces used in more than one feature, `shared/models/` for types, `services/` for data access.
- A component is a folder: `.ts`, `.html`, `.scss`, and usually a spec.
- The `@Component` metadata we actually use: `selector`, `imports`, `templateUrl`, `styleUrl`.
- Using a child: import the class, add it to `imports`, put the selector in the parent template.
- `ng generate component`.
- Template syntax Homework 2 requires: interpolation, a CSS class on the repeated element, `@if`, and `@for` with `track`.

`wsu-test` files to walk once we write the example:

- `src/app/app.ts` and `src/app/app.html` for the shell. `RouterOutlet` and `ErrorNotificationComponent` are already in `imports`.
- `src/app/shared/components/status-badge/` for a small component with a selector and a template.
- `src/app/features/work-orders/components/work-order-list/` for a feature folder. Open it to show the three files. Do not teach the list's paging or HTTP on this day.
- `src/app/app.routes.ts` only to show that a URL points at a component folder.

## Class 3. Behavior and state with signals

The class note is [Class 3 - Behavior & State Management with Signals](Class%203%20-%20Behavior%20%26%20State%20Management%20with%20Signals.md). This is where the UI starts reacting to the user.

- Writable signals: `signal()`, read with `()`, write with `.set()` and `.update()`.
- Event binding, `(click)` and `(input)`.
- `computed()`.
- Parent to child with `input()`.
- A first service and `inject()`.

`wsu-test` targets for the walkthrough: `status-badge` for `input()` and `computed()`, `work-order-list` for writable signals such as `currentPage` and `pageSize`, and `src/app/features/labs/ui-state-lab/` as an optional lab.

## Class 4. HTTP requests and async

The class note is [Class 4 - HTTP Requests & Async Programming](Class%204%20-%20HTTP%20Requests%20%26%20Async%20Programming.md). One path through the stack is enough for the class.

- GET, POST, PUT, DELETE, named against the work-order API.
- `provideHttpClient()` in `app.config.ts`.
- A service method that returns an Observable.
- Landing that result in a signal, either with `toSignal` or by subscribing and calling `.set()`.
- What a failed request looks like in the UI.

`wsu-test` targets: `src/app/services/api.service.ts`, `src/app/services/work-order.service.ts`, `src/environments/environment.ts`, and `src/app/features/labs/http-resource-lab/` as the optional lab.

Interceptors stay out of the required path. `retry.interceptor.ts` and `error.interceptor.ts` are there if someone asks.

## Class 5. Working Day 1: Project work & digesting HTTP

The class note is [Class 5 - Project Work & Digesting HTTP](Class%205%20-%20Project%20Work%20%26%20Digesting%20HTTP.md). Thursday, November 12. Working Day 1 — no new material presented. The HTTP class produces the most questions, so this meeting is dedicated to digesting that material before we add forms and the rest of the round trip.

Stay on the GET path from Class 4:

- `provideHttpClient()` is actually in their `app.config.ts`.
- A service method returns an Observable, and the component lands it in a signal with `toSignal` or `.set()`.
- `initialValue` is an empty array so the template can render before the response arrives.
- CORS between the Angular dev server and their API.
- A list on the group UI that renders rows from their GET.

`wsu-test` files to reopen while helping: `work-order.service.ts`, `api.service.ts`, and `work-order-list`. The form, POST, and DELETE wait for the next class.

## Class 6. Data round trip

The class note is [Class 6 - Data Round Trip & Full-Stack Display](Class%206%20-%20Data%20Round%20Trip%20%26%20Full-Stack%20Display.md). Tuesday, November 17. This is the class where the form belongs. Homework 5 follows this meeting.

- Load on `ngOnInit`.
- Show the list with `@for`.
- Reactive form: `FormBuilder`, `Validators.required`, submit disabled while invalid.
- POST, then refresh the list. DELETE the same way.
- UPDATE as the stretch that Homework 5 already marks optional.

`wsu-test` targets: `work-order-form`, `work-order-list`, and `work-order-detail`. `src/app/features/labs/signal-forms-lab/` is the newer form lab if we want to show signal forms beside reactive forms. Homework 5 still asks for `ReactiveFormsModule`, so that stays the required pattern.

## Class 7. Wildcard: Testing and pagination

The class note is [Class 7 - Testing with Jest & Client-Side Pagination](Class%207%20-%20Testing%20with%20Jest%20%26%20Client-Side%20Pagination.md). Thursday, November 19. Wildcard in-class session. Automated testing and client-side pagination are covered as production practices. No new homework.

- Pagination already in `work-order-list`: `currentPage`, `pageSize`, `totalPages`, and the methods that change them.
- A component spec next to a simple component, starting with `status-badge.component.spec.ts` or `work-order.service.spec.ts`. Show what the test calls and what it asserts.
- If the room is ahead, `src/app/features/labs/virtual-scroll-lab/` is the list-performance follow-on. `@defer` is the other optional topic already sketched in the existing project-work notes.

## Class 8. Working Day 2: Project work, review, troubleshooting

The class note is [Class 8 - Project Work, Review, and Troubleshooting](Class%208%20-%20Project%20Work%2C%20Review%2C%20and%20Troubleshooting.md). Tuesday, November 24. Working Day 2 — no new material presented. It is the last meeting before Thanksgiving.

The HTTP questions were handled on November 12. This day is for the round trip they just built.

- Reactive form validation and reading `form.value`.
- POST and DELETE against their API, then a refreshed list.
- A written note of the exact error if a group is blocked.
- Accessibility, keyboard navigation, and clean-install verification before final project completion.

## What we do next

The outline is the cut. Class 1's note matches the lesson plan. Next pass is the examples, one class at a time, starting with Class 2: a short walk through the `wsu-test` folders above, then a small in-class lab that generates a component and renders it.
