# @POST, @PUT Endpoints using WorkOrderController

Outlined below are the differences between POST and PUT requests in the service, as well as additional notes on other write methods. The examples in `mr-fixit-service` are explained in detail to help understand the flow.

## POST vs PUT

### POST Method

**Purpose**: Create new resources

**Characteristics**:
- **Non-idempotent** - Multiple identical requests create multiple resources
- **URL doesn't contain the final resource ID** - The server generally assigns the ID
- **Status codes**:
    - `201 CREATED` - Successfully created (best practice)
    - `200 OK` - Also acceptable for creation
    - `400 BAD_REQUEST` - Invalid data


### PUT Method

**Purpose**: Update existing resources (full replacement)

**Characteristics**:
- **Idempotent** - Multiple identical requests produce the same result (unless you have audit fields - these will be updated with each request)
- **URL contains resource ID** - Client specifies which resource to update
- **Full replacement** - Typically replaces the entire resource
- **Status codes**:
    - `200 OK` - Successfully updated
    - `404 NOT_FOUND` - Resource doesn't exist
    - `400 BAD_REQUEST` - Invalid data

## Examples

### How the `submitWorkOrder` Method Works

The `submitWorkOrder` method is located in `WorkOrderController.java` and is annotated with `@PostMapping`, making it handle POST requests to `/work_order`.

### Method Signature
```java
@PostMapping
ResponseEntity<Object> submitWorkOrder(@RequestBody WorkOrderRequestDto workOrderRequestDto)
```

### Request Flow

1. **Receives Request**: The method accepts a `WorkOrderRequestDto` in the request body containing:
    - `studentId`
    - `room`
    - `categoryId`
    - `statusCode`
    - `title`
    - `description`
    - `dateRequested`
    - `maintenanceTechnicianCode`
    - `appointmentScheduled`
    - `completionNotes`

2. **Creates Work Order**: The controller calls `workOrderService.createWorkOrderRequest()` which:
    - Maps the DTO to a `WorkOrder` entity using `WorkOrderRequestDtoMapper`
    - Saves the new work order to the database using `workOrderRepository.saveAndFlush()`
    - Returns the persisted `WorkOrder` entity

3. **Error Handling**: The method includes exception handling:
    - If an `EntityNotFoundException` is thrown (e.g., invalid student ID or category ID), it returns a `400 BAD_REQUEST` with the error message
    - On success, it returns `200 OK` with the created work order

4. **Response**: Returns a `ResponseEntity<Object>` containing either:
    - The newly created `WorkOrder` entity (on success)
    - An error message string (on failure)

### Important Notes
- **Creates new resources** - Each POST request creates a new work order in the database
- **Non-idempotent** - Making the same POST request multiple times creates multiple work orders
- **No ID in URL** - The endpoint doesn't require a work order ID since it's creating a new one

---

## What a PUT Method Would Look Like
> There is not an implementation in `mr-fixit-service` for PUT

Here's how an update endpoint using PUT would be implemented to update a `Student`:

```java
  @PutMapping(path={"{id}"})
ResponseEntity<StudentDto> updateStudent(@PathVariable Integer id, @RequestBody StudentDto requestBody) {
    return new ResponseEntity<>(
        studentDtoMapper.toDto(studentService.saveStudent(id, requestBody)), HttpStatus.OK);
}
```

### Corresponding Service Method
The service would need a new `updateStudent` method:

```java
    public Student updateStudent(Integer id, StudentDto requestBody) throws EntityNotFoundException {
    Student student = getStudentById(id);
    studentDtoMapper.updateEntity(requestBody, student);
    return studentRepository.save(student);
}
```

### Important Notes
- **Updates existing resources** - Modifies a student that already exists
- **Requires ID in URL** - Uses path variable `{id}` to identify which student to update
- **Idempotent** - Making the same PUT request multiple times produces the same result

---

### Additional Notes

**PATCH Method** (Alternative to PUT):
- Use PATCH for partial updates (only changing specific fields)
- PUT traditionally replaces the entire resource
- Example: PATCH to only update status without changing other fields

**DELETE Method** 
- (_**DANGER ZONE**_)
- This will delete the record from your database 
- Hard deleting records is often avoided - once it's gone, it's gone, and you have no way of looking up history or restoring it.
- Consider "soft-deleting" a record if it is no longer needed - this is often done through `isActive` or `status` columns. You can update the column to false, N, or any other value that indicates this record is no longer active. Then, when you are querying, you add this column to your `where` clause to only get active records.

**Best Practices**:
- Use appropriate HTTP status codes (201 for POST creation, 404 for PUT not found)
- Keep operations idempotent when possible (prefer PUT over POST for updates)
- Return the updated/created resource in the response body
- Include proper error messages for validation failures
