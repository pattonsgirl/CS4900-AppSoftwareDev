## **🧠 Class 2 — Behavior & State Management with** 

## **Signals**

### 

### **Goal**

Understand how to add dynamic functionality to components using event binding and manage application state reactively with Angular Signals. Introduce services for logic encapsulation and modern, signal-based component inputs.

### **Topics**

#### **What are Signals? The New Reactive Primitive**

Angular Signals are the new foundation for reactivity in the framework. A signal is a wrapper around a value that can notify interested consumers when that value changes. This system allows Angular to perform highly efficient, fine-grained updates to the UI. Instead of checking an entire component for changes, Angular knows exactly which parts of the DOM depend on a specific signal and updates only those parts when the signal's value is modified. This approach simplifies the mental model for developers: change a value, and the UI updates automatically, without the need to manually manage subscriptions or change detection cycles.

#### **Writable Signals**

A writable signal is a signal whose value can be changed directly.

* **Creation:** You create a signal using the `signal()` function from `@angular/core`, providing an initial value.

```ts
// In a component class
count = signal(0);
```

* **Reading:** To read a signal's value, you call it like a function. This syntax is crucial, as it's how Angular tracks where the signal is being used.

```html
<p>The current count is: {{ count() }}</p>
```

* **Updating:** There are two primary methods for updating a writable signal's value:  
  * **.set(newValue)**: Replaces the current value with a new one. `this.count.set(5);`  
  * **.update(updateFn**): Computes a new value based on the current value. This is safer for state transitions that depend on the previous state. `this.count.update(currentValue => currentValue + 1);`

#### **Event Binding ((click), (input))**

Event binding allows components to respond to user actions. The syntax uses parentheses around the event name, such as (click) or (input). This binding connects a DOM event to a method in the component's TypeScript class.

```html
<button (click)="increment()">Increment</button>
```

```ts
// In the component class
import { signal } from '@angular/core';

export class CounterComponent {
  count = signal(0);

  increment() {
    this.count.update(value => value + 1);
  }
}
```

#### **Computed Signals**

A computed signal is a read-only signal that derives its value from other signals. It automatically updates whenever any of its dependency signals change. Computed signals are both lazily evaluated (the calculation only runs when the value is requested) and memoized (the result is cached and only recalculated if a dependency changes), making them highly efficient.

```ts
// In the component class
count = signal(5);
doubleCount = computed(() => this.count() * 2); // Will be 10
isEven = computed(() => this.count() % 2 === 0); // Will be false
```

When `count` is updated, `doubleCount` and `isEven` will automatically reflect the new derived values without any extra code.

#### **Parent → Child Communication with input()**

The modern, signal-based way to pass data from a parent component to a child is with the input() function. It is a direct and more reactive replacement for the traditional @Input() decorator. When you use input(), the property in the child component becomes a read-only signal (InputSignal) that always holds the latest value passed down from the parent.

**Child Component:**

```ts
// src/app/user-profile/user-profile.component.ts
import { Component, input } from '@angular/core';

@Component({ /*... */ })
export class UserProfileComponent {
  // Creates a required signal input of type string
  username = input.required<string>();
}
```

**Parent Component Template:**

```html
<app-user-profile [username]="currentUser()" />
```

This approach makes component inputs inherently reactive. Instead of using the ngOnChanges lifecycle hook to react to input changes, one can now use a computed signal or an effect that directly depends on the input signal, leading to cleaner and more declarative code.

#### **Introduction to Services and Dependency Injection**

A **service** is a class designed to organize and share business logic, models, or data and functions with other parts of an application. It helps to keep components lean by abstracting away tasks like fetching data from a server or logging.

* **Creation:** Use the CLI: `ng generate service data`. This creates a class with an `@Injectable()` decorator.  
* **Providing the Service:** To make a service available throughout the application, it must be "provided." In a modern standalone application, this is done in [`app.config.ts`](http://app.config.ts):

```ts
// src/app/app.config.ts
import { DataService } from './data.service';

export const appConfig: ApplicationConfig = {
  providers: // Add the service here
};
```

* **Injecting the Service:** To use a service within a component, you use dependency injection. The modern and recommended way is to use the inject() function.

```ts
// In a component class
import { inject } from '@angular/core';
import { DataService } from './data.service';

export class MyComponent {
  private dataService = inject(DataService);
  //... now you can call methods on this.dataService
}

```
