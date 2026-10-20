# Class 5: Project Work & Digesting HTTP

> **Working Day 1: Troubleshooting & Integration Workshop**
> This session is dedicated project work. We do not introduce new framework syntax today. Instead, we focus on connecting Angular to your Spring Boot backend, resolving real-world HTTP errors, and making steady progress on Homework 5.

> **Reference Application Grounding**:
> Practical examples and architectural patterns in this session align with the reference repository [Mr Fix It UI](https://github.com/WSU-kduncan/mr-fixit-ui):
> - `src/app/services/api.service.ts` (generic HTTP communication gateway)
> - `src/app/services/work-order.service.ts` (domain service transforming API data into signals)
> - `src/environments/environment.ts` (API base URL pointing to port 8080)

---

## The Reality of Full-Stack Integration

Switching from static mock arrays in memory to dynamic network calls introduces failure modes that never happen in isolation:

1. **CORS blocks**: The browser receives a response from Spring Boot, but refuses to let your Angular TypeScript code read it.
2. **Timing glitches**: A component tries to render an object property before the async HTTP response has returned from the server.
3. **Data shape mismatches**: Spring Boot serializes a field as `first_name` or `customer_id`, while your TypeScript interface expects `firstName` or `customerId`, leaving table rows blank despite a `200 OK` status.
4. **Offline backends**: Forgetting to launch your Spring Boot server leads to immediate `net::ERR_CONNECTION_REFUSED` (Status `0`) errors.

Our goal today is to walk through these failure modes, learn how browser DevTools reveal the root cause, and resolve any connection hurdles across student teams.

---

## Section 1: Full-Stack HTTP Architecture Review

When debugging a broken screen, trace the entire route an HTTP transaction travels from the browser down to the database:

```
┌────────────────────────────────────────────────────────┐
│ Browser (Frontend - localhost:4200)                    │
│                                                        │
│  [ Component Template ]                                │
│       │ reads signal state (e.g. workOrders())         │
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

If the screen is blank, the breakdown could be in any one of these layers. DevTools tells you whether the issue occurred before leaving the browser, during transit, or inside Spring Boot.

---

## Section 2: Understanding Cross-Origin Resource Sharing (CORS)

CORS errors are the most common hurdle teams face during initial integration.

### What is an Origin?

An origin is defined by three components: **protocol + domain (host) + port**.

- Frontend: `http://localhost:4200`
- Backend: `http://localhost:8080`

Because the ports differ (`4200` vs `8080`), the browser classifies them as **two distinct origins**.

### The Same-Origin Policy (SOP)

Web browsers enforce the Same-Origin Policy as a baseline security protection. By default, JavaScript executing on `http://localhost:4200` is forbidden from reading data returned from `http://localhost:8080` unless the server explicitly grants permission.

**Key Rule**: CORS is enforced by the **browser**, not Angular. 

1. Angular sends a standard HTTP request. The browser automatically appends an `Origin: http://localhost:4200` header.
2. The Spring Boot backend processes the request and sends back a response.
3. The browser inspects the response headers. If it does not find `Access-Control-Allow-Origin: http://localhost:4200` (or `*`), the browser drops the response and logs a red security error in the console.

> **Common Misconception**: You cannot fix a CORS error by adding headers inside your Angular `HttpClient` request. `Access-Control-Allow-Origin` is a **response** header that must come from the server.

### Configuring CORS in Spring Boot

To resolve CORS, configure your Spring Boot application using either of the following approaches.

#### Approach A: Global WebMvcConfigurer (Recommended)

Add a configuration class to your Spring Boot project to cover all endpoints:

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

#### Approach B: Controller-Level `@CrossOrigin`

If you want to allow requests on specific endpoints, annotate the controller directly:

```java
@RestController
@RequestMapping("/api/work_orders")
@CrossOrigin(origins = "http://localhost:4200")
public class WorkOrderController {
    // controller endpoints...
}
```

---

### Checkpoint: CORS Verification

> **Question**: If you open your browser console and see `Access to XMLHttpRequest at 'http://localhost:8080/api/orders' from origin 'http://localhost:4200' has been blocked by CORS policy`, which project needs code changes?
>
> **Answer**: The Spring Boot backend. The server must include the `Access-Control-Allow-Origin` response header. Modifying Angular client code will not resolve this.

---

## Section 3: Inspecting Requests with the Network Tab

When a request fails, press `F12` (or right-click and choose **Inspect**), navigate to the **Network** tab, and filter by **Fetch/XHR**.

### Diagnosing the 5 Most Common Network Results

1. **Status `0` / `net::ERR_CONNECTION_REFUSED`**:
   - **Root Cause**: The browser could not establish a TCP connection to `localhost:8080`.
   - **Fix**: Check your terminal or IDE running Spring Boot. Verify the application started without errors and is listening on port 8080.
2. **CORS Error in Console (`No 'Access-Control-Allow-Origin' header present`)**:
   - **Root Cause**: The server replied, but omitted CORS permission headers for `http://localhost:4200`.
   - **Fix**: Add `@CrossOrigin` or a `WebMvcConfigurer` to Spring Boot.
3. **Status `404 Not Found`**:
   - **Root Cause**: The endpoint path requested by Angular does not match any `@RequestMapping` or `@GetMapping` path in Spring.
   - **Fix**: Compare the exact URL in the DevTools Network tab against the Spring controller annotation. Look for spelling differences, missing `/api` prefixes, or trailing slashes.
4. **Status `500 Internal Server Error`**:
   - **Root Cause**: Spring Boot received the request, but crashed with an unhandled Java exception (e.g., `NullPointerException`, JPA syntax error, database connection refusal).
   - **Fix**: Switch to your Spring Boot terminal and read the Java stack trace.
5. **Status `200 OK` but UI is Blank or Undefined**:
   - **Root Cause**: The network request succeeded, but the JSON payload keys do not match the properties declared on your TypeScript interface.
   - **Fix**: Click on the request in the Network tab and open the **Response** preview. Check whether the backend is returning snake_case (e.g., `work_order_id`) while your TypeScript interface expects camelCase (`workOrderId`).

---

## Section 4: Troubleshooting Quick-Reference

| Symptom | Root Cause | Immediate Action |
| --- | --- | --- |
| Red console error: `CORS policy` | Spring Boot missing CORS config | Add `@CrossOrigin(origins = "http://localhost:4200")` to Spring Controller or add `WebMvcConfigurer` |
| Red error: `net::ERR_CONNECTION_REFUSED` (Status 0) | Spring Boot is not running | Start the Spring Boot backend; confirm it is listening on port 8080 |
| `Cannot read properties of undefined` in template | Template tried to read data before the HTTP response finished | Provide `initialValue: []` inside `toSignal()`, or guard the section with `@if (items().length > 0)` |
| `NullInjectorError: No provider for _HttpClient` | `provideHttpClient()` missing from application config | Add `provideHttpClient()` to the `providers` array in `src/app/app.config.ts` |
| Table shows the correct number of rows, but every cell is blank | Key naming mismatch between Java DTO and TypeScript interface | Compare DevTools Response JSON keys with your TypeScript model fields |

---

## Section 5: Workshop Checklist for Homework 5

Spend the remainder of class working with your team on your frontend integration. Use this checklist to verify your application:

- [ ] Spring Boot boots cleanly and serves data on `http://localhost:8080`.
- [ ] Angular app boots on `http://localhost:4200` without console errors.
- [ ] `provideHttpClient()` is configured in `src/app/app.config.ts`.
- [ ] `src/environments/environment.ts` contains the API base URL.
- [ ] Data service performs a typed `GET` request matching the Spring DTO.
- [ ] Component handles all 4 states: Loading spinner, Error alert, Data rows, and Empty state message.
- [ ] DevTools Network tab records a clean `200 OK` status when the screen loads.
