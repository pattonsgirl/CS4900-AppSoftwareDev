# Class 1

## What students should be able to do

- Name three processes: browser, Angular app, backend
- Run the demo with `npm ci` and `npm start`
- Open `main.ts`, `app.config.ts`, `app.routes.ts`, and `app.ts` without hunting
- Change visible text, save, and see live reload

## Before class

Open these and keep them ready:

- Demo repo: `Documents/GitHub/WSU/2025/wsu-test`
- Browser at http://localhost:4200
- Terminal in the demo root
- `mr-fixit-service` on http://localhost:8080 if you can. If you cannot, that is still a teaching moment.

### Pre-class checklist

1. Node 22+ on the projector machine. `node -v`.
2. From the demo root: `npm ci`, then `npm start`. Confirm http://localhost:4200 loads `/dashboard`.
3. Confirm `src/environments/environment.ts` still says `http://localhost:8080/mr-fixit-service`.
4. Click `/dashboard`, `/work-orders/list`, `/work-orders/create` once so you know whether the API is up.
5. Have one tiny text change in mind. I use the dashboard subtitle in `dashboard.component.html`.

## Section 1. Three processes

Do this on the board before anyone opens a file.

A web app in this class is three programs that talk over the network:

1. The **browser** aka the client (Chrome, Safari, Edge). It displays HTML, runs JavaScript, and draws CSS. Students already use this.
2. The **Angular app**, served by `ng serve` on port 4200. That is TypeScript compiled to JavaScript.
3. The **backend**, `mr-fixit-service`, a Spring Boot process on port 8080. It answers HTTP with JSON.

> When you refresh the page, the browser asks 4200 for HTML and JavaScript. That is one request. Later, that JavaScript asks 8080 for work orders. That is a different request, to a different origin. If 8080 is down, 4200 can still hand you a page. You will see a spinner, then an error. The Angular app started but the data request failed.

Ask the class if anyone can define these terms:

- **Port.** A number on a machine that identifies which program should receive a connection. 4200 is Angular. 8080 is Spring. Mixing them up is the most common Class 1 confusion.
- **Origin.** Scheme + host + port. `http://localhost:4200` and `http://localhost:8080` are different origins. 
- **JSON.** JavaScript Object Notation or text shaped like JavaScript objects. The backend sends JSON. Angular turns it into TypeScript objects later (Class 3).
- DOM. Document Object Model. A cross-platform and language-independent API that represents an HTML or XML document as a hierarchical tree of objects and nodes. It allows scripting languages like JavaScript to read, change, add, or delete elements, styles, and content on a web page dynamically.

## Section 2. Terminal, npm, and Git at survival level

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

Open the running app first. Then open files. That is teaching rule 1.

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

## Section 5. Transfer into their repo

Last 20 minutes. Homework 1 starts here.

They use **their** project. A new Angular 22 app is fine. An existing frontend is fine. They do not copy `wsu-test`.

Coach this sequence:

1. Node 22+. `ng new` with routing and SCSS if they are starting fresh. Angular CLI 22.
2. `npm ci` or `npm install`, then `npm start`. Browser shows their app, usually http://localhost:4200.
3. Find the same four kinds of files: entry (`bootstrapApplication`), config (providers), routes, root component + template. Names may differ (`app.config.ts` is still typical).
4. Change a heading or a line of copy. Save. Confirm live reload.
5. README: one sentence, what a user does in this app.
6. Commit. Push. Pilot link is the deliverable.

## If they get stuck

- Wrong folder: no `package.json` after `ls`. `cd` into the app root.
- Old Node: install current LTS, reopen the terminal.
- Port in use: read the `ng serve` output. Use the URL it prints.
- Blank page: check the browser console. Startup errors from `bootstrapApplication` land there.
- Windows path pain: they can use the IDE terminal with the same commands.

## After class (ungraded)

- `/labs/resources`: Maximilian, Fireship shorts, angular.dev
- Official Node LTS installer if their machine is missing Node 22+


