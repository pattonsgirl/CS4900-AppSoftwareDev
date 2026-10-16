# Class 1

## Setting the Stage: From AngularJS to Modern, Standalone Angular

A brief historical overview is crucial for appreciating the design decisions in the latest versions of Angular. The journey began with AngularJS (often referred to as Angular 1.x), a framework that revolutionized front-end development by introducing concepts like two-way data binding and dependency injection to a wide audience. However, its design presented challenges in performance and scalability. This led to a complete, ground-up rewrite, resulting in Angular (version 2 and beyond). This new iteration was built on a component-based architecture, prioritizing performance, modularity, and the capabilities of modern JavaScript.

The evolution did not stop there. The most recent and significant shift in the framework's philosophy is the move towards simplification and an enhanced developer experience, a trend that gained significant momentum from Angular version 14 through 17 and beyond. This modern approach is characterized by three key pillars:

1. **Standalone Components**: A move away from the mandatory `NgModule` system, reducing boilerplate and simplifying the mental model.

2. **Signals**: A new, fine-grained reactivity system that offers a more intuitive and performant way to manage state changes compared to the traditional Zone.js-based change detection.6

3. **New Template Syntax**: Built-in control flow blocks like `@if` and `@for` that are more ergonomic and no longer require module imports.


This curriculum is firmly rooted in this modern paradigm. The focus is on building applications the way the Angular team now recommends, an approach that is not only simpler and more powerful but also aligns Angular more closely with the broader JavaScript ecosystem, making it more approachable for developers coming from other frameworks.

This evolution is not merely a collection of new features; it represents a strategic response to the web development landscape. Early versions of Angular (v2-v13), while powerful, were often criticized for a steep learning curve and the cognitive overhead associated with `NgModules`. Competing frameworks like React and Vue gained traction partly due to their component-centric models, which were perceived as simpler. The introduction of Standalone Components, Signals, and simplified control flow is a direct and deliberate effort by the Angular team to address these criticisms. It is a strategic initiative to lower the barrier to entry, enhance day-to-day developer productivity, and shift the narrative around Angular from being "heavy and corporate" to "modern and efficient." This demonstrates that the framework is actively shedding legacy complexities to maintain its competitive edge and appeal to a broader developer audience.

## Core Philosophy: Opinionated, Structured, and Scalable

Angular is often described as an "opinionated" framework. This means it provides a clear, built-in, and well-defined structure for building applications. It has its own solutions for critical aspects like routing, dependency injection, and data management, which are integrated directly into the framework.

This contrasts sharply with less opinionated libraries such as React, where the developer is responsible for selecting and integrating these fundamental pieces from a vast third-party ecosystem. The trade-off is clear:

- **Advantage of Angular's approach**: Reduced decision fatigue for developers. Teams can get started faster without debating which routing or state management library to use. This leads to a highly consistent architecture across different projects and teams, which is a significant advantage in large, enterprise-scale applications where maintainability and developer onboarding are paramount.

- **Disadvantage**: Less flexibility. If a developer disagrees with Angular's "opinion" on a certain architectural aspect, overriding it can be more complex than choosing an alternative in a less structured ecosystem.

This inherent structure is a core strength, making Angular a premier choice for complex applications that require long-term maintenance and collaboration among large development teams.

## Installing Node.js and npm

The foundation of any modern web development environment is Node.js. It serves as a JavaScript runtime environment, allowing developers to execute JavaScript code outside of a web browser. Bundled with Node.js is npm (Node Package Manager), the world's largest software registry. Npm is an essential tool for managing project dependencies—the external libraries and tools an application relies on.

Students must install the latest Long-Term Support (LTS) version of Node.js from the official website:

- **Node.js Downloads:** [https://nodejs.org/](https://nodejs.org/)

## What is a Package Manager?

A package manager like npm automates the process of installing, updating, and managing the libraries (packages) a project needs. It reads a configuration file, `package.json`, which lists all dependencies. When a command like `npm install` is run, npm downloads the correct versions of these packages from its registry and places them in a `node_modules` folder within the project. This ensures that every developer working on the project has the exact same set of tools, creating a consistent and reproducible development environment.

## Setting up the IDE (VSCode Recommended)

A capable Integrated Development Environment (IDE) is crucial for productivity. Visual Studio Code (VSCode) is highly recommended for Angular development due to its excellent TypeScript support and a rich ecosystem of extensions.

- **VSCode Download:** [https://code.visualstudio.com/](https://code.visualstudio.com/)

- **Recommended Extension:** The official **Angular Language Service** extension provides code completion, navigation, and real-time error checking within templates, significantly improving the development experience.

## Installing the Angular CLI

The Angular Command Line Interface (CLI) is a powerful tool for initializing, developing, scaffolding, and maintaining Angular applications. It handles complex configuration and build processes, allowing developers to focus on writing code.

To install the CLI globally on a machine, students should open their terminal or command prompt and run:

```bash
npm install -g @angular/cli
```

The `-g` flag signifies a global installation, making the `ng` command available anywhere on the system. As of Angular version 7, the major versions of the Angular core framework and the CLI are aligned, ensuring compatibility.

## Generating the First Angular Project

With the CLI installed, creating a new Angular application is a single command. Since Angular version 17, the CLI defaults to creating projects with the modern standalone architecture. You can also declare this by using the `--standalone` flag.

In the terminal, navigate to a desired directory and run:

```bash
ng new test-app
```

## The Modern Project Structure

The project structure generated by the CLI is organized for clarity and scalability. The previous reliance on a monolithic `app.module.ts` has been replaced by a more decoupled and logical file structure that better separates concerns. This architectural improvement isolates responsibilities, making the application easier to understand and maintain.

> 💡 **Reference Application Grounding (`wsu-test`)**:
> All practical demonstrations and code samples in this course are grounded in the reference repository at `/Users/edjenkins/Documents/GitHub/WSU/2025/wsu-test`. 
> In addition to the production-style WSU Work Order Management application, `wsu-test` includes a dedicated **Learning Studio** at `/labs` hosting 24 isolated, minimal teaching labs (`00` through `23`). When you want to see any concept or technique stripped down to its bare essentials in a clean environment, open the corresponding lab.

## Section 1. Three processes

A web app in this class is three programs that talk over the network:

1. The **browser** aka the client (Chrome, Safari, Edge). It displays HTML, runs JavaScript, and draws CSS. Students already use this.
2. The **Angular app**, served by `ng serve` on port 4200. That is TypeScript compiled to JavaScript.
3. The **backend**, `mr-fixit-service`, a Spring Boot process on port 8080. It answers HTTP with JSON.

> When you refresh the page, the browser asks 4200 for HTML and JavaScript. That is one request. Later, that JavaScript asks 8080 for work orders. That is a different request, to a different origin. If 8080 is down, 4200 can still hand you a page. You will see a spinner, then an error. The Angular app started but the data request failed.

Ask the class if anyone can define these terms:

- **Port.** A number on a machine that identifies which program should receive a connection. 4200 is Angular. 8080 is Spring. Mixing them up is the most common Class 1 confusion.
- **Origin.** Scheme + host + port. `http://localhost:4200` and `http://localhost:8080` are different origins. 
- **JSON.** JavaScript Object Notation or text shaped like JavaScript objects. The backend sends JSON. Angular turns it into TypeScript objects later (Class 3).
- **DOM.** Document Object Model. A cross-platform and language-independent API that represents an HTML or XML document as a hierarchical tree of objects and nodes. It allows scripting languages like JavaScript to read, change, add, or delete elements, styles, and content on a web page dynamically.

## Section 2. Terminal and npm

Stay in the demo root. Do not jump into `src/` yet.

### Commands they need today

```bash
cd /path/to/wsu-test
ls
node -v
npm ci
npm start
```

What each one does:

- `cd` changes directory. If `ls` does not show `package.json`, you are in the wrong folder.
- `ls` lists files. They should see `package.json`, `angular.json`, `src/`.
- `node -v` must be 22 or higher. Angular 22 wants that. If they have Node 18, stop and install LTS. Do not debug Angular errors on an old Node.
- `npm ci` installs from `package-lock.json`. Prefer this over `npm install` in a repo that already has a lockfile. `ci` means "clean install from the lockfile," not "continuous integration magic."
- `npm start` runs the `start` script in `package.json`, which is `ng serve`. Default URL: http://localhost:4200.

When `ng serve` is healthy, the terminal prints the URL and "watching for file changes." Leave that terminal running. Open a second terminal for Git.

If `npm start` fails:

- `EADDRINUSE` means something already owns 4200. Find the other `ng serve` or use the port it prints.
- Missing `node_modules` means they skipped `npm ci`.
- `ng: command not found` is fine. They should use `npm start`, which uses the local CLI in `node_modules`.

Checkpoint:

>"What file proves you are in an npm project?" 
>`package.json`.
 
 >"Which command starts the Angular server in this repo?" 
 >`npm start` or `ng serve`

## Section 3. How the app boots

> The browser loaded some HTML. That HTML has a tag called `app-root`. Angular replaces that tag with our application. I want you to see the chain from that tag to the dashboard.

### `src/index.html`

```html
<body>
  <app-root></app-root>
</body>
```

`app-root` is empty on purpose. It is a custom element. The `App` component's selector is `app-root`, so Angular mounts the shell there.

### `src/main.ts`

This file runs once when the bundle loads.

```typescript
import { bootstrapApplication } from '@angular/platform-browser';
import { appConfig } from './app/app.config';
import { App } from './app/app';

bootstrapApplication(App, appConfig)
  .catch((err) => console.error(err));
```

Walk it:

- `bootstrapApplication` is the Angular function that starts a standalone app. There is no `NgModule` bootstrap in this project.
- First argument `App` is the root component class from `app.ts`.
- Second argument `appConfig` is the providers object from `app.config.ts`.
- `.catch` logs a startup failure. If this runs, you will see a stack in the console.

Checkpoint: 

>"Which file runs first after the JavaScript bundle loads?" 
>`main.ts`.

### `src/app/app.config.ts`

Glance only. Name two providers. Do not unpack interceptors or zoneless theory.

```typescript
export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    { provide: ErrorHandler, useExisting: ErrorBoundaryService },

    provideZonelessChangeDetection(),

    provideRouter(routes, withComponentInputBinding()),

    provideHttpClient(
      withXhr(),
      withInterceptors([retryInterceptor, errorInterceptor])
    )
  ]
};
```

>**Providers** are app-wide services Angular can inject later. Think "things every screen is allowed to use."
>
`provideRouter(routes)` wires the URL table from `app.routes.ts`.
>
`provideHttpClient(...)` makes HTTP available. We will use it in Class 3. Today, just knowing it exists is enough.
>
`provideZonelessChangeDetection()` is an Angular 22 default. The running app does not load `zone.js`. Jest still does, in `setup-jest.ts`. We will not get into this today so for now we are going to leave it alone and will bring it up again in class 5.

### `src/app/app.routes.ts`

This is the table of URLs.

```typescript
export const routes: Routes = [
  {
    path: 'dashboard',
    loadComponent: () =>
      import('./features/dashboard/dashboard.component').then(m => m.DashboardComponent)
  },
  {
    path: 'work-orders',
    children: [
      { path: '', redirectTo: 'list', pathMatch: 'full' },
      { path: 'list', loadComponent: () => import('...WorkOrderListComponent') },
      { path: 'create', canActivate: [demoAuthGuard], loadComponent: () => import('...WorkOrderFormComponent') },
      { path: ':id', loadComponent: () => import('...WorkOrderDetailComponent') }
    ]
  },
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: '**', redirectTo: '/dashboard' }
];
```

Walk the student-relevant paths. Skip lazy-loading theory for now. `loadComponent` means "download this screen when the user goes there."

| URL they type or click | What they see                                                                |
| ---------------------- | ---------------------------------------------------------------------------- |
| `/`                    | Redirects to `/dashboard`                                                    |
| `/dashboard`           | Summary stats                                                                |
| `/work-orders`         | Redirects to `/work-orders/list`                                             |
| `/work-orders/list`    | Cards of work orders                                                         |
| `/work-orders/create`  | Create form. There is a `canActivate` guard. Name it. Explain it in Class 5. |
| `/work-orders/1`       | Detail for order 1. `:id` is a placeholder.                                  |
| anything else          | Redirects to `/dashboard`                                                    |

`canActivate: [demoAuthGuard]` is on create. Say: "There is a gate on that URL. Next week is signals and guards will be discussed in Class 5."

`/labs` exists and we will showcase those a bit later as they break down a bunch of the different topics we will be discussing in a singular location. 

Checkpoint:

>"If I go to `/`, where do I land?" 
>Dashboard.
>
"Which file decides that?" 
`app.routes.ts`.

### `src/app/app.ts` and `src/app/app.html`

Root shell. Always on screen.

```typescript
@Component({
  selector: 'app-root',
  imports: [RouterOutlet, ErrorNotificationComponent],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  protected title = 'wsu-test';
}
```

```html
<main class="app">
  <router-outlet></router-outlet>
  <app-error-notification></app-error-notification>
</main>
```

Walk it:

- `@Component` is metadata. `selector: 'app-root'` matches `index.html`.
- `imports` lists what this template is allowed to use. `RouterOutlet` is required for routing. `ErrorNotificationComponent` is our toast host.
- `<router-outlet>` is a hole. The router drops the current page into it. Dashboard, list, form, detail all render here, one at a time.
- `<app-error-notification>` stays visible across navigations. That is why toasts are not trapped inside one page.

Angular 22 defaults: you do **not** write `standalone: true` or `changeDetection: ChangeDetectionStrategy.OnPush` on every component. New apps already work that way. This demo follows that. We can get into change detection in a future class if you have more questions.

Checkpoint: 

>"Where does the dashboard HTML actually appear in the DOM?" 
>Inside `<router-outlet>`, which lives in `app.html`.

### `src/environments/environment.ts`

```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080/mr-fixit-service'
};
```

This is the base URL for every REST call. `ApiService` concatenates `${apiUrl}/${endpoint}`. The list GET becomes:

`http://localhost:8080/mr-fixit-service/work_order`

Checkpoint:

>"If I change 8080 to 8081 and the backend is still on 8080, what happens?" 
>The UI will still load but the JSON request will fail.

## Section 4. Click through the running app

Keep DevTools closed unless you need them. This block is navigation, not HTTP.

1. Open http://localhost:4200. You should land on `/dashboard`.
2. Point at the heading. That text is `welcomeMessage()` in the dashboard component. Do not unpack `computed` yet. "This screen is a component. Class 1 is components."
3. Click **View All**. URL becomes `/work-orders/list`. That is the route table you just showed.
4. Click **New Work Order**. URL becomes `/work-orders/create`. If the guard lets you through (it will, demo student is signed in by default), they see the form.
5. Use the breadcrumb or Dashboard link to go back.

If the API is **running**: stats and cards have numbers and titles. We do not need to explain `reloadWorkOrders()`.

If the API is **down**: dashboard shows "Unable to load dashboard" and a Retry button. List shows a similar error. Say:

> The shell rendered, our routing worked and the request for JSON failed. That is three processes, not a broken Angular install. If this happens on homework, you can reach out to myself and Ryan.

### Live reload

In the editor, change a visible string. I change the dashboard subtitle:

```html
<p class="page-subtitle">Here's a summary of the current maintenance status on campus.</p>
```

to something obviously wrong, like `Here's the Class 1 live-reload check.` Save. The browser updates without a manual refresh. Then revert it, or commit it as a demo and revert later.

If live reload does not fire: they saved a file the app is not using, or `ng serve` died.


> 🧪 **Simpler Lab Reference in `wsu-test`**:
> Want to explore curated developer guides, video walkthroughs, and official documentation? Visit `http://localhost:4200/labs/resources` (Lab 00) in `wsu-test` (`src/app/features/labs/resources-lab/`).

## Section 5. Transfer into students repo

They use **their** project and will be creating a new Angular 22 app.

Sequence:

1. Node 22+. `ng new` with routing and SCSS if they are starting fresh. Angular CLI 22.
2. `npm ci` or `npm install`, then `npm start`. Browser shows their app, usually http://localhost:4200.
3. Find the same four kinds of files: entry (`bootstrapApplication`), config (providers), routes, root component + template. Names may differ (`app.config.ts` is still typical).
4. Change a heading or a line of copy. Save. Confirm live reload.
5. README: one sentence, what a user does in this app.
6. Commit. Push. Pilot link is the deliverable.

## Lab References: Simpler Isolated Examples in `wsu-test`

In `wsu-test`, navigate to `http://localhost:4200/labs` to open the **Learning Studio** catalog.

- **Lab 00 — Resources & Reference Hub (`/labs/resources`)**:
  - **Route**: `http://localhost:4200/labs/resources`
  - **Source Code**: `src/app/features/labs/resources-lab/`
  - **What it demonstrates**: An isolated reference hub linking directly to primary Angular documentation, Maximilian Schwarzmüller's video courses, Fireship Angular shorts, and CSS layout guides.
  - **Why consult this lab**: When setting up your workstation or looking for quick video explanations of modern Angular architecture, this lab gathers high-trust resources without searching the web.
