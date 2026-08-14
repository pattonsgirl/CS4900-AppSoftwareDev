# API Specifications, Environments & CORS

## API Specifications

Generally speaking, you will follow one of three paradigms for API development: code-first, API-first, and design-first. For this class, we followed the code-first paradigm, which was mainly because of how much experience we expected you to have with API design. There are two important terms to know when discussing the three paradigms. The first is a contract, which is simply a defined agreement between two parties (normally a producer, such as an API, and a consumer, normally a UI or another API). The second is a definition, also known as a specification, which is a machine-readable, standardized format used to describe APIs. The most common is currently the OpenAPI Specification, but another common specification is the GraphQL Specification.

### Code-First

The code-first approach starts with taking the business requirements and then implementing them into code directly. In class, we started with taking the database tables you created and then implementing the models, then continuing on from there. This is a common approach for looser business requirements where the code implementation will be used to generate the API definition later on with tools such as  [springdoc-openapi](https://springdoc.org/) (internally at Winsupply we call this swagger due to OpenAPI's original project name and the annotations that it still provides).

| Advantages               | Disadvantages                                                                                                                                           |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Faster for simple APIs   | Generally forces a Waterfall Model SDLC, which can cause major delays if requirements change later in development and cost more money in the long run |
| Intuitive for developers | Can cause unnecessary development work due to lack of planning                                                                                          |
|                          | Deprioritizes documentation                                                                                                                             |

### API-First

The API-first approach focuses on defining the API endpoints by what data it needs to produce. This is generally seen as the most consistent way to start a project and ties well into the AGILE software development life cycle by identifying tasks for work based on the initial design. This also allows for an initial check to see if the API matches company-defined standards before too much (if any) code has been implemented.

### Design-First

The design-first approach will spend a lot of time upfront identifying the requirements for the API, specifically focusing on the consumers and what they need from the API. This approach is good for contractors since the work can be completely identified up front, and appropriate quotes and timeframes should come directly from the planning.


Both API-first and design-first paradigms have similar strengths and weaknesses due to their focus on upfront planning, so the table for both is listed here for your reference.

| Advantages                                                                                                                                                | Disadvantages                             |
| --------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| Allows for parallel development work because of definition                                                                                                | Needs business support for upfront design |
| If you use a specification language (such as OpenAPI), you can use that to generate documentation early to reduce potential confusion for anyone involved |                                           |
| Less likely to find issues long-term due to planning                                                                                                      |                                           |

Some companies will follow a hybrid approach and focus on both the producers and consumers when defining their APIs. This ensures that both sides of the API contract are known, and future changes should be less impactful whether they are for the producer or the consumer.

Here is an example of an OpenAPI Specification (they are normally written in YAML or JSON):
```yaml
openapi: 3.0.4
info:
  title: Sample API
  description: Optional multiline or single-line description in [CommonMark](http://commonmark.org/help/) or HTML.
  version: 0.1.9
servers:
  - url: http://api.example.com/v1
    description: Optional server description, e.g. Main (production) server
  - url: http://staging-api.example.com
    description: Optional server description, e.g. Internal staging server for testing
paths:
  /users:
    get:
      summary: Returns a list of users.
      description: Optional extended description in CommonMark or HTML.
      responses:
        "200":
          description: A JSON array of user names
          content:
            application/json:
              schema:
                type: array
                items:
                  type: string
```

## Environments

At a very high level, environments are the locations that your code and infrastructure will live in, along with the appropriate tooling to run everything. Most organizations will have multiple environments that are set up for specific points of the development process. The most common environments that you will see are Local, Integration, Quality Assurance, Staging, and Production.

### Local

The local environment is where you should spend the most time doing development work. This environment is entirely your own, and the changes you make here should not impact anything else until the code leaves this environment.

### Integration

The integration environment (commonly referred to as "develop" or "dev") is the location that changes from your local environment are merged into. This is the most volatile environment, and troubleshooting will most likely be needed to merge or resolve unforeseen issues from integration. For most teams, this is what your default branch on your repository will be pointed to since it should be what you are actively merging into.

### Quality Assurance

The quality assurance environment (commonly referred to as "QA" or "testing") is the location that thorough testing should be conducted at. If you work with a team that specializes in testing (a QA team), this is most likely where they will require the changes to be in order to test them. Outside of manual interaction with the API, there are additional types of testing, such as unit testing, integration testing, functional testing, end-to-end testing (E2E), and more. Code tests can also be required before the QA environment, and you will often see them as a requirement to merge into develop.

### Staging

The staging environment is normally used to directly match a production environment. This can be very useful to identify expected resource usage, potential hardware issues, problems with deployments, and more.

### Production

The production environment is where end users should interact with your API. This includes additional components that may be unreasonable to include in most other environments because the expected security and usage are vastly different.

> The local, integration, quality assurance, staging, and production environments are just the most common that you will see in a traditional position. Ensure that you are familiar with the appropriate development workflow and expectations when you start a new position. 

### Cross-Origin Resource Sharing

Cross-Origin Resource Sharing (CORS) is a security mechanism that is enabled by default in web browsers. According to Mozilla, "CORS is an HTTP-header based mechanism that allows a server to indicate any origins (domain, scheme, or port) other than its own from which a browser should permit loading resources. CORS also relies on a mechanism by which browsers make a "preflight" request to the server hosting the cross-origin resource, in order to check that the server will permit the actual request. In that preflight, the browser sends headers that indicate the HTTP method and headers that will be used in the actual request". For Spring Boot applications, this means that you will want to implement an appropriate configuration or use the appropriate annotation (`@CrossOrigin`) on a controller method or class to allow the expected origin to interact. Common origins are http://localhost, http://localhost:8080, and your hosted environment's fully qualified domain names (FQDNs).

Here is an example of a configuration class that is set up to allow all origins to any endpoint:

```java
@Configuration
@EnableWebMvc
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**");
    }
}
```
## Sources Used

- https://www.codecademy.com/article/environments
- https://blog.stoplight.io/api-first-api-design-first-or-code-first-which-should-you-choose
- https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS
- https://www.baeldung.com/spring-cors