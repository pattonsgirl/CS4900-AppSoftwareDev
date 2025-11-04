# Assignment 3 - HTTP Requests & Async Programming

## Purpose / Objectives
> The purpose of this assignment is to learn how to fetch data from a remote server, handle the asynchronous response, and display it in the application. The skills being reinforced are:
> * Configuring Angular's `HttpClient`.
> * Making HTTP `GET` requests from a service.
> * Bridging the gap between RxJS `Observables` and `Signals` using `toSignal`.

## Description

Make a **branch** off of your GROUP UI repository OR off of `lastname-homework2` named `lastname-homework3`.  Perform the following tasks on this branch.

### 1. Configure HttpClient
1.  Configure `HttpClient` in your application by opening `src/app/app.config.ts` and adding `provideHttpClient()` to the `providers` array.

### 2. Update Service
1.  In the service you created previously, import and inject the `HttpClient`.
2.  Create a TypeScript `interface` that defines the shape of the data you will fetch from an API (e.g., `{ id: number, name: string, email: string }`).
3.  In your service, create a method that uses `this.http.get()` to request data from a public API endpoint (like `https://jsonplaceholder.typicode.com/`). This method should return an `Observable` of an array of your interface type (e.g., `Observable<User[]>`).

### 3. Update Component
1.  In your list component, inject your service.
2.  Create a public property in your component and use the `toSignal` function to convert the `Observable` from your service into a signal. You must provide an `initialValue` of an empty array (`[]`).
3.  In your component's template, update the `@for` loop to iterate over the new signal that holds the fetched data. Ensure your `track` expression uses a unique identifier from the API data, such as `item.id`.

### 4. git add, commit, and push
1.  Push your commits, including the updated `app.config.ts`, service, and component files, to your `lastname-homework3` branch in your GROUP UI repository.

# Rubric

Assignment score: X / 5 points

-   `[ ]` `HttpClient` is correctly provided to the application.
-   `[ ]` The data service is updated to make an HTTP `GET` request.
-   `[ ]` A TypeScript interface correctly models the API response data.
-   `[ ]S` The component correctly uses `toSignal` with an `initialValue`.
-   `[ ]` The template successfully renders the data fetched from the remote API.

**Feedback:**
