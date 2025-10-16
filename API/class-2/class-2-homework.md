
## Homework 2 - Creating GET methods

## Purpose / Objectives
> The purpose of this assignment is to create endpoints that allow you to retrieve data from your group database using your newly initialized group Java project. You will also work to identify the critical routes your service must provide by the end of the unit.

> You will individually create your own branch on your group repo to complete one portion of the assignment. You will get your individual grade on this. Then, as a group, you will work together to merge your branches into the main branch. You may make further adjustments as a group.

## Description

Choose ONE entity you want your service to retrieve. You will then create three controller methods to retrieve this entity in various ways - similar to the StudentController in the overview.
> Honors Students: You must choose TWO entities.

If you are not honors but want to do multiple entities, feel free, but this assignment will be graded on getting just one entity working. Focus on that and then do extra if you want.

Coordinate with your team as you are choosing entities.

>_**The risk for merge conflicts is about to get significantly higher, so coordinate with your team or else be prepared to sort through things when it's time to merge to the default branch.**_

### Perform the following tasks in the Java service of your group repo:


### 1. Create a branch off of the default branch and name the branch your last name and homework assignment number
Example: noel-homework-2

### 2. Create a homework directory under your project root `{your-service-name}/homework`
- Create a subdirectory called `homework-2`

### 3. Create directories for remaining layers under `/src/main/java/{project-specific-package}`
- controller
- dto
- mapper
- repository
- service
- You should already have a `model` directory from Homework 1


### 4. Create all classes necessary in the above packages to get your route working
- Create three controller methods that perform the following tasks:
  - Find all entities
  - Find entity by id
  - Find entity by search string (similar to finding Student by firstName in the overview)

### 5. Create requests in Bruno to verify your new endpoints work
- Save clearly named screenshots of Bruno including the response, URL, request method, and response status code in `/homework/homework-2`
- There should be one screenshot per request - 3 for standard, 6 for honors.

### 6. Group activity only - decide critical routes
- As a group, decide the routes your service must provide by the end of the unit.
- You will already have 3 defined from this activity
- Plan what write requests you will need
- Plan any other get requests are necessary
- Save a document with your plan in `/homework/homework-2`
- See example in `/API/class-2/example-api-routes.md`

### 7. git add, commit, and push your changes to your branch upstream

# Rubric

Assignment score: X / 10 points (used for both individual and group)

-   `[ ]` Your Java service runs successfully
-   `[ ]` Classes for each layer are created and correctly structured in packages (2 pts)
-   `[ ]` Controller methods are created for one entity (two entities for honors) to find all, find by id, and find by search string. (3 pts)
-   `[ ]` Screenshot of all requests for new controller methods are saved in correct directory with 200 response status code, URL, response body, and request method visible (3pts)
-   `[ ]` Code is pushed to the repository with a clear commit message

Additional group score: X / 5 points (used only for group score in addition to above requirements)
-   `[ ]` Document clearly outlining expected routes, complete with entity and request methods, saved in group repo
