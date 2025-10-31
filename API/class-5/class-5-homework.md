## Homework 5 - Catch Up / Group Project Verification (again)

## Purpose / Objectives
> The purpose of this assignment is to ensure your group project is ready for the next unit and capable of handling GET, POST, and PUT requests.

## Cleanup

### Perform the following tasks in the Java service of your group repo:

### 1. Create a branch off of your `lastName-homework-5` branch and name the branch your last name and homework assignment number
Example: noel-homework-3

### 2. Implement remaining endpoints according to your API definitions document
- If there are endpoints on your api definition document that have not been implemented yet (and you already have at least one entity GET, POST, PUT working) - go ahead and do them
- If all of them are implemented - and everything is working great - get creative and come up with more functionality. You could do more endpoints, implement more error handling, write some unit tests.....
- Work with your team to decide how to approach this - whether each of you will implement a different endpoint of if you want to do the same ones and compare later

### 3. Ensure the project adheres to Java standards
- Packages are lowercase
- Class names are UpperCamelCase
- Method and variables are lowerCamelCase

### 4. Ensure code is properly formatted
- Use the `spotless` plugin to quickly and uniformly format your code

### 5. git add, commit, and push your changes to your branch upstream

## Group Project

### 1. Merge all final changes
This is it, guys. Make any final touches, implement any last minute functionality - whatever you need to make sure your project is ready for the front end!

### 2. Ensure proper architecture and code style
- Follow the steps in [Cleanup](#cleanup) for your group's default branch

### 3. Ensure changes are commited and pushed/merged to upstream default branch

### 4. Documentation polish
1. Update the API definition document with any changes and denote what has been implemented (see Homework 2 - Critical Routes)
2. Update Bruno collection to test all working endpoints
3. README.md with instructions  
  - Minimum requirements:
    - required tools (Java version, any other dependencies)
    - how to run API (which branch, point to DB repo & instructions, how to start service)
    - how to test (point to API definition doc and Bruno collections, quick info of test runs that should work)

# Rubric

### Contribution requirements
Every team member should have one or more commits against this final compilation of your group's API. No commits = no credit.  Heavy recommendation to use PRs to avoid accidental clobbering - or at least to identify merge conflicts before creating chaos. 

### Group Assignment
Assignment score: X / 10 points

-   `[ ]` Your Java service runs successfully
-   `[ ]` Project has proper package-by-layer architecture with clearly named packages
-   `[ ]` Classes, packages, methods, and variables follow Java coding standards
-   `[ ]` Code is consistently formatted
-   `[ ]` GET controller methods are created for one entity to find all, find by id, and find by search string
    - `[ ]` Honors: two entities with GET controller methods to find all, find by id, and find by search string  
-   `[ ]` POST/PUT/DELETE controller methods are created for one entity
    - `[ ]` Honors: two entities with POST / PUT / DELETE controller methods  
-   `[ ]` Polished Bruno collection(s) that support testing your implemented endpoints
-   `[ ]` Updated API definitions document that *also* denotes what is currently implemented (keep this up to date as your team continues implementing pieces of the API)
-   `[ ]` README.md in repo with project instructions
-   `[ ]` Code is pushed to the repository with a clear commit message





