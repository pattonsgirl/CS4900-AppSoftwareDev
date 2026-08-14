## Homework 1 - Creating JPA Entities

## Purpose / Objectives
> The purpose of this assignment is to create your group Java service and create entities that represent the tables and relationships in your group database.
> You will individually create your own branch on your group repo to complete the assignment. You will get your individual grade on this. Then, as a group, you will work together to decide which of your branches to merge into the main branch. You may make further adjustments as a group.

## Description

Perform the following tasks in the Java service of your group repo:

### 1. Create a branch off of the default branch and name the branch your last name and homework assignment number
Example: noel-homework-1

### 2. Create a directory under `/src/main/java/{project-specific-package}` and name it `model`

### 3. Create a class for each entity in your database in the `model` directory
- You don't need a class for relation tables - use these to help determine your `@OneToMany`, `@ManyToMany`, etc annotations
- Make sure all annotations are included to indicate this class is an entity, what the table and column names are, relationship mapping, the primary key, etc

### 4. git add, commit, and push your changes to your branch upstream

# Rubric

Assignment score: X / 5 points

-   `[ ]` your Java service runs successfully
-   `[ ]` A Java class is created for each entity in your database
-   `[ ]` Java classes are properly annotated at both the class and field level (2 pts)
-   `[ ]` Code is pushed to the repository with a clear commit message.
