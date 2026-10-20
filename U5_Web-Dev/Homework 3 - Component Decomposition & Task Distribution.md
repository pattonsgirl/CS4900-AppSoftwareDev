# Homework 3 - Component Decomposition & Task Distribution

## Purpose / Objectives
> The purpose of this assignment is to break down your team's UI/UX wireframes into a modular Angular component hierarchy and distribute component ownership across all teammates. The skills being reinforced are:
> * Decomposing UI designs into container (smart) and presentational (dumb) components.
> * Structuring Angular applications by feature folders and shared modules.
> * Configuring application routes in `src/app/app.routes.ts`.
> * Delegating individual implementation responsibilities across 3-person and 4-person teams.

## Description

Last year, one of the biggest challenges teams faced was figuring out how to break apart their application so that work could happen in parallel. When an entire UI is packed into one or two monolithic components, teammates end up stepping on each other's git branches or waiting until the last week to integrate.

In this assignment, your team will map your Unit 2 wireframes into distinct standalone components, scaffold those components in your group repository, configure routes, and assign individual ownership so each developer has a dedicated component to build out in Homework 4, 5, and 6.

Make a branch off your GROUP UI repository named `lastname-homework3`. Coordinate with your teammates to ensure no overlapping file collisions.

### 1. Decompose Your Wireframes

Review your team's UI/UX wireframes, user flows, and API endpoints. Identify the components needed to deliver your core user experience:

1. **Feature views (containers)**: Top-level screens that load data, handle route parameters, and coordinate child elements (for example: `order-list`, `order-detail`, `item-create-form`, `dashboard`).
2. **Presentational child components**: Smaller, reusable widgets that receive data via inputs and display information or emit events (for example: `status-badge`, `item-card`, `filter-bar`, `metric-card`).

Diagram or outline your component hierarchy. Note which components will be routed screens and which will be nested children.

### 2. Document Team Task Delegation

Create a markdown document named `COMPONENT_PLAN.md` in the root of your team UI repository. Document the following:

- The list of planned components and their designated folder paths.
- Assigned owner for each component across all team members:
  - **For 3-person teams**: Distribute components so each developer owns at least one major screen and associated child widget (for example: Member A owns the primary list/overview view and list-item card; Member B owns the detail view and status/action widgets; Member C owns the create/edit form and form input controls).
  - **For 4-person teams**: Distribute work across four distinct areas (for example: Member A owns the list/overview view; Member B owns the detail view and summary widgets; Member C owns the create/edit form; Member D owns search/filter controls, shared layout/navigation shell, or a secondary entity view).
- The planned data model interface each component expects to consume or emit.

### 3. Scaffold Component Shells

Each team member must generate the standalone components they own using the Angular CLI:

```bash
# Example for a feature container
ng generate component features/orders/components/order-list

# Example for a shared presentational widget
ng generate component shared/components/status-badge
```

Ensure the generated components adhere to your team folder conventions (`src/app/features/<feature-name>/components/` and `src/app/shared/components/`). Add placeholder HTML inside your assigned component template (such as an `<h2>` heading and brief text identifying the component) so the application builds cleanly.

### 4. Configure Application Routes

Open `src/app/app.routes.ts` and set up the routes that map application paths to your top-level feature components. For example:

```typescript
import { Routes } from '@angular/router';
import { OrderListComponent } from './features/orders/components/order-list/order-list.component';
import { OrderDetailComponent } from './features/orders/components/order-detail/order-detail.component';
import { OrderFormComponent } from './features/orders/components/order-form/order-form.component';

export const routes: Routes = [
  { path: '', redirectTo: 'orders', pathMatch: 'full' },
  { path: 'orders', component: OrderListComponent },
  { path: 'orders/new', component: OrderFormComponent },
  { path: 'orders/:id', component: OrderDetailComponent },
];
```

Verify that running `ng serve` compiles without errors and that navigating to each URL path in your browser loads the corresponding placeholder component.

### 5. git add, commit, and push

1. Push your component files, route updates, and `COMPONENT_PLAN.md` to your `lastname-homework3` branch in your GROUP UI repository.
2. Open a Pull Request to your team's default branch so your teammates can review the structure and verify that all assigned components are accounted for.

# Rubric

Assignment score: X / 5 points

- `[ ]` UI wireframes are decomposed into a clear hierarchy of container and presentational components.
- `[ ]` `COMPONENT_PLAN.md` is present in the repository, clearly dividing component ownership across all 3 or 4 team members.
- `[ ]` Assigned standalone component shells are generated in the correct folder structure (`features/` or `shared/components/`).
- `[ ]` Top-level routes are configured in `src/app/app.routes.ts` and load the respective components in the browser.
- `[ ]` Work is pushed to the designated `lastname-homework3` branch with clear, descriptive commit messages.

**Feedback:**
