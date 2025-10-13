# Homework 1 - Creating JPA Entities

## Purpose / Objectives

The purpose of this assignment is to create your group Java service, create classes that represent the tables in your group database, and lay the foundation for the various layers of the service application.

You will individually create your own branch on your group repo to complete the assignment. You will get your individual grade on this. Then, as a group, you will work together to decide which of your branches to merge into the main branch. You may make further adjustments as a group.

## Description

Perform the following tasks in the Java service of your group repo:

### 1. Create a branch off of the default branch and name the branch your last name and homework assignment number

Example: `noel-homework-1`

### 2. Create packages for each layer

Create a directory under `/src/main/java/{project-specific-package}` for each of these:
- config
- controller
- dto
- mapper
- model
- repository
- service

### 3. Create a class for each entity in your database in the `model` directory
- Annotate the
  -You don't need a class for relation tables.

### 4. Create a controller class for each entity you plan to access in the `controller` directory

Examples: `CardController`, `BookController`, `UserController`
- Make sure all annotations are included to indicate this class is an entity, what the table and column names are, the primary key
- No methods needed yet

### 5. Create a repository class for each entity in the `repository` directory

Examples: `CardRepository`, `BookRepository`, `UserRepository`
- Add class-level annotation (reference mr-fixit-service)
- Extend `JpaRepository` and pass the correct type arguments
- No methods needed yet

### 6. Create a service class for each entity in the `service` directory

Examples: `CardService`, `BookService`, `UserService`
- Add class-level annotations (reference mr-fixit-service)
- No methods needed yet

### 7. git add, commit, and push your changes to your branch upstream

## Rubric

**Assignment score: X / 5 points**

- [ ] Your Java service runs successfully
- [ ] A Java class is created and properly annotated for each entity in your database (2 pts)
- [ ] Packages are created for each layer, complete with classes set up according to instructions above
- [ ] Code is pushed to the repository with a clear commit message
