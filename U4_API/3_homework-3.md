## Homework 3 - GET cleanup / Group Project - Entity Select

## Purpose / Objectives
> The purpose of this assignment is to ensure your group project has a good foundation, is capable of handling GET requests, and is ready to begin PUT/POST requests next lesson.

## Cleanup

### Perform the following tasks in the Java service of your group repo:

### 1. Create a branch off of your `lastName-homework-2` branch and name the branch your last name and homework assignment number
Example: noel-homework-3

### 2. Ensure proper project architecture using the package-by-layer approach
- Ensure your project is properly named (all references to default API_NAME are removed)
- Ensure your main class is directly under the package root. In `mr-fixit-service` project, `MrFixitServiceApplication.java` is under `src/main/java/com/winsupply/mrfixitservice`
- Ensure all your classes are in the proper package.

### 3. Ensure the project adheres to Java standards
- Packages are lowercase
- Class names are UpperCamelCase
- Method and variables are lowerCamelCase

### 4. Ensure code is properly formatted
- Use the `spotless` plugin to quickly and uniformly format your code

### 5. git add, commit, and push your changes to your branch upstream

## Group Project

### 1. Ensure functioning GET endpoints
Choose at least ONE entity's 3 GET requests from someone's individual homework-2 assignment to merge into your group's default branch (if honors, then TWO entities). You may create a new branch that combines ideas from multiple individual homeworks that then gets merged to default.
> You may have already done this last week - if so, and if what you have _works_:
> - If team members worked on multiple entities, merge the additional entities in.
> - If team members worked on the same entity, you can work on creating GET endpoints for an additional entity.
> - ***If what you have does not work yet  - focus on getting ONE entity to work before moving on!***

### 2. Ensure proper architecture and code style
- Follow the steps in [Cleanup](#cleanup) for your group's default branch

### 3. Ensure changes are commited and pushed/merged to upstream default branch

# Rubric

### Individual Assignment
Assignment score: X / 5 points

-   `[ ]` Your Java service runs successfully
-   `[ ]` Project has proper package-by-layer architecture with clearly named packages
-   `[ ]` Classes, packages, methods, and variables follow Java coding standards
-   `[ ]` Code is consistently formatted
-   `[ ]` Code is pushed to the repository with a clear commit message

### Group Assignment
Assignment score: X / 10 points

-   `[ ]` Your Java service runs successfully
-   `[ ]` Project has proper package-by-layer architecture with clearly named packages
-   `[ ]` Classes, packages, methods, and variables follow Java coding standards
-   `[ ]` Code is consistently formatted
-   `[ ]` Controller methods are created for one entity (two entities for honors) to find all, find by id, and find by search string (2pts)
-   `[ ]` Screenshot of all requests for new controller methods are saved in correct directory with 200 response status code, URL, response body, and request method visible (3pts)
-   `[ ]` Code is pushed to the repository with a clear commit message





