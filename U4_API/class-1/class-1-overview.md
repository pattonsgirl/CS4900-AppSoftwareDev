# Spring Boot Application Architecture Layers

## 1. Controller Layer

The Controller Layer is responsible for handling HTTP requests and returning HTTP responses. This is where the application interacts with the outside world—typically via REST APIs.

### Key Responsibilities:

- Handling incoming HTTP requests (GET, POST, PUT, DELETE, etc.)
- Mapping request URLs to corresponding methods using annotations like `@GetMapping`, `@PostMapping`, etc.
- Processing request parameters and body data (e.g., using `@RequestParam`, `@RequestBody`)
- Delegating business logic to the Service Layer
- Returning responses, typically in the form of a `ResponseEntity` containing the DTO

### Key Annotations:

- `@RestController`: Marks the class as a controller that handles web requests and automatically serializes responses into JSON or XML
- `@RequestMapping`: Defines the base URL for the controller
- `@GetMapping`, `@PostMapping`, `@PutMapping`, etc.: Specify the HTTP method and endpoint path

### Example:

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

## 2. Service Layer

The Service Layer contains the business logic of the application. It acts as a bridge between the controller and the data access layers. The service layer handles the core application operations and orchestrates data manipulation.

### Key Responsibilities:

- Containing business logic (e.g., validating inputs, applying business rules)
- Orchestrating calls to the Repository Layer (data access)
- Processing data before sending it to the controller
- Returning data as DTOs or models to the controller

### Key Annotations:

- `@Service`: Marks the class as a service provider that handles business logic

### Example:

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

## 3. Data Transfer Object (DTO) Layer

The DTO Layer is used to transfer data between layers (e.g., from the service layer to the controller) in a structured way. DTOs are simple objects that contain only the necessary data and no business logic. They provide an abstraction over complex models, which can improve security, readability, and maintainability.

### Key Responsibilities:

- Representing data in a form suitable for communication between the layers (e.g., between the service and controller)
- Simplifying complex entities/models when transferring data to the client
- Reducing the exposure of sensitive information by only including required fields

### Key Annotations:

- `@Builder`: (optional) Provides a flexible way to construct DTO objects, usually from entities or models
- `@Getter`, `@Setter`, `@NoArgsConstructor`, `@AllArgsConstructor`: These Lombok annotations can be used to generate boilerplate code

### Example:

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

## 4. Model (or Entity) Layer

The Model Layer (also referred to as the Entity Layer) represents the database entities and their relationships. This layer is where the actual data structures are defined, and it interacts with the Repository Layer to perform CRUD operations on the database.

### Key Responsibilities:

- Representing the database schema as Java objects (POJOs)
- Mapping database tables to Java classes using JPA or other ORM tools
- Handling relationships (e.g., one-to-many, many-to-many) between tables

### Key Annotations:

- `@Entity`: Marks the class as a JPA entity (i.e., a table in the database)
- `@Table`: Specifies the table name if different from the class name
- `@Id`: Specifies the primary key of the entity
- `@Column`: Maps fields to columns in the table
- `@ManyToOne, @ManyToMany, @OneToOne, @OneToMany`: Maps the relationships between tables
- `@JoinColum`: Indicates the foreign key column 

### Example:

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
