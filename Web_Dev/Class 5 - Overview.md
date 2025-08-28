## **✅ Class 5 — Project Work, Review, and Troubleshooting**

### **Goal**

Consolidate knowledge by applying all learned skills to a cohesive project. This session is designed to be interactive, allowing for guided work time, reinforcement of key concepts, and exploration of related advanced topics based on student interest.

### **Topics**

#### 

#### **Guided Student Project Time**

The majority of this class should be dedicated to students working on their final CRUD project as outlined in the Homework 4 assignment. The instructor's role is to circulate, answer questions, and provide guidance as students encounter challenges. This hands-on time is critical for cementing the concepts learned throughout the course.

#### **1-on-1 or Group Troubleshooting**

This is an opportunity to address common stumbling blocks and misconceptions. Potential areas for review include:

* **RxJS/Signal Interop:** Clarifying why `toSignal` is used and how to handle the `initialValue`.  
* **Reactive Forms:** Debugging validation issues or problems with accessing form values.  
* **Dependency Injection:** Ensuring services are correctly provided in `app.config.ts` and injected into components.  
* **CORS Errors:** Explaining what Cross-Origin Resource Sharing (CORS) is and why it might cause HTTP requests to fail when the frontend and backend are on different origins (e.g., localhost:4200 and localhost:1800).

#### **Optional Exploration**

Based on student progress and questions, we can introduce related, more advanced topics.

* **Routing with Parameters:** For the "Update" feature of the CRUD project, students will need to handle route parameters (e.g., /items/edit/:id). This involves:  
  * Configuring the route in `app.routes.ts`: { path: 'items/edit/:id', component: ItemFormComponent }.  
  * Injecting ActivatedRoute in the component to access the id parameter from the URL.  
* **Component Lifecycle Hooks:** `ngOnInit` is just one of several hooks Angular provides to tap into a component's lifecycle. Others include `ngOnDestroy` (for cleanup), and `ngAfterViewInit` (for interacting with the rendered DOM).  
* **Performance with Deferred Loading (@defer):** This is a powerful and highly relevant modern feature. Show how to wrap a component or a section of a template in a `@defer` block to lazy-load it, improving initial application load time. Explain the different triggers (on viewport, on interaction, on hover) and the utility of the `@placeholder` and `@loading` sub-blocks for a better user experience.

```html
<button #loadTrigger>Load Details</button>

@defer (on interaction(loadTrigger)) {
  <app-heavy-details-component />
} @placeholder {
  <p>Click the button to load details.</p>
} @loading {
  <p>Loading details...</p>
}
```

#### **Reviewing and Connecting All Pieces**

Dedicate the final part of the class to a high-level review, tracing the flow of data and events through the application:

1. A user navigates to a route (/items).  
2. The **Router** activates the ListComponent.  
3. The ListComponent uses toSignal to call the DataService.  
4. The DataService uses HttpClient to make a GET request to the backend.  
5. The backend returns data. The Observable emits, and toSignal updates the component's **signal**.  
6. The template's `@for` loop reacts to the signal change and renders the list.  
7. The user fills out a **Reactive Form** and clicks submit.  
8. The (ngSubmit) **event binding** triggers a component method.  
9. The method calls a service method, passing the form data.  
10. The service makes a POST request.  
11. Upon success, the component re-fetches the list, and the cycle repeats.

#### **Best Practices Review**

Conclude with a summary of key software development principles as they apply to Angular:

* **Readability & Naming Conventions:** Use clear names for components, services, and variables.  
* **DRY (Don't Repeat Yourself):** Encapsulate reusable logic in services or helper functions.  
* **SRP (Single Responsibility Principle):** Components should focus on presentation, and services should focus on business logic and data access.  
* **Project Recommendation:** For students who want to see a complete, well-structured example, the **Angular JumpStart** repository is an excellent resource. It demonstrates many key features, including component communication, services, HTTP calls, and routing in a practical application.
