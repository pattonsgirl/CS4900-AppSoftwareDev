## **🌐 Class 3 — HTTP Requests & Async Programming**

### **Goal**

Understand how to communicate with backend APIs asynchronously using Angular's HttpClient and integrate the resulting data streams (Observables) into the component's reactive state (Signals).

### **Topics**

#### **What is an HTTP Request?**

An HTTP (Hypertext Transfer Protocol) request is the mechanism by which a client (like an Angular application running in a browser) communicates with a server to request or send data. The most common types of requests, or "verbs," for a full-stack application are:

* **GET:** Retrieve data from the server.  
* **POST:** Send new data to the server to create a resource.  
* **PUT / PATCH:** Send data to update an existing resource.  
* **DELETE:** Request that the server delete a resource.

#### **The HttpClient Service**

Angular provides a dedicated service, `HttpClient`, for making HTTP requests. It is a simplified client HTTP API that rests on the `XMLHttpRequest` interface exposed by browsers. Its major features include the ability to request typed response values, streamlined error handling, and request/response interception.

To use `HttpClient`, it must be made available to the application's dependency injection system. In a modern standalone application, this is done by calling `provideHttpClient()` within the providers array in `app.config.ts`.

```ts
// src/app/app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideHttpClient } from '@angular/common/http';

export const appConfig: ApplicationConfig = {
  providers: [
    //... other providers
    provideHttpClient()
  ]
};

```

#### **What is an Observable? Subscribing to API Responses**

When you make a request with `HttpClient`, it does not return the data directly. Instead, it returns an **RxJS Observable**. An Observable is a powerful construct for managing asynchronous operations. It represents a stream of data that may arrive over time.

A key characteristic of `HttpClient` Observables is that they are "cold." This means the HTTP request is not actually sent until a piece of code **subscribes** to the Observable.

```ts
// In a data service
import { inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export class DataService {
  private http = inject(HttpClient);

  getItems(): Observable<Item> {
    return this.http.get<Item>('https://api.example.com/items');
  }
}
```

In this example, calling `getItems()` does not send the request. It only returns the Observable object. The request is sent when `subscribe()` is called on that object.

#### **The Bridge: Converting Observables to Signals with toSignal**

While Observables are essential for handling the asynchronous nature of HTTP requests, Angular Signals are the preferred primitive for managing component state. The `@angular/core/rxjs-interop` package provides the essential `toSignal` function to bridge this gap.

The `toSignal` function subscribes to an Observable and converts its emissions into a signal. It automatically handles the subscription and, crucially, unsubscribes when the component is destroyed, preventing memory leaks. This is the recommended pattern for consuming HTTP data in modern components.

```ts
// In a component
import { Component, inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { DataService } from './data.service';

@Component({ /*... */ })
export class ItemListComponent {
  private dataService = inject(DataService);

  // Convert the Observable from the service into a signal.
  // The request is made when the component is initialized.
  public items = toSignal(
    this.dataService.getItems(),
    { initialValue: } // Provide an initial value while waiting for the response
  );
}
```

The `initialValue` option is required because a signal must always have a value, but the HTTP response will not be available synchronously. The signal will hold this initial value until the Observable emits, at which point the signal's value will be updated to the data from the server.

#### **Error Handling Basics**

Network requests can fail. `HttpClient` captures these errors in an `HttpErrorResponse` and sends them through the Observable's error channel. When using `toSignal`, the signal will hold the error object if the Observable errors. The template can then check for this error state.

```html
@if (items.error()) {
  <p>Failed to load items. Error: {{ items.error().message }}</p>
} @else {
  <ul>
    @for (item of items(); track item.id) {
      <li>{{ item.name }}</li>
    }
  </ul>
}
```

More advanced error handling, such as retrying failed requests, can be accomplished using RxJS operators like retry before the toSignal conversion.
