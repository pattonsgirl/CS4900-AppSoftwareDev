# ⚙️ Class 0 — Setup & The Anatomy of a Modern Angular App

## Setting the Stage: From AngularJS to Modern, Standalone Angular

A brief historical overview is crucial for appreciating the design decisions in the latest versions of Angular. The journey began with AngularJS (often referred to as Angular 1.x), a framework that revolutionized front-end development by introducing concepts like two-way data binding and dependency injection to a wide audience. However, its design presented challenges in performance and scalability. This led to a complete, ground-up rewrite, resulting in Angular (version 2 and beyond). This new iteration was built on a component-based architecture, prioritizing performance, modularity, and the capabilities of modern JavaScript.

The evolution did not stop there. The most recent and significant shift in the framework's philosophy is the move towards simplification and an enhanced developer experience, a trend that gained significant momentum from Angular version 14 through 17 and beyond. This modern approach is characterized by three key pillars:

1. **Standalone Components**: A move away from the mandatory `NgModule` system, reducing boilerplate and simplifying the mental model.

2. **Signals**: A new, fine-grained reactivity system that offers a more intuitive and performant way to manage state changes compared to the traditional Zone.js-based change detection.

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

## Two Paths: Clone the Course Repository OR Create a New Project

You have two options for getting started with Angular development in this course:

### Option 1: Clone the Course Repository (Recommended for Following Along)

This option allows you to work with the complete WSU Work Order Management application that we'll be studying throughout the course.

#### Step 1: Clone the Repository

In your terminal, navigate to the directory where you store your projects, then run:

```bash
git clone https://github.com/WSU-kduncan/mr-fixit-ui.git
```

**What this does:**
- `git clone` - Git command that downloads a complete copy of a repository
- The URL points to the WSU Work Order Management application on GitHub
- Creates a new folder called `mr-fixit-ui` containing all project files

#### Step 2: Open the Project

Open the cloned project folder in your code editor (e.g., VS Code):

```bash
cd mr-fixit-ui
code .
```

**Breaking this down:**
- `cd mr-fixit-ui` - Change directory into the cloned project folder
- `code .` - Opens VS Code with the current directory (`.` means current directory)
- You can also open VS Code manually and use File → Open Folder

#### Step 3: Install Dependencies

Open an integrated terminal within your code editor (inside the project's root folder) and run:

```bash
npm install
```

**What `npm install` does:**
1. Reads `package.json` file in the project root
2. Identifies all required dependencies (packages)
3. Downloads them from the npm registry
4. Installs them into a `node_modules` folder
5. Creates/updates `package-lock.json` (locks exact versions)

**Why this step is necessary:**
- The `node_modules` folder is NOT included in Git repositories (too large)
- It's listed in `.gitignore` to prevent it from being committed
- Every developer must run `npm install` after cloning to get dependencies
- This ensures everyone has the exact same package versions

**What you'll see:**
```
npm install
added 1247 packages in 45s
```
- The number of packages and time will vary
- Angular projects typically have 1000+ packages due to dependencies of dependencies

#### Step 4: Run the Application

In the same terminal, run:

```bash
ng serve
```

**What `ng serve` does:**
1. Compiles TypeScript to JavaScript
2. Bundles all files together (webpack)
3. Starts a development server on port 4200
4. Watches for file changes
5. Automatically recompiles and refreshes browser on changes

**You'll see output like:**
```
✔ Browser application bundle generation complete.
Initial chunk files | Names         | Raw size
polyfills.js        | polyfills     | 90.20 kB
main.js             | main          | 23.59 kB
styles.css          | styles        |  1.35 kB

** Angular Live Development Server is listening on localhost:4200 **
✔ Compiled successfully.
```

**Verify the application:** Open your web browser and navigate to `http://localhost:4200`

**Common issues:**
- **Port already in use:** Another app is using port 4200. Use `ng serve --port 4300` to use a different port
- **Module not found:** Run `npm install` again
- **Command not found: ng:** Angular CLI not installed globally. Run `npm install -g @angular/cli`

### Option 2: Create a New Angular Project from Scratch

If you want to start fresh and build your own application, the Angular CLI makes this simple.

#### Step 1: Generate the Project

With the CLI installed, creating a new Angular application is a single command. Since Angular version 17, the CLI defaults to creating projects with the modern standalone architecture. You can also declare this by using the `--standalone` flag.

In the terminal, navigate to a desired directory and run:

```bash
ng new wsu-work-order-app
```

**What `ng new` does:**
1. Creates a new folder with the project name
2. Initializes a Git repository
3. Creates the project structure (folders and files)
4. Generates starter components and configuration
5. Creates `package.json` with dependencies
6. Runs `npm install` automatically
7. Initializes Git with an initial commit

**The CLI will prompt you with several questions:**

**Prompt 1: "Would you like to add Angular routing?"**
```
? Would you like to add Angular routing? (y/N)
```
**Answer:** `y` (Yes)
- Adds the Angular Router package
- Creates `app.routes.ts` file
- Configures routing in `app.config.ts`
- Sets up `RouterOutlet` in root component
- **Why you want this:** Almost every real application needs routing (multiple pages/views)

**Prompt 2: "Which stylesheet format would you like to use?"**
```
? Which stylesheet format would you like to use?
  CSS
❯ SCSS   [ https://sass-lang.com/documentation/syntax#scss ]
  Sass   [ https://sass-lang.com/documentation/syntax#the-indented-syntax ]
  Less   [ http://lesscss.org ]
```
**Answer:** `SCSS` (recommended)
- SCSS is a superset of CSS (all CSS is valid SCSS)
- Adds powerful features: variables, nesting, mixins, functions
- Industry standard for Angular projects
- WSU Work Order Management project uses SCSS

**What happens after answering prompts:**
```
CREATE wsu-work-order-app/README.md
CREATE wsu-work-order-app/.gitignore
CREATE wsu-work-order-app/angular.json
CREATE wsu-work-order-app/package.json
CREATE wsu-work-order-app/tsconfig.json
CREATE wsu-work-order-app/src/main.ts
CREATE wsu-work-order-app/src/app/app.component.ts
... (many more files)

✔ Packages installed successfully.
Successfully initialized git.
```

**Time estimate:** 2-5 minutes depending on internet speed

#### Step 2: Navigate and Serve

Navigate into the newly created directory and start the development server:

```bash
cd wsu-work-order-app
ng serve -o
```

**Flag breakdown:**
- `-o` or `--open` - Automatically opens browser at `http://localhost:4200`
- Alternative: `ng serve` (then manually open browser)

**You should see:** The default Angular welcome page with:
- Angular logo
- Links to documentation
- "Next Steps" recommendations
- A list of CLI commands

**This confirms:**
✅ Angular CLI is working  
✅ Project was created successfully  
✅ Development server is running  
✅ Browser can connect to the application

## The Modern Project Structure

The project structure generated by the CLI is organized for clarity and scalability. The previous reliance on a monolithic `app.module.ts` has been replaced by a more decoupled and logical file structure that better separates concerns. This architectural improvement isolates responsibilities, making the application easier to understand and maintain.

### *src/main.ts* - Application Entry Point

This is the first file that executes. Its sole responsibility is to bootstrap, or launch, the application. It uses the `bootstrapApplication` function to start the root component (`AppComponent`). This is a significant departure from the legacy approach of bootstrapping an `NgModule`.

```ts
// src/main.ts
import { bootstrapApplication } from '@angular/platform-browser';
import { appConfig } from './app/app.config';
import { AppComponent } from './app/app.component';
   
bootstrapApplication(AppComponent, appConfig)
.catch((err) => console.error(err));
```

#### 🔍 **Detailed Code Breakdown: `main.ts`**

Let's dissect this file line by line:

**Line 1: `import { bootstrapApplication } from '@angular/platform-browser';`**
- `import` - ES6 module syntax that brings code from other files into this file
- `{ bootstrapApplication }` - Named import using destructuring. We're specifically importing ONLY the `bootstrapApplication` function, not everything from the module
- `from '@angular/platform-browser'` - This tells JavaScript where to find the code. The `@angular/` prefix means it's an official Angular package installed in `node_modules`
- `@angular/platform-browser` specifically provides Angular functionality for running in web browsers (as opposed to other platforms like mobile or server-side)

**Line 2: `import { appConfig } from './app/app.config';`**
- `./app/app.config` - The `./` means "relative to the current file". This imports from our own codebase, not from `node_modules`
- We're importing the `appConfig` object which contains all our application's configuration

**Line 3: `import { AppComponent } from './app/app.component';`**
- Imports the root component of our application
- Every Angular app has exactly ONE root component that serves as the entry point

**Line 5: `bootstrapApplication(AppComponent, appConfig)`**
- `bootstrapApplication()` - This function is what actually STARTS your Angular application
- First argument: `AppComponent` - The component class (not an instance, the class itself)
- Second argument: `appConfig` - The configuration object telling Angular how to set up the app
- This function does A LOT behind the scenes:
  1. Creates the Angular platform (sets up zone.js for change detection)
  2. Creates an instance of AppComponent
  3. Compiles the component's template
  4. Injects all required services
  5. Attaches the component to the DOM
  6. Starts the change detection system
  7. Returns a Promise that resolves when everything is ready

**Line 6: `.catch((err) => console.error(err));`**
- `.catch()` - Promise error handler. If ANYTHING goes wrong during bootstrap, we catch it here
- `(err) =>` - Arrow function that receives the error object
- `console.error(err)` - Logs the error to browser console so developers can see what went wrong
- Without this, bootstrap errors might fail silently, making debugging impossible

### *src/app/app.config.ts* - Application-Level Configuration

This file is the central hub for application-wide configuration, replacing the role previously held by the root `AppModule`. It is where services, such as the router or `HttpClient`, are made available to the entire application through an array of `providers`. This configuration is then passed to the `bootstrapApplication` function in `main.ts`.

Looking at our WSU Work Order Management application, we can see this pattern in action:

```ts
// src/app/app.config.ts
import { ApplicationConfig, provideBrowserGlobalErrorListeners, provideZoneChangeDetection } from '@angular/core';
import { provideRouter, withComponentInputBinding } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';

import { routes } from './app.routes';
import { errorInterceptor } from '@shared/interceptors/error.interceptor';
import { retryInterceptor } from '@shared/interceptors/retry.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes, withComponentInputBinding()),
    provideHttpClient(
      withInterceptors([retryInterceptor, errorInterceptor])
    )
  ]
};
```

#### 🔍 **Detailed Code Breakdown: `app.config.ts`**

Let's examine each line and understand what's happening:

**`export const appConfig: ApplicationConfig = {`**
- `export const` - Makes this constant available for import in other files (specifically `main.ts`)
- `appConfig` - The name of our configuration object
- `: ApplicationConfig` - TypeScript type annotation ensuring our object matches Angular's expected structure
- `= { ... }` - Object literal syntax defining the configuration

**`providers: [`** - An array of "provider" functions that register services with Angular's dependency injection system

**Line 1: `provideBrowserGlobalErrorListeners()`**
- Registers global error handlers for uncaught errors in the application
- When errors occur anywhere in your app, Angular can intercept and handle them gracefully
- Without this, errors might crash the app or appear as cryptic browser console messages

**Line 2: `provideZoneChangeDetection({ eventCoalescing: true })`**
- Zone.js is Angular's change detection mechanism that watches for async operations
- `eventCoalescing: true` - Performance optimization that batches multiple events together
- **What does this mean?** If multiple events fire rapidly (like mousemove + click), Angular will only check for changes ONCE instead of multiple times
- This can significantly improve performance in event-heavy applications

**Line 3: `provideRouter(routes, withComponentInputBinding())`**
- `provideRouter(routes, ...)` - Registers the Angular Router with our route configuration
- `routes` - The array of route definitions imported from `app.routes.ts`
- `withComponentInputBinding()` - Feature that allows route parameters to be automatically bound to component inputs
- **Example**: Route `/work-orders/:id` automatically provides `id` as an input signal to the component
- This replaces the old pattern of injecting `ActivatedRoute` and manually subscribing to parameter changes

**Line 4: `provideHttpClient(withInterceptors([retryInterceptor, errorInterceptor]))`**
- `provideHttpClient(...)` - Registers Angular's HTTP client for making API calls
- `withInterceptors([...])` - Configures HTTP interceptors (middleware for HTTP requests)
- **Interceptors** are like security checkpoints for your HTTP requests:
  - `retryInterceptor` - Automatically retries failed requests (e.g., if server is temporarily down)
  - `errorInterceptor` - Catches and handles HTTP errors globally (e.g., showing user-friendly error messages)
- **Order matters!** Interceptors run in the order they're listed:
  1. Request goes through retry interceptor first
  2. Then through error interceptor
  3. Then actually sent to server
  4. Response comes back through interceptors in reverse order

**Why is this architecture better?**
- **Centralized**: All HTTP error handling in ONE place, not scattered across components
- **DRY**: Don't repeat retry logic in every service method
- **Testable**: Can easily mock or disable interceptors for testing
- **Maintainable**: Change retry strategy once, affects entire app

### *src/app/app.routes.ts* - Defining Navigation

This file explicitly defines the application's navigation routes. Each route maps a URL path to a specific component. This array of routes is then imported into `app.config.ts` and provided to the application.

Our WSU application uses lazy loading for optimal performance:

```ts
// src/app/app.routes.ts
import { Routes } from '@angular/router';

export const routes: Routes = [
  // Dashboard routes - direct component loading
  {
    path: 'dashboard',
    loadComponent: () => import('./features/dashboard/dashboard.component').then(m => m.DashboardComponent)
  },

  // Work orders routes - direct component loading
  {
    path: 'work-orders',
    children: [
      {
        path: '',
        redirectTo: 'list',
        pathMatch: 'full'
      },
      {
        path: 'list',
        loadComponent: () => import('./features/work-orders/components/work-order-list/work-order-list.component').then(m => m.WorkOrderListComponent)
      },
      {
        path: 'create',
        loadComponent: () => import('./features/work-orders/components/work-order-form/work-order-form.component').then(m => m.WorkOrderFormComponent)
      },
      {
        path: ':id',
        loadComponent: () => import('./features/work-orders/components/work-order-detail/work-order-detail.component').then(m => m.WorkOrderDetailComponent)
      }
    ]
  },

  // Default redirects
  {
    path: '',
    redirectTo: '/dashboard',
    pathMatch: 'full'
  },

  // Wildcard route - must be last
  {
    path: '**',
    redirectTo: '/dashboard'
  }
];
```

### *src/app/app.component.ts* - The Root Component

This is the main component that acts as the container for the entire application. The key feature to note in its `@Component` decorator is `standalone: true`. This flag signifies that the component does not need to be declared in an `NgModule` and manages its own dependencies.

Our WSU application's root component is clean and focused:

```ts
// src/app/app.component.ts
import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ErrorNotificationComponent } from '@shared/components/error-notification/error-notification.component';

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

## What are Standalone Components?

Standalone components are a streamlined way to build Angular applications. They are self-contained units that are not declared in any `NgModule` and, consequently, must manage their own template dependencies directly.

This paradigm was introduced to solve a major pain point in the Angular ecosystem: the cognitive overhead and boilerplate associated with `NgModules`. For many developers, especially those new to the framework, `NgModules` represented an extra, often confusing, layer of abstraction. It wasn't always clear why a component needed to be declared in a separate class (`.module.ts`) just to be used.

The benefits of adopting standalone components are substantial and address these historical criticisms directly:

- **Reduced Boilerplate**: The most immediate advantage is the elimination of `.module.ts` files for many features and components. This leads to a cleaner, more concise project structure.

- **Simplified Mental Model**: Developers can focus solely on the component they are building. Its dependencies are declared explicitly and locally within the component file itself, making it easier to reason about what a component needs to function.

- **Improved Performance and Tree-Shaking**: Because dependencies are declared on a per-component basis, the Angular compiler has a much clearer view of what is actually being used. This allows for more effective tree-shaking (the process of removing unused code from the final bundle), resulting in smaller application sizes. This is a significant improvement over the common pattern of large, shared modules that often caused many unused components or services to be included in the main bundle.

- **Simplified Lazy Loading**: It is now possible to lazy-load a single component directly via the router, without the need to wrap it in an `NgModule`. This makes code-splitting more granular and easier to implement.

Think of `NgModules` as toolboxes. To use a single screwdriver, you have to bring the entire toolbox, which might contain many other tools you don't need. This adds weight and complexity. Standalone components are like individual, high-quality tools. If you need a screwdriver, you grab just the screwdriver. It's self-contained, lightweight, and ready to use immediately.

### Anatomy of a Standalone Component

The transition to a standalone architecture is enabled by two key properties within the `@Component` decorator:

1. `standalone: true`: This boolean flag is the core of the feature. When set to `true`, it informs the Angular compiler that this component is self-contained and should not be declared in an `NgModule`. Attempting to declare a standalone component in a module's `declarations` array will result in a compiler error.

2. `imports:`: This array is where a standalone component declares its template dependencies. If the component's HTML template uses another component, a directive (like `@if` or `*ngFor`), or a pipe, that dependency must be imported directly into this array. This makes the component's dependencies explicit and co-located with its definition.

Let's examine our `StatusBadgeComponent` from the WSU project to see this in action:

```ts
// src/app/shared/components/status-badge/status-badge.component.ts
import { Component, input, computed, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { WorkOrderStatus } from '@shared/models';

@Component({
  selector: 'app-status-badge',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './status-badge.component.html',
  styleUrl: './status-badge.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class StatusBadgeComponent {
  status = input.required<WorkOrderStatus | string>();
  size = input<'sm' | 'md' | 'lg'>('md');

  badgeClass = computed(() => {
    const baseClass = 'badge';
    const statusClass = this.statusClass();
    const sizeClass = this.size() !== 'md' ? `badge--${this.size()}` : '';

    return [baseClass, statusClass, sizeClass].filter(Boolean).join(' ');
  });

  private readonly statusClass = computed(() => {
    const status = this.status();
    switch (status) {
      case WorkOrderStatus.OPEN:
      case 'OPEN':
      case 'OPN':
        return 'badge--status-open';
      case WorkOrderStatus.IN_PROGRESS:
      case 'IN_PROGRESS':
      case 'NPRGRS':
        return 'badge--status-in-progress';
      case WorkOrderStatus.COMPLETED:
      case 'COMPLETED':
      case 'CMPLTD':
        return 'badge--status-completed';
      case WorkOrderStatus.CANCELLED:
      case 'CANCELLED':
      case 'CNCLD':
        return 'badge--status-cancelled';
      default:
        return 'badge--status-open';
    }
  });

  statusText = computed(() => {
    const status = this.status();
    switch (status) {
      case WorkOrderStatus.OPEN:
      case 'OPEN':
      case 'OPN':
        return 'Open';
      case WorkOrderStatus.IN_PROGRESS:
      case 'IN_PROGRESS':
      case 'NPRGRS':
        return 'In Progress';
      case WorkOrderStatus.COMPLETED:
      case 'COMPLETED':
      case 'CMPLTD':
        return 'Completed';
      case WorkOrderStatus.CANCELLED:
      case 'CANCELLED':
      case 'CNCLD':
        return 'Cancelled';
      default:
        return 'Open';
    }
  });
}
```

#### 🔍 **Detailed Code Breakdown: `StatusBadgeComponent`**

This component is a masterclass in modern Angular patterns. Let's dissect it piece by piece:

**`@Component({ ... })` Decorator**
- Decorators are TypeScript features that add metadata to classes
- The `@Component` decorator tells Angular "this class is a component"
- Everything inside the decorator configures how the component works

**`selector: 'app-status-badge'`**
- Defines the HTML tag name for this component
- Usage: `<app-status-badge></app-status-badge>` in templates
- Convention: prefix with `app-` to avoid conflicts with native HTML elements

**`standalone: true`**
- **THIS IS THE MAGIC** that makes it a standalone component
- Means: "I don't need to be declared in an NgModule"
- Allows: Direct import into other components
- Old way: Would need to create/modify a module file just to use this component

**`imports: [CommonModule]`**
- Lists what THIS component needs in its template
- `CommonModule` provides common Angular directives like `ngIf`, `ngFor`, etc.
- **Important**: Each standalone component declares its OWN dependencies
- This is different from modules where imports were shared across many components

**`changeDetection: ChangeDetectionStrategy.OnPush`**
- **Performance optimization!**
- Default: Angular checks component for changes ALL THE TIME
- OnPush: Only check when:
  1. An input changes
  2. An event fires in this component
  3. An observable emits (async pipe)
  4. Manual trigger via `ChangeDetectorRef`
- **Result**: Massively reduces unnecessary checks, especially in large component trees

**`status = input.required<WorkOrderStatus | string>()`**
- `input.required()` - NEW signal-based input (Angular 17+)
- `required` - This input MUST be provided or Angular throws an error
- `<WorkOrderStatus | string>` - TypeScript generic: accepts either the enum OR a string
- Returns an `InputSignal<WorkOrderStatus | string>` - a read-only signal
- **Old way**: `@Input() status!: WorkOrderStatus | string;` (not reactive)
- **New way**: Automatically reactive, no need for ngOnChanges lifecycle hook

**`size = input<'sm' | 'md' | 'lg'>('md')`**
- Optional input with default value
- `<'sm' | 'md' | 'lg'>` - String literal union type (only these 3 values allowed)
- `('md')` - Default value if not provided
- TypeScript will error if you try to pass anything other than 'sm', 'md', or 'lg'

**`badgeClass = computed(() => { ... })`**
- `computed()` creates a **derived signal** that automatically recalculates
- **When does it recalculate?** Whenever any signal it depends on changes
- Dependencies: `this.statusClass()` and `this.size()`
- **Memoized**: Only recalculates if dependencies actually changed
- **Lazy**: Doesn't calculate until someone reads the value

**Inside the computed function:**
```ts
const baseClass = 'badge';  // Always included
const statusClass = this.statusClass();  // Reads another computed signal
const sizeClass = this.size() !== 'md' ? `badge--${this.size()}` : '';  // Conditional class
return [baseClass, statusClass, sizeClass].filter(Boolean).join(' ');
```
- `.filter(Boolean)` - Removes empty strings from array
- `.join(' ')` - Combines array into space-separated string
- **Result**: Something like `"badge badge--status-open badge--sm"`

**`private readonly statusClass = computed(() => { ... })`**
- `private` - Only accessible within this class
- `readonly` - Cannot be reassigned (but computed values can change)
- Uses a switch statement to map status codes to CSS classes
- **Why multiple cases per status?** Handles different status formats:
  - Enum values (`WorkOrderStatus.OPEN`)
  - String values (`'OPEN'`)
  - Backend codes (`'OPN'`)

**`statusText = computed(() => { ... })`**
- Similar pattern to `statusClass`
- Maps status codes to human-readable text
- Used in template: `{{ statusText() }}`
- **Notice**: Called as a function `statusText()` not a property
- This is how you read signal values!

**The Power of Signals in This Component:**
1. **Reactive**: When parent changes `[status]` input, everything updates automatically
2. **Efficient**: Only recalculates what's needed, when it's needed
3. **Type-safe**: TypeScript catches errors at compile time
4. **Composable**: Signals can depend on other signals creating a reactive chain
5. **No lifecycle hooks**: No need for `ngOnChanges`, `ngOnInit`, etc.

**Usage Example:**
```html
<app-status-badge 
  [status]="workOrder.status.code"  <!-- Binds to status input -->
  size="sm">                         <!-- Binds to size input -->
</app-status-badge>
```

**What happens when status changes?**
1. Parent component changes `workOrder.status.code`
2. `status` input signal detects change
3. `statusClass` computed signal recalculates (depends on `status`)
4. `statusText` computed signal recalculates (depends on `status`)
5. `badgeClass` computed signal recalculates (depends on `statusClass` and `size`)
6. Template automatically re-renders with new classes and text
7. All this happens in MICROSECONDS with minimal CPU usage

It is important to note that this pattern extends beyond components. Directives and pipes can also be marked as `standalone: true` in their respective decorators (`@Directive` and `@Pipe`), allowing them to be imported and used in the same self-contained manner.

### Interoperability: Using NgModules in a Standalone World (The Hybrid Approach)

The transition to standalone components was designed to be gradual and non-disruptive. Angular provides excellent interoperability between the new standalone paradigm and the traditional `NgModule`-based architecture, allowing for a "hybrid" approach.

There are two primary scenarios for this interoperability:

1. **Using a Standalone Component in an `NgModule`-based Application**: If you are working in an existing application that uses `NgModules`, you can still create and use new standalone components. To do so, you simply add the standalone component class to the `imports` array of the relevant `NgModule`. You do _not_ add it to the `declarations` array.

2. **Using an `NgModule`-based Component in a Standalone Component**: This is a very common scenario, especially when using third-party component libraries (e.g., Angular Material, Kendo UI, Ignite UI) that may still be distributed as `NgModules`. To use a component from such a library, you import the entire `NgModule` that exports it directly into your standalone component's `imports` array.

This hybrid model is not a temporary workaround but a deliberate, strategic bridge. The Angular framework has a massive, mature ecosystem of applications and libraries built upon `NgModules`. A "big bang" migration that deprecated `NgModules` overnight would have been catastrophic for the community. Instead, the Angular team engineered the standalone APIs for full interoperability from their inception. This allows teams to adopt the new paradigm incrementally, writing new features with standalone components within their existing applications, or starting new standalone projects while still leveraging the rich ecosystem of `NgModule`-based libraries. This thoughtful migration path underscores the Angular team's commitment to stability and their deep understanding of the constraints faced in real-world, enterprise-level software development.
