```mermaid
graph TD;
    A[Client] -->|HTTP GET Request| B[DispatcherServlet];
    B -->|Maps to| C[Controller (@GetMapping)];
    C -->|Calls| D[Service Layer];
    D -->|Calls findAll()| E[Repository Layer];
    E -->|Translates to SQL| F[JPA/Hibernate];
    F -->|Executes Query| G[Database];
    
    %% Response path (dashed arrows)
    G -.->|Returns Records| F;
    F -.->|Maps to Entities| E;
    E -.->|Returns Entities| D;
    D -.->|Returns Entities| C;
    C -.->|Serializes & Responds| A;
```
