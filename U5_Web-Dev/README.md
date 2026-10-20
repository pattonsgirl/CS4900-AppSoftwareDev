# Web design module overview

Fall 2026. Eight classes starting Thursday, October 29.

This module introduces front-end web development with modern Angular, focusing on standalone components, signals for reactive state management, and typed reactive forms. Students build their team frontend against the Spring Boot REST API created in the previous module.

The course reference application is [Mr Fix It UI](https://github.com/WSU-kduncan/mr-fixit-ui), which runs against the [mr-fixit-service](https://github.com/WSU-kduncan/mr-fixit-service) backend.

## Schedule

| Class | Date | Topic | Homework | Notes |
| :---: | --- | --- | --- | --- |
| 1 | Thu Oct 29 | Setup and the anatomy of a modern Angular app | [Homework 1](Homework%201%20-%20Setup%20Verification.md) | [Class 1](Class%201%20-%20Setup%20%26%20The%20Anatomy%20of%20a%20Modern%20Angular%20App.md) |
| 2 | Tue Nov 3 | File and component structure | [Homework 2](Homework%202%20-%20HTML%2C%20CSS%20%26%20Modern%20Templates.md) | [Class 2](Class%202%20-%20File%20and%20Component%20Structure.md) |
| 3 | Thu Nov 5 | Behavior and state with signals | [Homework 3](Homework%203%20-%20Component%20Decomposition%20%26%20Task%20Distribution.md) | [Class 3](Class%203%20-%20Behavior%20%26%20State%20Management%20with%20Signals.md) |
| 4 | Tue Nov 10 | HTTP requests and async | [Homework 4](Homework%204%20-%20Component%20Logic%2C%20Signals%20%26%20Services.md) | [Class 4](Class%204%20-%20HTTP%20Requests%20%26%20Async%20Programming.md) |
| 5 | Thu Nov 12 | Project work: Digesting HTTP | [Homework 5](Homework%205%20-%20HTTP%20Requests%20%26%20Async%20Programming.md) | [Class 5](Class%205%20-%20Project%20Work%20%26%20Digesting%20HTTP.md) |
| 6 | Tue Nov 17 | Data round trip and full-stack display | [Homework 6](Homework%206%20-%20Full%20CRUD%20Interaction.md) | [Class 6](Class%206%20-%20Data%20Round%20Trip%20%26%20Full-Stack%20Display.md) |
| 7 | Thu Nov 19 | Wildcard: Testing and pagination | In class | [Class 7](Class%207%20-%20Testing%20with%20Jest%20%26%20Client-Side%20Pagination.md) |
| 8 | Tue Nov 24 | Project work, review, and troubleshooting | Group UI Final | [Class 8](Class%208%20-%20Project%20Work%2C%20Review%2C%20and%20Troubleshooting.md) |
| -- | Thu Nov 26 | Thanksgiving Break (no class) | -- | -- |

## Class summaries

### Class 1: Setup and the anatomy of a modern Angular app
- Web applications as three connected processes: the browser client, Angular dev server on port 4200, and Spring Boot backend on port 8080.
- Node.js LTS, npm package management, and running projects with `npm ci` and `ng serve`.
- Root entry points: `index.html`, `main.ts`, `app.config.ts`, `app.routes.ts`, and `app.ts`.
- Hands-on setup verification and initializing each team's frontend repository.

### Class 2: File and component structure
- Component architecture: separating structure (HTML), presentation (SCSS), and behavior (TypeScript).
- Standalone components using the `@Component` decorator and explicit imports.
- Modern template control flow: `@for` with required `track` expressions, `@if`, and `@empty`.
- Nesting presentational child components inside feature containers.

### Class 3: Behavior and state with signals
- Angular signals for local reactivity: reading values with `()`, updating with `.set()` and `.update()`.
- Two-way user interaction: DOM event binding with `(click)` and `(input)`.
- Component communication using modern signal `input()` and derived state with `computed()`.
- Extracting state and manipulation methods from components into injectable singleton services.

### Class 4: HTTP requests and async programming
- Registering `provideHttpClient()` in `app.config.ts`.
- Injecting `HttpClient` into services to execute typed HTTP `GET` requests.
- Converting RxJS Observables into Angular signals with `toSignal` and setting safe initial values.
- Handling asynchronous loading states and rendering data in templates.

### Class 5: Project work and digesting HTTP
- Dedicated lab session with no new lecture topics to resolve HTTP integration questions.
- Debugging cross-origin resource sharing (CORS) between Angular (port 4200) and Spring Boot (port 8080).
- Verifying endpoint URLs against the team API definition document and displaying live records in team views.

### Class 6: Data round trip and full-stack display
- Building typed data entry forms with `ReactiveFormsModule` and `FormBuilder`.
- Client-side validation with `Validators.required` and disabling submit buttons on invalid input.
- Sending data mutations (`POST`, `PUT`, `DELETE` or domain-specific equivalents) to backend controllers.
- Refreshing UI signals following successful mutations to keep views synchronized with the database.

### Class 7: Wildcard: Testing and pagination
- Automated testing practices using Jest for Angular components and services.
- Writing unit assertions for component inputs, DOM rendering, and service method calls.
- Implementing client-side pagination: managing page state, calculating total pages, and slicing visible arrays.

### Class 8: Project work, review, and troubleshooting
- Final in-class integration and debugging session before Thanksgiving.
- Resolving edge cases in data flows, forms, and service error handling.
- Verifying keyboard accessibility, clear error feedback, and clean project builds.
- Preparing the group UI repository for final milestone evaluation.

## Homework sequence

1. **[Homework 1: Setup Verification](Homework%201%20-%20Setup%20Verification.md)**: Use [Mr Fix It UI](https://github.com/WSU-kduncan/mr-fixit-ui) as the reference, confirm it runs and filters, then scaffold the team's own Angular app in the group UI repository. That app is what later homework builds on.
2. **[Homework 2: HTML, CSS & Modern Templates](Homework%202%20-%20HTML%2C%20CSS%20%26%20Modern%20Templates.md)**: Generate a standalone component, practice template rendering with `@for` and `track`, apply scoped SCSS styling, and use `@if` conditionals.
3. **[Homework 3: Component Decomposition & Task Distribution](Homework%203%20-%20Component%20Decomposition%20%26%20Task%20Distribution.md)**: Break the team application wireframes into distinct Angular components, establish routes, and delegate component ownership across all 3 or 4 team members so work proceeds in parallel.
4. **[Homework 4: Component Logic, Signals & Services](Homework%204%20-%20Component%20Logic%2C%20Signals%20%26%20Services.md)**: Manage interactive state with writable signals, build a child detail component with signal `input()`, and extract state operations into an injectable service.
5. **[Homework 5: HTTP Requests & Async Programming](Homework%205%20-%20HTTP%20Requests%20%26%20Async%20Programming.md)**: Wire `HttpClient` into services, fetch remote API data, and transform Observables into template signals using `toSignal`.
6. **[Homework 6: Full CRUD Interaction](Homework%206%20-%20Full%20CRUD%20Interaction.md)**: Connect a reactive form to backend mutation endpoints (Create and Update/Delete depending on the team's project domain) and refresh UI lists upon response.
