# Spring Boot Architecture and Design Patterns

## Important Concepts

### Annotations

Annotations are metadata that are provided in the format of an at sign (@) followed by the name of the annotation, and are then evaluated at runtime or compile time. 

### Dependency Injection

Dependency Injection is a design pattern that has an external object manage connecting dependencies rather than the object itself. Spring has an Inversion of Control (IoC) container that manages dependency injection for us, as well creates managed object instances (Spring Beans) that can be used by other objects. There are 3 common ways that you can do this in Spring Boot:

#### Constructor Injection

Constructor Injection is when dependencies are provided to the contructor when creating an instance of the class. This requires all specified dependencies to be provided when the object is created, encouraging immutability. The `@Autowired` annotation is used to indicate that the method arguments need to be provided by the IoC container, however the annotation is no longer required for Constructor Injection since Spring 4.3 (Spring Boot 2). In mr-fixit-service, the Lombok annotation `@RequiredArgsConstructor` will create a constructor with arguments for all final and `@NonNull` fields. This is the preferred approach to implement dependency injection.

##### Example:

```java
@Service
public class LocationService {

    private AuthService authService;

    @Autowired // This annotaion is no longer required
    public LocationService(AuthService authService) {
        this.authService = authService;
    }
}
```

#### Setter Injection

Setter Injection is when you apply an `@Autowired` annotation to a setter method. This is helpful for providing dependencies that may not be available upon construction, and for scenarios where the dependency might be optional.

##### Example:

```java
@Service
public class LocationService {

    private AuthService authService;

    @Autowired
    public void setAuthService(AuthService authService) {
        this.authService = authService;
    }
}
```

#### Field Injection

Field injection is when you apply an `@Autowired` annotation directly to a field. This approach should not be used since it doesn't indicate the dependency (via method or constructor), and it is harder to properly test.

##### Example:

```java
@Service
public class LocationService {

    @Autowired
    private AuthService authService;
}
```

## Spring Boot Architecture and Design Patterns

### Controllers (aka Presentation Layer)

Controllers are responsible for handling HTTP requests and returning HTTP responses. This is where the application interacts with the outside world—typically via REST APIs.

#### Key Responsibilities:

- Handling incoming HTTP requests (GET, POST, PUT, DELETE, etc.)
- Mapping request URLs to corresponding methods using annotations like `@GetMapping`, `@PostMapping`, etc.
- Processing request parameters and body data (e.g., using `@RequestParam`, `@RequestBody`)
- Delegating business logic to the Service Layer
- Returning responses, typically in the form of a `ResponseEntity` containing the DTO

#### Key Annotations:

- `@RestController`: Marks the class as a controller that handles web requests and automatically serializes responses into JSON or XML
- `@RequestMapping`: Defines the base URL for the controller
- `@GetMapping`, `@PostMapping`, `@PutMapping`, etc.: Specify the HTTP method and endpoint path

#### Example:

```java
@RequiredArgsConstructor
@RestController
@RequestMapping(
    path = "work_order",
    produces = MediaType.APPLICATION_JSON_VALUE,
    consumes = MediaType.APPLICATION_JSON_VALUE)
public class WorkOrderController {

    private final WorkOrderCategoryDtoMapper workOrderCategoryDtoMapper;
    private final WorkOrderCategoryService workOrderCategoryService;
    private final WorkOrderDtoMapper workOrderDtoMapper;
    private final WorkOrderService workOrderService;
    private final WorkOrderStatusDtoMapper workOrderStatusDtoMapper;
    private final WorkOrderStatusService workOrderStatusService;

    @GetMapping(path = "{id}")
    ResponseEntity<WorkOrderDto> getWorkOrderById(@PathVariable Integer id) {
        return new ResponseEntity<>(
            workOrderDtoMapper.toDto(workOrderService.getWorkOrderById(id)), HttpStatus.OK);
    }
}
```

Here, the controller handles the GET `/work_order/{id}` request and delegates business logic to the service layer. It converts the object returned from the service layer to a DTO before returning it in the response.

### Services (aka Business Layer)

Services contain the business logic of the application. They acts as a bridge between the controller and the data access layers. Services handle the core application operations and orchestrates data manipulation.

#### Key Responsibilities:

- Containing business logic (e.g., validating inputs, applying business rules)
- Orchestrating calls to the Repository Layer (data access)
- Processing data before sending it to the controller
- Returning data as DTOs or models to the controller

#### Key Annotations:

- `@Service`: Marks the class as a service provider that handles business logic

#### Example:

```java
@RequiredArgsConstructor
@Service
public class WorkOrderService {

    private final WorkOrderRepository workOrderRepository;
    private final WorkOrderRequestDtoMapper workOrderRequestDtoMapper;

    public WorkOrder getWorkOrderById(Integer id) throws EntityNotFoundException {
        return workOrderRepository
            .findById(id)
            .orElseThrow(() -> new EntityNotFoundException("Work Order (" + id + ") not found"));
    }
}
```

Here, the service is calling the repository to fetch the data, applying necessary business logic.

### Data Transfer Object (DTO) Pattern

The DTO pattern is used to transfer data between layers (e.g., from a service layer to a controller) in a structured way. DTOs are simple objects that contain only necessary fields and methods. They provide an abstraction over complex models, which can improve security, readability, and maintainability. The conversion of classes is usually handled by a mapper, and for this course we will be using a library (MapStruct) to help with creating the mapper.

#### Key Responsibilities:

- Representing data in a form suitable for communication between the layers (e.g., between the service and controller)
- Simplifying complex entities/models when transferring data to the client
- Reducing the exposure of sensitive information by only including required fields

#### Key Annotations:

- `@Builder`: (optional) Provides a flexible way to construct DTO objects, usually from entities or models
- `@Getter`, `@Setter`, `@NoArgsConstructor`, `@AllArgsConstructor`: These Lombok annotations can be used to generate boilerplate code

#### Example:

```java
@Builder
@Data
@Value
public class WorkOrderDto {
    Integer orderNumber;
    StudentDto student;
    RoomDto room;
    WorkOrderCategoryDto category;
    WorkOrderStatusDto status;
    String title;
    String description;
    LocalDate dateRequested;
    MaintenanceTechnicianDto maintenanceTechnician;
    Instant appointmentScheduled;
    Instant appointmentCompleted;
    String completionNotes;
    Instant dateAdded;
    Instant dateUpdated;
}
```

Here, the `WorkOrderDto` represents a simplified view of a Work Order entity that is returned to the client, containing only the fields that need to be exposed. In this case, we are returning every column in the Work Order table, but if new columns are ever added to the table (an audit column for example), they will not inherently be returned as part of the Work Order. You don't necessarily want to expose that to the client.

### Models and Repository Pattern (aka Persistence Layer)

The Persistence Layer includes classes representing database entities (models) and their relationships as well as the interactions with the database. There are several ways to implement a Persistence Layer, but for this class we will be using JPA (Java Persistence API) with repositories. Another approach is to use the Data Access Object (DAO) Pattern, which is a lower-level implementation.

#### Key Responsibilities:

- Representing the database schema as Java objects (POJOs)
- Mapping database tables to Java classes using JPA or other ORM tools
- Handling relationships (e.g., one-to-many, many-to-many) between tables

#### Key Annotations:

- `@Entity`: Marks the class as a JPA entity (i.e., a table in the database)
- `@Table`: Specifies the table name if different from the class name
- `@Id`: Specifies the primary key of the entity
- `@Column`: Maps fields to columns in the table
- `@ManyToOne, @ManyToMany, @OneToOne, @OneToMany`: Maps the relationships between tables
- `@JoinColumn`: Indicates the foreign key column 

#### Example:

```java
@Data
@Entity
@Table(name = "Work_Order")
public class WorkOrder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "work_order_number", nullable = false)
    Integer orderNumber;

    @JoinColumn(name = "student_id", nullable = false)
    @ManyToOne
    Student student;

    @JoinColumns({
        @JoinColumn(name = "building_id", referencedColumnName = "building_id"),
        @JoinColumn(name = "room_number", referencedColumnName = "room_number")
    })
    @ManyToOne
    Room room;

    @JoinColumn(name = "work_order_category_id", nullable = false)
    @ManyToOne
    WorkOrderCategory category;

    @JoinColumn(name = "work_order_status_code", nullable = false)
    @ManyToOne
    WorkOrderStatus status;

    @Column(name = "title", length = 25, nullable = false)
    String title;

    @Column(name = "description", length = 300, nullable = false)
    String description;

    @Column(name = "date_requested", nullable = false)
    LocalDate dateRequested;

    @JoinColumn(name = "technician_code")
    @ManyToOne
    MaintenanceTechnician maintenanceTechnician;

    @Column(name = "appointment_scheduled")
    Instant appointmentScheduled;

    @Column(name = "appointment_completed")
    Instant appointmentCompleted;

    @Column(name = "completion_notes", length = 500)
    String completionNotes;

    @Column(name = "date_added")
    @CreationTimestamp(source = SourceType.DB)
    Instant dateAdded;

    @Column(name = "date_last_updated")
    @UpdateTimestamp(source = SourceType.DB)
    Instant dateUpdated;
}

```

In this example, the `WorkOrder` entity represents the `Work_Order` table in the database, with the `orderNumber` field as its primary key.

Notice the association annotations. The `Work_Order` table has a many-to-one relationship to the `Student` table, so the `student` property in your Java class is annotated like this:

```java
@JoinColumn(name = "student_id", nullable = false)
@ManyToOne
Student student;
```

Another point of interest is the `room` property, as the `Room` table has a composite foreign key to the `Room` table:

```java
@JoinColumns({
    @JoinColumn(name = "building_id", referencedColumnName = "building_id"),
    @JoinColumn(name = "room_number", referencedColumnName = "room_number")
})
@ManyToOne
Room room;
```

### Supporting content
These were included in class-0-overview.md if you missed them:

- [JPA - Introduction](https://www.geeksforgeeks.org/java/jpa-introduction/)
- [Simplifying Data Access in Java: A Comparative Look at DAO and Spring Data JPA](https://medium.com/@ksaquib/simplifying-data-access-in-java-a-comparative-look-at-dao-and-spring-data-jpa-6c3d56fd0c22)
- [Accessing Data with JPA](https://spring.io/guides/gs/accessing-data-jpa)

### Next Steps & Further Reading
Next class you will create the other layers of your Java service, and start making GET requests. Study `mr-fixit-service` and get familiar with the flow between layers. Pick a controller class, and see if you can trace the steps all the way back down to the model.
