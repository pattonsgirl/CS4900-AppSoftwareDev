# Homework 5 - HTTP Requests & Async Programming

## Purpose / Objectives
> The purpose of this assignment is to fetch data from a remote server, handle the asynchronous response, and display it in the application. The skills being reinforced are:
> * Configuring Angular's `HttpClient`.
> * Making HTTP `GET` requests from a service.
> * Bridging RxJS `Observables` and `Signals` using `toSignal`.

## Description

Make a branch off of your GROUP UI repository or off of `lastname-homework4` named `lastname-homework5`. Perform the following tasks on this branch.

### 1. Configure HttpClient
1. Configure `HttpClient` in your application by opening `src/app/app.config.ts` and adding `provideHttpClient()` to the `providers` array.

### 2. Update Service
1. In the service you created previously, import and inject `HttpClient`.
2. Create a TypeScript `interface` that defines the shape of the data returned by your API endpoint (for example, `{ id: number, name: string, status: string }`).
3. In your service, create a method that uses `this.http.get()` to request data from your team's backend API (or a public mock API endpoint like `https://jsonplaceholder.typicode.com/` if testing independently). This method should return an `Observable` of an array of your interface type (for example, `Observable<Item[]>`).

### 3. Update Component
1. In your list component, inject your service.
2. Create a public property in your component and use the `toSignal` function to convert the `Observable` from your service into a signal. Provide an `initialValue` of an empty array (`[]`).
3. In your component's template, update the `@for` loop to iterate over the new signal holding the fetched data. Ensure your `track` expression uses a unique identifier from the API data, such as `item.id`.

### 4. git add, commit, and push
1. Push your commits, including the updated `app.config.ts`, service, and component files, to your `lastname-homework5` branch in your GROUP UI repository.

# Rubric

Assignment score: X / 5 points

- `[ ]` `HttpClient` is correctly provided to the application.
- `[ ]` The data service is updated to make an HTTP `GET` request.
- `[ ]` A TypeScript interface correctly models the API response data.
- `[ ]` The component correctly uses `toSignal` with an `initialValue`.
- `[ ]` The template successfully renders the data fetched from the remote API.

**Feedback:**
