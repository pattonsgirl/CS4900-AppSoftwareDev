# @Get Endpoints using StudentController

Outlined below is the complete flow of GET requests in the StudentController, from the Controller layer down to the Entity layer, including all intermediate layers. This is similar to last week's reading, but while last week was more conceptual, this breaks a specific flow down further to get a better understanding of how the layers connect.

>Examples below use mr-fixit-service

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [GET All Students](#get-all-students)
3. [GET Student By ID](#get-student-by-id)
4. [Path Variables Explained](#path-variables-explained)

---

## Architecture Overview

The StudentController follows a layered architecture pattern:

```
Controller Layer (StudentController.java)
    ↓
Mapper Layer (StudentDtoMapper.java)
    ↓
Service Layer (StudentService.java)
    ↓
Repository Layer (StudentRepository.java)
    ↓
Entity Layer (Student.java)
    ↓
Database (Student table)
```

### Layer Responsibilities:
- **Controller**: Handles HTTP requests, manages request/response, and delegates business logic
- **Mapper**: Converts between Entity objects and DTO (Data Transfer Objects)
- **Service**: Contains business logic and orchestrates data operations
- **Repository**: Provides database access methods through Spring Data JPA
- **Entity**: Represents the database table structure as a Java class

---

## GET All Students

### Endpoint
```
GET /student
```

### Flow Diagram
```
HTTP Request → Controller → Service → Repository → Database
                    ↓
                  Mapper
                    ↓
HTTP Response (JSON)
```

### Detailed Flow

#### 1. Controller Layer
**File**: `StudentController.java:28-32`

```java
@GetMapping
ResponseEntity<List<StudentDto>> getAllStudents() {
    return new ResponseEntity<>(
        studentDtoMapper.toDtoList(studentService.getAllStudents()), HttpStatus.OK);
}
```

**What happens:**
- The `@GetMapping` annotation (line 28) maps HTTP GET requests to `/student` to this method. This path is defined on line 19 as part of the `@RequestMapping` annotation.
- No path variables or request parameters are required for this endpoint
- The method returns a `ResponseEntity` containing a list of `StudentDto` objects with HTTP status 200 (OK)

#### 2. Service Layer Call
**File**: `StudentService.java:17-19`

The controller calls `studentService.getAllStudents()`:

```java
public List<Student> getAllStudents() {
    return studentRepository.findAll();
}
```

**What happens:**
- This service method delegates directly to the repository layer
- No business logic is applied in this simple case
- Returns a list of `Student` entities (not DTOs yet)

#### 3. Repository Layer
**File**: `StudentRepository.java:8`

```java
public interface StudentRepository extends JpaRepository<Student, Integer> {}
```

**What happens:**
- The repository extends `JpaRepository<Student, Integer>`, which provides the `findAll()` method automatically
- `findAll()` is a built-in Spring Data JPA method that queries the database for all records
- The `Integer` type parameter indicates the primary key type
- Spring Data JPA generates the equivalent of this SQL query: `SELECT * FROM Student`
  - Note: it doesn't actually run `SELECT *` - it will specify each column name.

#### 4. Entity Layer
**File**: `Student.java:15-50`

```java
@Entity
@Table(name = "Student")
public class Student {
    @Id
    @Column(name = "student_id", nullable = false)
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Integer id;

    @Column(name = "email_address", length = 200, nullable = false)
    String emailAddress;

    @Column(name = "first_name", length = 20, nullable = false)
    String firstName;

    @Column(name = "last_name", length = 25, nullable = false)
    String lastName;

    @Column(name = "phone_number", length = 10, nullable = false)
    String phoneNumber;

    @Column(name = "last_login")
    Instant lastLogin;

    @Column(name = "active", nullable = false)
    Boolean active;

    @Column(name = "date_added")
    @CreationTimestamp(source = SourceType.DB)
    Instant dateAdded;

    @Column(name = "date_last_updated")
    @UpdateTimestamp(source = SourceType.DB)
    Instant lastUpdated;
}
```

**What happens:**
- The `@Entity` annotation marks this class as a JPA entity mapped to a database table
- The `@Table(name = "Student")` annotation specifies the table name
- Each field with `@Column` annotation maps to a database column
- The `@Id` annotation marks `id` as the primary key
- JPA/Hibernate uses this entity to map database rows to Java objects

#### 5. Mapper Layer
**File**: `StudentDtoMapper.java:19`

Back in the controller, after receiving the list of `Student` entities from the service, the mapper is invoked:

```java
List<StudentDto> toDtoList(List<Student> studentList) throws EntityNotFoundException;
```

**What happens:**
- This is a MapStruct interface that generates mapping code at compile time
- MapStruct automatically converts each `Student` entity to a `StudentDto`
- Fields with matching names are mapped automatically
- The DTO layer protects the internal entity structure from being exposed via the API

#### 6. Response
The controller wraps the list of DTOs in a `ResponseEntity` with HTTP status 200 and returns it. Spring Boot automatically serializes the DTOs to JSON format.

**Example Response:**
```json
[
    {
        "id": 1,
        "emailAddress": "john.doe@example.com",
        "firstName": "John",
        "lastName": "Doe",
        "phoneNumber": "5551234567",
        "lastLogin": "2025-10-14T10:30:00Z",
        "active": true,
        "dateAdded": "2025-01-15T08:00:00Z",
        "lastUpdated": "2025-10-14T10:30:00Z"
    },
    {
        "id": 2,
        "emailAddress": "jane.smith@example.com",
        "firstName": "Jane",
        "lastName": "Smith",
        "phoneNumber": "5559876543",
        "lastLogin": "2025-10-13T14:22:00Z",
        "active": true,
        "dateAdded": "2025-02-20T09:15:00Z",
        "lastUpdated": "2025-10-13T14:22:00Z"
    }
]
```

---

## GET Student By ID

### Endpoint
```
GET /student/{id}
```

### Flow Diagram
```
HTTP Request → Controller (extract {id}) → Service → Repository → Database
                           ↓
                         Mapper
                           ↓
                  HTTP Response (JSON)
```

### Detailed Flow

#### 1. Controller Layer
**File**: `StudentController.java:34-38`

```java
@GetMapping(path = "{id}")
ResponseEntity<StudentDto> getStudentById(@PathVariable Integer id) {
    return new ResponseEntity<>(
        studentDtoMapper.toDto(studentService.getStudentById(id)), HttpStatus.OK);
}
```

**What happens:**
- The `@GetMapping(path = "{id}")` annotation maps GET requests to `/student/{id}`
- The `{id}` in the path is a **path variable** placeholder (see [Path Variables Explained](#path-variables-explained))
- The `@PathVariable Integer id` annotation extracts the `{id}` value from the URL and binds it to the `id` parameter
- The method returns a `ResponseEntity` containing a single `StudentDto` object with HTTP status 200 (OK)

**Example Request:**
```
GET /student/5
```
In this example, the value `5` is extracted and passed as the `id` parameter.

#### 2. Service Layer Call
**File**: `StudentService.java:21-27`

The controller calls `studentService.getStudentById(id)`:

```java
public Student getStudentById(Integer id) throws EntityNotFoundException {
    Optional<Student> result = studentRepository.findById(id);
    if (result.isEmpty()) {
        throw new EntityNotFoundException("Student (" + id + ") not found");
    }
    return result.get();
}
```

**What happens:**
- The service receives the `id` parameter from the controller
- It calls `studentRepository.findById(id)` which returns an `Optional<Student>`
- **Business logic**: The service checks if the student exists
    - If not found (`result.isEmpty()`), it throws an `EntityNotFoundException` with a descriptive message
    - If found, it extracts the `Student` entity from the Optional using `.get()`
- This error handling ensures the API returns a meaningful error response when a student doesn't exist

#### 3. Repository Layer
**File**: `StudentRepository.java:8`

```java
public interface StudentRepository extends JpaRepository<Student, Integer> {}
```

**What happens:**
- The `findById(id)` method is inherited from `JpaRepository<Student, Integer>`
- The second type parameter `Integer` specifies that the primary key type is Integer
- Spring Data JPA generates the the equivalent of this SQL query: `SELECT * FROM Student WHERE student_id = ?`
    - Note: it doesn't actually run `SELECT *` - it will specify each column name.
- The `?` parameter is replaced with the actual `id` value
- Returns an `Optional<Student>` which can be empty if no record matches the ID

#### 4. Entity Layer
**File**: `Student.java:20-23`

```java
@Id
@Column(name = "student_id", nullable = false)
@GeneratedValue(strategy = GenerationType.IDENTITY)
Integer id;
```

**What happens:**
- The `@Id` annotation marks this field as the primary key that `findById()` searches against
- The `@Column(name = "student_id")` annotation maps the `id` field to the `student_id` database column
- When a matching record is found, JPA creates a `Student` object and populates all fields from the database row

#### 5. Mapper Layer
**File**: `StudentDtoMapper.java:17`

After the service returns the `Student` entity, the controller invokes the mapper:

```java
StudentDto toDto(Student student) throws EntityNotFoundException;
```

**What happens:**
- MapStruct converts the single `Student` entity to a `StudentDto`
- This conversion creates a clean separation between the internal data model and the API contract
- The DTO can have different field names, exclude sensitive fields, or format data differently than the entity

#### 6. Response
The controller wraps the DTO in a `ResponseEntity` with HTTP status 200 and returns it.

**Example Response for GET /student/5:**
```json
{
    "id": 5,
    "emailAddress": "alice.johnson@example.com",
    "firstName": "Alice",
    "lastName": "Johnson",
    "phoneNumber": "5551112222",
    "lastLogin": "2025-10-12T16:45:00Z",
    "active": true,
    "dateAdded": "2025-03-10T11:20:00Z",
    "lastUpdated": "2025-10-12T16:45:00Z"
}
```

**Example Error Response for GET /student/999 (not found):**
```json
{
    "error": "Entity Not Found",
    "message": "Student (999) not found"
}
```

---

## Path Variables Explained

### What Are Path Variables?

Path variables are dynamic segments in a URL path that capture values from the request URL. They allow you to create flexible endpoints that work with different resource identifiers.

### Syntax in Spring Boot

#### 1. Defining a Path Variable in @GetMapping
```java
@GetMapping(path = "{id}")
```

- The curly braces `{id}` define a path variable placeholder
- The name inside the braces (`id`) is the variable name
- This creates a URL pattern like `/student/123` where `123` is the value of `id`

#### 2. Binding to a Method Parameter
```java
ResponseEntity<StudentDto> getStudentById(@PathVariable Integer id)
```

- The `@PathVariable` annotation binds the URL path variable to the method parameter
- Spring automatically extracts the value from the URL and converts it to the parameter type (`Integer`)
- The parameter name (`id`) must match the path variable name in the `@GetMapping` path

### How Path Variables Work

#### Example URL: `GET /student/42`

1. **Request arrives**: `GET /student/42`
2. **Spring matches pattern**: `/student/{id}` matches the URL
3. **Extraction**: Spring extracts `42` from the URL
4. **Type conversion**: Spring converts the string `"42"` to an `Integer`
5. **Parameter binding**: The value `42` is passed to the `id` parameter
6. **Method execution**: `getStudentById(42)` is called

### Path Variable vs Request Parameter

| Feature | Path Variable | Request Parameter |
|---------|--------------|-------------------|
| Syntax | `/student/{id}` | `/student?id=42` |
| Required | Usually required | Often optional |
| Purpose | Identify specific resource | Filter or configure request |
| Example | `@PathVariable Integer id` | `@RequestParam Integer id` |
| URL | `/student/42` | `/student?id=42` |

### Multiple Path Variables

Although not used in StudentController, you can have multiple path variables:

```java
@GetMapping(path = "{studentId}/courses/{courseId}")
ResponseEntity<Enrollment> getEnrollment(
    @PathVariable Integer studentId,
    @PathVariable Integer courseId
) {
    // Handle GET /student/5/courses/101
}
```

### Path Variable Naming

If the path variable name differs from the parameter name, you can specify it explicitly:

```java
@GetMapping(path = "{studentId}")
ResponseEntity<StudentDto> getStudent(@PathVariable("studentId") Integer id) {
    // The URL has {studentId} but the parameter is named 'id'
}
```

### Type Conversion

Spring automatically converts path variables to the parameter type:

- `Integer id` - converts to integer (e.g., `/student/42`)
- `String name` - keeps as string (e.g., `/student/john-doe`)
- `Long id` - converts to long (e.g., `/student/9999999999`)
- `UUID id` - converts to UUID (e.g., `/student/123e4567-e89b-12d3-a456-426614174000`)

If conversion fails (e.g., `/student/abc` when expecting Integer), Spring returns a 400 Bad Request error.

---

## Summary

### GET All Students Flow
1. HTTP GET request to `/student`
2. `StudentController.getAllStudents()` is invoked
3. Controller calls `StudentService.getAllStudents()`
4. Service calls `StudentRepository.findAll()`
5. Repository queries database for all Student records
6. Entities are returned through service to controller
7. Controller uses `StudentDtoMapper.toDtoList()` to convert entities to DTOs
8. Response with list of DTOs and HTTP 200 is returned

### GET Student By ID Flow
1. HTTP GET request to `/student/{id}` (e.g., `/student/5`)
2. Spring extracts path variable `{id}` and converts to Integer
3. `StudentController.getStudentById(5)` is invoked
4. Controller calls `StudentService.getStudentById(5)`
5. Service calls `StudentRepository.findById(5)`
6. Repository queries database: `SELECT * FROM Student WHERE student_id = 5`
7. If found, entity is returned; if not found, `EntityNotFoundException` is thrown
8. Controller uses `StudentDtoMapper.toDto()` to convert entity to DTO
9. Response with single DTO and HTTP 200 is returned

### Key Concepts
- **Path Variables**: Dynamic URL segments that capture resource identifiers (e.g., `{id}`)
- **Layered Architecture**: Separation of concerns across Controller, Service, Repository, and Entity layers
- **DTO Pattern**: Data Transfer Objects protect internal entity structure and provide clean API contracts
- **Spring Data JPA**: Provides automatic implementation of common database operations
- **MapStruct**: Compile-time mapper that converts between entities and DTOs
