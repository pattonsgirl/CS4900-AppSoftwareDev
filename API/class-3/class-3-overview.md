.# MapStruct & Code Style

## Table of Contents
1. [MapStruct](#what-is-mapstruct)
2. [Code Style](#java-coding-standards)
3. [Commit Messages](#git-commit-messages)
4. [Package Architecture](#package-architecture-package-by-layer-vs-package-by-feature)


## What is MapStruct?

MapStruct is a compile-time code generator that simplifies the implementation of mappings between Java bean types. Instead of writing repetitive boilerplate code to convert between objects, MapStruct generates the mapping code automatically during compilation.

In a typical Spring Boot application with a layered architecture, we separate concerns between different layers:

- **Entities** (Domain Models): Represent database tables with JPA annotations
- **DTOs** (Data Transfer Objects): Represent data sent to/from clients

Mappers are what we use to convert an entity to a DTO, or a DTO to an entity. MapStruct greatly simplifies this process for us.

## Read Operations: StudentDtoMapper.toDto()

### Purpose
Convert an **Entity → DTO** when reading data from the database to send to the client.

### Implementation

**Mapper Interface** (`StudentDtoMapper.java:13-20`):
```java
@Mapper(
    componentModel = "spring",
    uses = {StudentService.class})
public interface StudentDtoMapper {

  StudentDto toDto(Student student) throws EntityNotFoundException;

  List<StudentDto> toDtoList(List<Student> studentList) throws EntityNotFoundException;
}
```

**Entity** (`Student.java:18-50`):
```java
@Entity
@Table(name = "Student")
public class Student {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  Integer id;

  String emailAddress;
  String firstName;
  String lastName;
  String phoneNumber;
  Instant lastLogin;
  Boolean active;

  @CreationTimestamp(source = SourceType.DB)
  Instant dateAdded;

  @UpdateTimestamp(source = SourceType.DB)
  Instant lastUpdated;
}
```

**DTO** (`StudentDto.java:8-30`):
```java
@Builder
@Value
public class StudentDto {
  Integer id;
  String emailAddress;
  String firstName;
  String lastName;
  String phoneNumber;
  Instant lastLogin;
  Boolean active;
  Instant dateAdded;
  Instant lastUpdated;
}
```

**Generated Implementation** (`StudentDtoMapperImpl.java:40-59`):
```java
@Override
public StudentDto toDto(Student student) throws EntityNotFoundException {
    if ( student == null ) {
        return null;
    }

    StudentDto.StudentDtoBuilder studentDto = StudentDto.builder();

    studentDto.id( student.getId() );
    studentDto.emailAddress( student.getEmailAddress() );
    studentDto.firstName( student.getFirstName() );
    studentDto.lastName( student.getLastName() );
    studentDto.phoneNumber( student.getPhoneNumber() );
    studentDto.lastLogin( student.getLastLogin() );
    studentDto.active( student.getActive() );
    studentDto.dateAdded( student.getDateAdded() );
    studentDto.lastUpdated( student.getLastUpdated() );

    return studentDto.build();
}
```

### How It Works (Read Operations)

1. **Simple Field Mapping**: Since field names match between `Student` and `StudentDto`, MapStruct automatically maps all fields
2. **Null Safety**: Generated code includes null checks
3. **Builder Pattern**: Uses the `@Builder` annotation from Lombok to construct the immutable DTO
4. **No Business Logic**: Direct field-to-field copy - suitable for simple read operations

---

## Write Operations: WorkOrderRequestDtoMapper.toEntity()

### Purpose
Convert a **DTO → Entity** when receiving data from the client to persist to the database.

### Implementation

**Mapper Interface** (`WorkOrderRequestDtoMapper.java:15-36`):
```java
@Mapper(
    componentModel = "spring",
    uses = {
      LocationService.class,
      MaintenanceTechnicianService.class,
      RoomIdDtoMapper.class,
      StudentService.class,
      WorkOrderCategoryService.class,
      WorkOrderService.class,
      WorkOrderStatusService.class
    })
public interface WorkOrderRequestDtoMapper {

  @Mapping(target = "orderNumber", ignore = true)
  @Mapping(target = "student", source = "studentId")
  @Mapping(target = "category", source = "categoryId")
  @Mapping(target = "status", source = "statusCode")
  @Mapping(target = "maintenanceTechnician", source = "maintenanceTechnicianCode")
  @Mapping(target = "appointmentCompleted", ignore = true)
  @Mapping(target = "dateAdded", ignore = true)
  @Mapping(target = "dateUpdated", ignore = true)
  WorkOrder toEntity(WorkOrderRequestDto workOrderRequestDto) throws EntityNotFoundException;
}
```

**Request DTO** (`WorkOrderRequestDto.java:9-33`):
```java
@Builder
@Value
public class WorkOrderRequestDto {
  Integer studentId;
  RoomIdDto room;
  Integer categoryId;
  String statusCode;
  String title;
  String description;
  LocalDate dateRequested;
  String maintenanceTechnicianCode;
  Instant appointmentScheduled;
  String completionNotes;
}
```

**Entity** (`WorkOrder.java:19-77`):
```java
@Entity
@Table(name = "Work_Order")
public class WorkOrder {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  Integer orderNumber;

  @ManyToOne
  Student student;

  @ManyToOne
  Room room;

  @ManyToOne
  WorkOrderCategory category;

  @ManyToOne
  WorkOrderStatus status;

  String title;
  String description;
  LocalDate dateRequested;

  @ManyToOne
  MaintenanceTechnician maintenanceTechnician;

  Instant appointmentScheduled;
  Instant appointmentCompleted;
  String completionNotes;

  @CreationTimestamp
  Instant dateAdded;

  @UpdateTimestamp
  Instant dateUpdated;
}
```

**Generated Implementation** (`WorkOrderRequestDtoMapperImpl.java:36-56`):
```java
@Override
public WorkOrder toEntity(WorkOrderRequestDto workOrderRequestDto) throws EntityNotFoundException {
    if ( workOrderRequestDto == null ) {
        return null;
    }

    WorkOrder workOrder = new WorkOrder();

    workOrder.setStudent( studentService.getStudentById( workOrderRequestDto.getStudentId() ) );
    workOrder.setCategory( workOrderCategoryService.getWorkOrderCategoryById( workOrderRequestDto.getCategoryId() ) );
    workOrder.setStatus( workOrderStatusService.getWorkOrderStatusByCode( workOrderRequestDto.getStatusCode() ) );
    workOrder.setMaintenanceTechnician( maintenanceTechnicianService.getMaintenanceTechnicianByCode( workOrderRequestDto.getMaintenanceTechnicianCode() ) );
    workOrder.setRoom( locationService.getRoomByKey( roomIdDtoMapper.toEntity( workOrderRequestDto.getRoom() ) ) );

    workOrder.setTitle( workOrderRequestDto.getTitle() );
    workOrder.setDescription( workOrderRequestDto.getDescription() );
    workOrder.setDateRequested( workOrderRequestDto.getDateRequested() );
    workOrder.setAppointmentScheduled( workOrderRequestDto.getAppointmentScheduled() );
    workOrder.setCompletionNotes( workOrderRequestDto.getCompletionNotes() );

    return workOrder;
}
```

### How It Works (Write Operations)

1. **Service Integration**: The `uses` parameter tells MapStruct to inject services for lookups
2. **ID → Entity Resolution**: IDs from the DTO are resolved to full entity objects via service calls
    - `studentId` (Integer) → `student` (Student entity) via `studentService.getStudentById()`
    - `categoryId` (Integer) → `category` (WorkOrderCategory entity) via `workOrderCategoryService.getWorkOrderCategoryById()`
3. **Ignored Fields**: Fields marked with `@Mapping(target = "...", ignore = true)` are not set by the mapper:
    - `orderNumber`: Auto-generated by database
    - `appointmentCompleted`: Set later in workflow
    - `dateAdded`/`dateUpdated`: Managed by `@CreationTimestamp` and `@UpdateTimestamp`
4. **Nested Mapping**: Uses other mappers (`RoomIdDtoMapper`) for complex nested objects
5. **Validation**: Service methods throw `EntityNotFoundException` if referenced entities don't exist

---

## Example: The Complete Flow

### GET Request (Read Operation)
```
Database → Student Entity → StudentDtoMapper.toDto() → StudentDto → JSON Response
```
The mapper simply copies fields from the entity to create a clean DTO for the API response.

### POST Request (Write Operation)
```
JSON Request → WorkOrderRequestDto → WorkOrderRequestDtoMapper.toEntity() → WorkOrder Entity → Database
```

## MapStruct Configuration

### Annotation Parameters

- `componentModel = "spring"`: Makes MapStruct generate Spring beans (`@Component`)
- `uses = {ServiceClass.class}`: Injects services for custom mapping logic
- `@Mapping`: Configures specific field mappings
    - `target`: The destination field in the entity
    - `source`: The source field from the DTO
    - `ignore = true`: Skip mapping for this field

### Build-Time Code Generation

MapStruct runs during compilation (annotation processing) and generates implementation classes:
- `StudentDtoMapperImpl.java`: Generated implementation of `StudentDtoMapper`
- `WorkOrderRequestDtoMapperImpl.java`: Generated implementation of `WorkOrderRequestDtoMapper`

These generated classes are what Spring actually injects at runtime.

---

## Java Coding Standards

### Code Style

In an enterprise setting, it is especially important to adhere to coding standards. This makes for a consistent codebase that any developer can easily jump in and begin working on. In addition, CI/CD (Continuous Integration, Continuous Deployment) processes will inspect code styles and fail builds if it does not meet configured standards.

The [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html) is generally an accepted standard. The important thing is to be clear and consistent.

`mr-fixit-service` (and your project if you followed instructions) is configured to use `spotless`, which will automatically format your code for you. Make sure you have the correct extensions (found in the README of `mr-fixit-service`), and then you can run this in the terminal of your project to reformat your code:


`./gradlew spotlessApply
`

---
## git commit messages

Your future self, and your teammates, will thank you for writing clear, informative commit messages. [Read this](https://cbea.ms/git-commit/) to take your messages to the next level.

> As an aside, [here is a general git cheat sheet](https://git-scm.com/cheat-sheet)

---

## Package Architecture: Package-by-Layer vs. Package-by-Feature

There are two primary approaches to organizing code in a software project: **package-by-layer** and **package-by-feature**. Each has its own advantages and trade-offs.

### Package-by-Layer (current architecture of `mr-fixit-service`)

package-by-layer organizes code based on technical concerns. All classes of the same type are grouped together regardless of which business feature they support.

### `mr-fixit-service` Project Structure
```
com.winsupply.mrfixitservice/
├── config/
│   ├── H2TcpConfig.java
│   └── JpaAuditingConfig.java
├── controller/
│   ├── LocationController.java
│   ├── MaintenanceTechnicianController.java
│   ├── StudentController.java
│   └── WorkOrderController.java
├── dto/
│   ├── BuildingDto.java
│   ├── MaintenanceTechnicianDto.java
│   ├── RoomDto.java
│   ├── RoomIdDto.java
│   ├── RoomTypeDto.java
│   ├── StudentDto.java
│   ├── WorkOrderCategoryDto.java
│   ├── WorkOrderDto.java
│   ├── WorkOrderRequestDto.java
│   └── WorkOrderStatusDto.java
├── mapper/
│   ├── BuildingDtoMapper.java
│   ├── MaintenanceTechnicianDtoMapper.java
│   ├── RoomDtoMapper.java
│   ├── RoomIdDtoMapper.java
│   ├── RoomTypeDtoMapper.java
│   ├── StudentDtoMapper.java
│   ├── WorkOrderCategoryDtoMapper.java
│   ├── WorkOrderDtoMapper.java
│   ├── WorkOrderRequestDtoMapper.java
│   └── WorkOrderStatusDtoMapper.java
├── model/
│   ├── composite/
│   │   └── RoomId.java
│   ├── Building.java
│   ├── MaintenanceTechnician.java
│   ├── Room.java
│   ├── RoomType.java
│   ├── Student.java
│   ├── WorkOrder.java
│   ├── WorkOrderCategory.java
│   └── WorkOrderStatus.java
├── repository/
│   ├── BuildingRepository.java
│   ├── MaintenanceTechnicianRepository.java
│   ├── RoomRepository.java
│   ├── RoomTypeRepository.java
│   ├── StudentRepository.java
│   ├── WorkOrderCategoryRepository.java
│   ├── WorkOrderRepository.java
│   └── WorkOrderStatusRepository.java
├── service/
│   ├── LocationService.java
│   ├── MaintenanceTechnicianService.java
│   ├── StudentService.java
│   ├── WorkOrderCategoryService.java
│   ├── WorkOrderService.java
│   └── WorkOrderStatusService.java
└── MrFixitServiceApplication.java
```

### Advantages
- **Clear separation of concerns**: Each layer has a single responsibility
- **Consistent architecture**: Easy to enforce architectural patterns across the application
- **Familiar pattern**: Most developers are familiar with this structure
- **Easy to find classes by type**: All controllers, services, repositories are grouped together

### Disadvantages
- **High coupling between layers**: Changes to one feature often require modifications across multiple packages
- **Poor encapsulation**: Related feature code is scattered across the codebase
- **Difficult to assess feature scope**: Understanding a single feature requires navigating multiple packages
- **Harder to modularize**: Extracting a feature into a separate module requires gathering files from multiple locations
- **Package bloat**: As the application grows, each layer package becomes increasingly large

---

### Package-by-Feature

package-by-feature organizes code around business capabilities or features. All classes related to a specific feature are grouped together regardless of their technical layer.

### If `mr-fixit-service` used package-by-feature
```
com.winsupply.mrfixitservice/
├── common/
│   └── config/
│       ├── H2TcpConfig.java
│       └── JpaAuditingConfig.java
├── workorder/
│   ├── controller/
│   │   └── WorkOrderController.java
│   ├── dto/
│   │   ├── WorkOrderCategoryDto.java
│   │   ├── WorkOrderDto.java
│   │   ├── WorkOrderRequestDto.java
│   │   └── WorkOrderStatusDto.java
│   ├── mapper/
│   │   ├── WorkOrderCategoryDtoMapper.java
│   │   ├── WorkOrderDtoMapper.java
│   │   ├── WorkOrderRequestDtoMapper.java
│   │   └── WorkOrderStatusDtoMapper.java
│   ├── model/
│   │   ├── WorkOrder.java
│   │   ├── WorkOrderCategory.java
│   │   └── WorkOrderStatus.java
│   ├── repository/
│   │   ├── WorkOrderCategoryRepository.java
│   │   ├── WorkOrderRepository.java
│   │   └── WorkOrderStatusRepository.java
│   └── service/
│       ├── WorkOrderCategoryService.java
│       ├── WorkOrderService.java
│       └── WorkOrderStatusService.java
├── location/
│   ├── controller/
│   │   └── LocationController.java
│   ├── dto/
│   │   ├── BuildingDto.java
│   │   ├── RoomDto.java
│   │   ├── RoomIdDto.java
│   │   └── RoomTypeDto.java
│   ├── mapper/
│   │   ├── BuildingDtoMapper.java
│   │   ├── RoomDtoMapper.java
│   │   ├── RoomIdDtoMapper.java
│   │   └── RoomTypeDtoMapper.java
│   ├── model/
│   │   ├── composite/
│   │   │   └── RoomId.java
│   │   ├── Building.java
│   │   ├── Room.java
│   │   └── RoomType.java
│   ├── repository/
│   │   ├── BuildingRepository.java
│   │   ├── RoomRepository.java
│   │   └── RoomTypeRepository.java
│   └── service/
│       └── LocationService.java
├── technician/
│   ├── controller/
│   │   └── MaintenanceTechnicianController.java
│   ├── dto/
│   │   └── MaintenanceTechnicianDto.java
│   ├── mapper/
│   │   └── MaintenanceTechnicianDtoMapper.java
│   ├── model/
│   │   └── MaintenanceTechnician.java
│   ├── repository/
│   │   └── MaintenanceTechnicianRepository.java
│   └── service/
│       └── MaintenanceTechnicianService.java
├── student/
│   ├── controller/
│   │   └── StudentController.java
│   ├── dto/
│   │   └── StudentDto.java
│   ├── mapper/
│   │   └── StudentDtoMapper.java
│   ├── model/
│   │   └── Student.java
│   ├── repository/
│   │   └── StudentRepository.java
│   └── service/
│       └── StudentService.java
└── MrFixitServiceApplication.java
```

### Advantages
- **High cohesion**: All code related to a feature is in one place
- **Better encapsulation**: Feature implementation details can be kept private to the package
- **Easier to understand feature scope**: Navigate to one package to see everything about a feature
- **Easier to modularize**: Each feature package can potentially become its own module
- **Easier to delete features**: Remove one package to eliminate a feature entirely
- **Better team organization**: Different teams can own different feature packages with minimal conflicts
- **Scales better**: As the application grows, features remain organized and navigable

### Disadvantages
- **Less obvious architectural layers**: The layered architecture is less visually apparent
- **Potential code duplication**: Shared utilities might be duplicated if not properly extracted to common packages
- **Requires more discipline**: Developers must be careful about dependencies between features
- **Less familiar**: Some developers may find this structure initially confusing

---




