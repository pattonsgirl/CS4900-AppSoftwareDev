# Assignment 0 - Setup Verification

## Purpose / Objectives

> The purpose of this assignment is to ensure your development environment is working correctly and that you can successfully run and edit a baseline Angular project. This reinforces the core developer workflow of editing code and seeing live updates.

## Description

Perform the following tasks in your course **homework** repository.

1.  Use the project you have generated for this course.
2.  Open a terminal within the project's root folder.
3.  Run the command `npm install` to download all necessary project dependencies.
4.  Run the command `ng serve` to compile the application and start the development server.
5.  Verify that the application is running in your web browser, typically at `http://localhost:4200`.
6.  Open the file `src/app/app.component.html` and change some of the text to something personal, like your name or a favorite quote.
7.  Save the file and verify that your change appears automatically in the browser without a manual refresh.
8.  Explore the project files to identify the key parts of a modern Angular application:
    -   Find the `bootstrapApplication` call in `src/main.ts`.
    -   Observe how the router is provided in `src/app/app.config.ts`.
    -   Find the `standalone: true` flag in the `@Component` decorator in `src/app/app.component.ts`.

## Deliverable(s)

Push your commits, including the modified `src/app/app.component.html` file, to your course **homework** repository.

# Rubric

Assignment score: X / 5 points

-   `[ ]` Project runs successfully using `ng serve`.
-   `[ ]` `app.component.html` has been modified with personal text.
-   `[ ]` Live-reloading functionality is confirmed to be working.
-   `[ ]` Student can locate the three specified key architectural markers (`bootstrapApplication`, providers, `standalone: true`).
-   `[ ]` Code is pushed to the repository with a clear commit message.

**Feedback:**
