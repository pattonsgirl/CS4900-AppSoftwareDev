# Class 5 — Project Work & Digesting HTTP

> **Working Day 1 — No New Material Presented.**
> This session is a dedicated project work and troubleshooting workshop. We do not introduce new framework features today. Instead, students focus on digesting the HTTP concepts from Class 4, fixing live connection errors with their Spring Boot backends, and completing Homework 4.

> 💡 **Reference Application Grounding (`wsu-test`)**:
> All practical demonstrations and code samples in this session are grounded in `/Users/edjenkins/Documents/GitHub/WSU/2025/wsu-test`.
> Specific reference files:
> - `src/app/services/api.service.ts` (the low-level HTTP gateway)
> - `src/app/services/work-order.service.ts` (the domain service mapping API responses to models)
> - `src/environments/environment.ts` (specifying backend port 8080)

## Setting the Stage: The Reality of Full-Stack Integration

Connecting an Angular client running on `http://localhost:4200` to a Spring Boot backend running on `http://localhost:8080` introduces friction that never occurs with mock data:
- **CORS blocks**: The browser silently intercepts and drops responses before your TypeScript code can read them.
- **Timing glitches**: Components attempt to read properties of objects that have not arrived yet.
- **Data shape mismatches**: Spring Boot serializes fields with one naming convention (e.g. `snake_case`) while TypeScript interfaces expect another (`camelCase`), resulting in blank screens with HTTP 200 OK statuses.
- **Offline servers**: Forgetting to launch the backend leads to confusing network errors (`Status 0`).

Today is designed to unblock every student team and master browser forensic debugging.

## Section 1. Full-Stack HTTP Architecture Review

To debug effectively, trace the complete path an HTTP transaction travels from the browser UI down to the database:

```
┌────────────────────────────────────────────────────────┐
│ Browser (Frontend - localhost:4200)                    │
│                                                        │
│  [ Component Template ]                                │
│       │ reads signal state                             │
│       ▼                                                │
│  [ Domain Service ] (WorkOrderService)                 │
│       │ calls apiService.get<T>()                      │
│       ▼                                                │
│  [ Gateway Service ] (ApiService)                      │
│       │ calls httpClient.get()                         │
│       ▼                                                │
│  [ Angular HttpClient & Interceptors ]                 │
└───────────────────────────┬────────────────────────────┘
                            │ HTTP Network Request
                            │ (OPTIONS preflight if non-simple)
                            ▼
┌────────────────────────────────────────────────────────┐
│ Backend Server (Spring Boot - localhost:8080)          │
│                                                        │
│  [ Spring Security / CORS Filter ] (Validates Origin)  │
│       │                                                │
│       ▼                                                │
│  [ Controller Layer ] (@CrossOrigin, @GetMapping)      │
│       │ delegates to service                           │
│       ▼                                                │
│  [ Service & Repository ] (Spring Data JPA)            │
│       │ executes SQL query                             │
│       ▼                                                │
│  [ Database ] (PostgreSQL / H2 / MySQL)                │
└────────────────────────────────────────────────────────┘
```

## Section 2. Deep Dive: Cross-Origin Resource Sharing (CORS)

CORS is consistently the most common blocker students encounter when connecting Angular to Spring Boot.

### What is Origin?
An origin is defined by three parts: **protocol + domain (host) + port**.
- `http://localhost:4200` (Angular)
- `http://localhost:8080` (Spring Boot)

Because the ports differ (`4200` vs `8080`), these are **two distinct origins**.

### The Browser's Same-Origin Policy (SOP)
The browser's Same-Origin Policy is a fundamental security safeguard. It restricts scripts running on one origin from accessing resources on another origin unless the receiving server explicitly permits it.

**Critical Principle**: CORS is enforced by the **browser**, not by Angular. The browser sends an `Origin: http://localhost:4200` request header. If the response from `localhost:8080` lacks a matching `Access-Control-Allow-Origin` header, the browser blocks the JavaScript runtime from reading the response.

#### ⚠️ Student Survival Pitfall: Trying to Fix CORS in Angular
Never attempt to fix CORS by adding `Access-Control-Allow-Origin` headers inside your Angular `HttpClient` calls! That response header must come from the **server** (Spring Boot). Setting it in the Angular request will have zero effect.

### How to Fix CORS on the Backend (Spring Boot)

CORS must be configured on your Spring Boot application using one of two methods:

#### Method 1: Global WebMvcConfigurer (Recommended for Teams)

Create a configuration class in your Spring Boot application:

```java
package com.example.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebCorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins("http://localhost:4200")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true);
    }
}
```

#### Method 2: Controller-Level `@CrossOrigin`

Annotate your Spring REST controller directly:

```java
@RestController
@RequestMapping("/api/work_orders")
@CrossOrigin(origins = "http://localhost:4200")
public class WorkOrderController { ... }
```

## Section 3. The DevTools Network Tab: Forensic Debugging

When a network request fails, open Developer Tools (`F12`), switch to the **Network** tab, and filter by **Fetch/XHR**.

### How to Read the 5 Most Common Network Errors

1. **Status `0` / `net::ERR_CONNECTION_REFUSED`**:
   - *Cause*: The backend server is not running on port 8080, or the port number in `environment.ts` is incorrect.
   - *Fix*: Check your terminal or IDE where Spring Boot runs. Verify it is started on port 8080.
2. **CORS Error in Console (`No 'Access-Control-Allow-Origin' header`)**:
   - *Cause*: The backend responded, but did not include permission headers for `http://localhost:4200`.
   - *Fix*: Add `@CrossOrigin` or `WebMvcConfigurer` to your Spring Boot project.
3. **Status `404 Not Found`**:
   - *Cause*: The path in `ApiService` does not match the `@RequestMapping` path on your Spring controller.
   - *Fix*: Compare the exact URL requested in the Network tab with the controller mapping. Watch for missing prefixes or trailing slashes.
4. **Status `500 Internal Server Error`**:
   - *Cause*: An unhandled exception occurred in Java (NullPointerException, SQL constraint, database connection failure).
   - *Fix*: Open your Spring Boot console output to view the Java stack trace.
5. **Status `200 OK` but UI is Blank**:
   - *Cause*: Field name mismatch between JSON payload and TypeScript interface (for example, Spring serialized `first_name` while Angular expects `firstName`).
   - *Fix*: Inspect the **Response** tab in DevTools. Compare the exact property names with your TypeScript interface.

> 🧪 **Simpler Lab Reference in `wsu-test`**:
> Want to see how route parameters and query parameters bind directly to component `input()` signals without subscribing to `ActivatedRoute`? Open `http://localhost:4200/labs/route-inputs/1042` (Lab 12) in `wsu-test` (`src/app/features/labs/route-inputs-lab/`).
> For preloading route data with functional resolvers, open `http://localhost:4200/labs/resolved-work-order/1` (Lab 13).

## Section 4. Comprehensive HTTP Troubleshooting Matrix

| Symptom | Root Cause | Immediate Action |
| --- | --- | --- |
| Red error in console: `CORS policy` | Spring Boot missing CORS config | Add `@CrossOrigin(origins = "http://localhost:4200")` to Spring Controller |
| Red error: `net::ERR_CONNECTION_REFUSED` | Spring Boot is offline | Start Spring Boot app; verify port 8080 in terminal |
| `Cannot read properties of undefined` in template | Template evaluated before HTTP response arrived | Add `initialValue: []` to `toSignal()`, or use `@if (items().length > 0)` |
| `NullInjectorError: No provider for _HttpClient` | Missing provider in `app.config.ts` | Add `provideHttpClient()` to `appConfig.providers` |
| Table shows empty rows with correct number of items | DTO property naming mismatch | Compare Network tab JSON response keys with TypeScript interface fields |

## Section 5. In-Class Working Session & Verification Checklist

Use the remaining class time to work directly on your team's frontend application. Instructors will circulate to help unblock backend connection issues.

### Verification Checklist for Homework 4

- [ ] Spring Boot backend boots cleanly and serves data on `http://localhost:8080`.
- [ ] Angular app boots on `http://localhost:4200` without console errors.
- [ ] `provideHttpClient()` is declared in `src/app/app.config.ts`.
- [ ] `src/environments/environment.ts` contains your backend API base URL.
- [ ] Data service performs a typed `GET` request.
- [ ] Template handles all 4 states: Loading spinner, Error alert, Data list, and Empty list.
- [ ] DevTools Network tab displays a successful `200 OK` request when the view loads.

## Lab References: Simpler Isolated Examples in `wsu-test`

In `wsu-test`, navigate to `http://localhost:4200/labs` to open the **Learning Studio** catalog.

- **Lab 12 — Route Params as Inputs (`/labs/route-inputs/1042`)**:
  - **Route**: `http://localhost:4200/labs/route-inputs/1042`
  - **Source Code**: `src/app/features/labs/route-inputs-lab/`
  - **What it demonstrates**: Binding the `:orderId` route parameter and `?status` query parameter directly to component `input()` signals using `withComponentInputBinding()`.
  - **Why consult this lab**: Shows how to read URL parameters without injecting `ActivatedRoute` or managing subscriptions.

- **Lab 13 — Resolver + Route-Scoped State (`/labs/resolved-work-order/1`)**:
  - **Route**: `http://localhost:4200/labs/resolved-work-order/1`
  - **Source Code**: `src/app/features/labs/resolved-work-order/`
  - **What it demonstrates**: Functional router resolver preloading work-order data before component activation, and providing a route-scoped context service.
  - **Why consult this lab**: Demonstrates how to prevent UI flashes by ensuring data is resolved before navigating to a detail view.
