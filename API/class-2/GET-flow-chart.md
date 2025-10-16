```mermaid
graph TD;
    %% Define nodes
    A[Client 🧑‍💻]:::client
    B[DispatcherServlet]:::mvc
    C[Controller (aGetMapping)]:::mvc
    D[Service Layer]:::service
    E[Repository Layer (Spring Data JPA)]:::repo
    F[JPA / Hibernate]:::jpa
    G[(Database)]:::db

    %% Request flow (solid arrows)
    A -->|HTTP GET Request| B
    B -->|Maps to| C
    C -->|Calls| D
    D -->|Invokes findAll()| E
    E -->|Translates to SQL| F
    F -->|Executes Query| G

    %% Response flow (dashed arrows)
    G -.->|Returns Records| F
    F -.->|Maps to Entities| E
    E -.->|Returns Entities| D
    D -.->|Returns Entities| C
    C -.->|Serializes & Responds (JSON)| A

    %% Styles
    classDef client fill:#fffae5,stroke:#f0b400,stroke-width:2px,color:#000,font-weight:bold;
    classDef mvc fill:#e3f2fd,stroke:#2196f3,stroke-width:2px,color:#000;
    classDef service fill:#e8f5e9,stroke:#43a047,stroke-width:2px,color:#000;
    classDef repo fill:#fff3e0,stroke:#fb8c00,stroke-width:2px,color:#000;
    classDef jpa fill:#ede7f6,stroke:#7e57c2,stroke-width:2px,color:#000;
    classDef db fill:#fce4ec,stroke:#e91e63,stroke-width:2px,color:#000,font-weight:bold;

```
