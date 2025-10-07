## Homework 0 - Making HTTP Requests

## Purpose / Objectives
> The purpose of this assignment is to get you familiar with the client-server concept, by making HTTP requests using a variety of HTTP methods.
> ### Sorry, no coding yet.
> \*laughs in evil\*


## Description

Make sure you have cloned the Mr. Fix It Service repo: [mr-fix-it repo](https://github.com/WSU-kduncan/mr-fixit-service)

Perform the following tasks in the demo [mr-fix-it repo](https://github.com/WSU-kduncan/mr-fixit-service):

### 1. Create a branch off of `put-work-order` and name the branch your last name

### 2. Start and run the demo app (don't forget to also have the DB running with `docker compose <up or start>`)

### 3. Open Bruno and open the `mr-fixit-service` collection
- `/mr-fix-it-service/bruno/mr-fix-it-service`

### 4. Get all work orders - GET
1. Open the `GET` request to get all work orders
   - In Bruno: `mr-fixit-service > work_order > Get All Work Orders.bru`
2. Send the request and verify you get a 200 response
3. In mr-fixit-service: save a clearly named screenshot of Bruno including the response, URL, request method, and response status code in `/homework/homework-0`

### 5. Create a new work order - POST
1. In Bruno: modify the request body in `mr-fixit-service > work_order > Create Work Order.bru` to create a new work order for your favorite super hero
2. Send the request and verify you get a 200 response
3. In mr-fixit-service: save a clearly named screenshot of Bruno including the response, URL, request method, and response status code in `/homework/homework-0`

### 6. Add a new request to update a work order - PUT
1. In Bruno: create a new and well-named PUT request under `mr-fixit-service > work_order`
2. Add a request body that will update the description of the new work order you created in Step 5
3. Send the request and verify you get a 200 response
4. In mr-fixit-service: save a clearly named screenshot of Bruno including the response, URL, request method, and response status code in `/homework/homework-0`

### 7. git add, commit, and push your changes to your branch upstream
    

Here is an example of the required components in the screenshot:
![homework-screenshot-example.png](assets/homework-screenshot-example.png)


# Rubric

Assignment score: X / 5 points

-   `[ ]` mr-fix-service runs successfully
-   `[ ]` Screenshot of GET request for retrieving all work orders is saved in correct directory with 200 response status code, URL, response body, and request method visible
-   `[ ]` Screenshot of POST request for adding new work order is saved in correct directory with 200 response status code, URL, response body showing super hero values, and request method visible
-   `[ ]` Screenshot of PUT request for updating newly created work order is saved in correct directory with 200 response status code, URL, response body showing updated description, and request method visible
-   `[ ]` Code is pushed to the repository with a clear commit message.
