## **⚙️ Class 0 — Setup & The Anatomy of a Modern Angular App**

### **Goal**

Set up a working development environment, understand the evolution and philosophy of modern Angular, and dissect the structure of a standalone-by-default Angular project using the WSU Work Order Management application as our reference.

### **Topics**

#### **Setting the Stage: From AngularJS to Modern Angular**

Understanding Angular's evolution helps appreciate modern design decisions. The journey from AngularJS (Angular 1.x) through Angular 2+ to today's modern Angular (v14-17+) represents a strategic response to developer feedback and competitive pressures. Modern Angular is characterized by three key pillars:

1. **Standalone Components** - Eliminating mandatory `NgModule` system, reducing boilerplate
2. **Signals** - Fine-grained reactivity system for intuitive state management
3. **New Template Syntax** - Built-in control flow blocks like `@if` and `@for`

This curriculum focuses exclusively on this modern paradigm, teaching Angular the way the framework team now recommends.

#### **Core Philosophy: Opinionated, Structured, and Scalable**

Angular is an "opinionated" framework providing built-in solutions for routing, dependency injection, and data management. This contrasts with React's approach where developers select tools from the ecosystem.

**Trade-offs:**
- **Advantage**: Reduced decision fatigue, consistent architecture, excellent for enterprise applications
- **Disadvantage**: Less flexibility when you disagree with Angular's opinions

#### **Installing Node.js and npm**

Node.js is a JavaScript runtime environment enabling code execution outside browsers. npm (Node Package Manager) is essential for managing project dependencies.

Install the latest LTS version: [https://nodejs.org/](https://nodejs.org/)

#### **What is a Package Manager?**

Package managers automate installing, updating, and managing libraries. npm reads `package.json` to download dependencies into `node_modules`, ensuring consistent development environments across teams.

#### **Installing the Angular CLI**

The Angular CLI is a powerful tool for initializing, scaffolding, and maintaining applications.

```bash
npm install -g @angular/cli
```

The `-g` flag enables global installation, making the `ng` command available system-wide.

#### **Setting up the IDE (VSCode Recommended)**

Visual Studio Code offers excellent TypeScript support and Angular extensions.

* **VSCode Download:** [https://code.visualstudio.com/](https://code.visualstudio.com/)  
* **Recommended Extension:** **Angular Language Service** for code completion and error checking

#### **Two Paths: Clone the Course Repository OR Create New Project**

**Option 1: Clone the WSU Work Order Management Application (Recommended)**

Work with the complete application we'll study throughout the course:

```bash
git clone https://github.com/WSU-kduncan/mr-fixit-ui.git
cd mr-fixit-ui
npm install
ng serve
```

**Option 2: Create a New Angular Project from Scratch**

Start fresh with your own application:

```bash
ng new wsu-work-order-app
```

CLI prompts:
1. **"Would you like to add Angular routing?"** — Select **Yes**
2. **"Which stylesheet format would you like to use?"** — Select **SCSS** (recommended, used in WSU project)

#### **The Modern Project Structure**

Modern Angular eliminates the monolithic `app.module.ts` in favor of a decoupled structure with clear separation of concerns:

**`src/main.ts` - Application Entry Point**

The bootstrap file that launches the application using `bootstrapApplication()`:

```ts
import { bootstrapApplication } from '@angular/platform-browser';
import { appConfig } from './app/app.config';
import { AppComponent } from './app/app.component';

bootstrapApplication(AppComponent, appConfig)
  .catch((err) => console.error(err));
```

**`src/app/app.config.ts` - Application Configuration**

Central hub for application-wide configuration, replacing the old `AppModule`. Providers register services like routing, HTTP client, and interceptors:

```ts
export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes, withComponentInputBinding()),
    provideHttpClient(withInterceptors([retryInterceptor, errorInterceptor]))
  ]
};
```

**Key providers in the WSU application:**
- `provideRouter()` - Registers routing with automatic input binding
- `provideHttpClient()` - Configures HTTP with retry and error interceptors
- `provideZoneChangeDetection()` - Optimizes change detection performance

**`src/app/app.routes.ts` - Route Definitions**

Defines navigation mapping URL paths to components. Modern Angular uses lazy loading for optimal performance:

```ts
export const routes: Routes = [
  { 
    path: 'dashboard',
    loadComponent: () => import('./features/dashboard/dashboard.component')
      .then(m => m.DashboardComponent)
  },
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' }
];
```

**`src/app/app.component.ts` - Root Component**

The main container component marked with `standalone: true`:

```ts
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

#### **What are Standalone Components?**

Standalone components are self-contained units that don't require `NgModule` declarations. They revolutionize Angular by:

**Key Features:**
- `standalone: true` - Declares the component as self-contained
- `imports: []` - Explicitly lists template dependencies
- Direct lazy loading via router without wrapping in modules

**Benefits:**
- **Reduced Boilerplate** - Eliminates `.module.ts` files
- **Simplified Mental Model** - Dependencies declared locally in the component
- **Better Tree-Shaking** - Smaller bundle sizes, unused code removed
- **Easier Lazy Loading** - Load individual components, not entire modules

**Example: StatusBadgeComponent from WSU Application**

```ts
@Component({
  selector: 'app-status-badge',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './status-badge.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class StatusBadgeComponent {
  status = input.required<WorkOrderStatus | string>();
  size = input<'sm' | 'md' | 'lg'>('md');
  
  badgeClass = computed(() => {
    // Automatically recalculates when status or size changes
    return `badge ${this.statusClass()} badge--${this.size()}`;
  });
}
```

This component demonstrates modern Angular patterns: signal-based inputs, computed values, and standalone architecture.

#### **Interoperability with NgModules**

Angular provides seamless integration between standalone and module-based code:

- **Using standalone in modules:** Add to `imports` array (not `declarations`)
- **Using modules in standalone:** Import entire module into component's `imports`

This hybrid approach enables gradual migration and use of third-party libraries (Angular Material, Kendo UI) that may still use modules.

#### **Serving the App**

Start the development server with live reloading:

```bash
ng serve -o
```

The `-o` flag opens `http://localhost:4200` automatically. Changes to source files trigger automatic rebuild and browser refresh.

#### **Philosophy: Component-Based Architecture**

Modern front-end development builds interactive UIs from small, reusable, encapsulated **components**. Angular provides the complete structure, tools, and patterns to manage application complexity—from rendering and state management to routing and server communication. Modern Angular methodologies minimize boilerplate while maximizing performance and developer productivity.
