# Final Project Delivery Rubric

## Contributions (or team member will receive a 0)

- Each team members must make reasonable number of contributions to group project commit history between 12/1 & 12/10
    - Just a spelling update here or there is not considered a significant contribution
- Failure to be author of contributions towards the compilation below will result in a 0 for the final group project score

## Content / Task Expectations for the `CS4900` Group Repository

This repository will contain the core of your project description, your database design, and UI / UX user flows and wireframes.

### README & MVP

It is expected that you have some "drift" from Bri's MVP packets, so you'll need to define the *current* truth of your project.

Add a `README.md` page to the repository. This is no longer your Project Proposal, but is now your description.  The README page should cover the following:

Project Information:
- [ ] Project Name *Optional* using wordmark
- [ ] Project Overview - one sentence summary
- [ ] Project Description - elaborates on overview
- [ ] Project Goals - 2-3 goals outlined based on project description
- [ ] Style - cleanliness / good formatting

Project Composition  
Link to each of the following. Along with your link, provide a one sentence summary about what the user will find there
- [ ] MVP
- [ ] UI / UX design
- [ ] Database design / Database instructions
- [ ] API repository
- [ ] Web Design repository

---

Add a file called `MVP.md` to the repository.  Remember that MVP means *Minimum Viable Product*.  In this document, revist / update the following information about the focus of your application:

- Point of View
  - [ ] Who:
  - [ ] Who NOT:
- Entities
  - [ ] What:
  - [ ] What NOT:
- Actions
  - [ ] When
  - [ ] When NOT:
- Links
  - [ ] Where:
  - [ ] Where NOT:
- Actions
  - [ ] Why:
  - [ ] Why NOT:
- [ ] Style - cleanliness / good formatting

---

### UI / UX Design

So look - no one will have the heart to tell you to toss your dream designs and make new diagrams based on reality of what your app looks like now that your group is implementing the web design portion.  If your final project is a massively different vision from your OG design, do go back to Figma and make some adjustments.  If your OG design is still your end game plan, keep it going.

Create a `README.md` file in your group's UIUX folder in the repository: 
- [ ] Screenshots of your user flow(s), wireframe(s) and brand guide
    - Your Figma accounts are NOT permanent - take this moment to grab what you need / export files / upload screenshots
- [ ] User flow(s) and wireframe(s) with include descriptions to explain the associated action / interaction
- [ ] Brand guide must have notes on tone or personality (1–2 bullet points)
- Optional (Required for Honors)
    - [ ] Iconography - https://fonts.google.com/icons - You can customize the icons to fit your style.
    - [ ] Wordmark

---

### Database Design

Use the following checklist to make sure your database design from models to scripts is polished:

Organization
- `[ ]` Content supporting DB is well organized
- `[ ]` Database folder contains README describing layout of contents
- `[ ]` Instructions on how to start DB with docker-compose / initialization script

DB Components
- `[ ]` Business queries formed into working SQL queries answerable by database
- `[ ]` docker-compose file properly starts Maria DB environment
- `[ ]` DB initialization script reflects physical model
- `[ ]` Physical Model reflects logical model
- `[ ]` Logical Model reflects conceptual model
- `[ ]` Conceptual Model is understandable

## Content / Task Expectations for the `CS4900-API` Group Repository

Review any project feedback. It is likely you will have made changes to your API service due to the UI unit. Use the below checklist to make sure things are up to code:

- `[ ]` Your Java service runs successfully
- `[ ]` Project has proper package-by-layer architecture with clearly named packages
- `[ ]` Classes, packages, methods, and variables follow Java coding standards
- `[ ]` Code is consistently formatted
- `[ ]` GET controller methods are created for one entity to find all, find by id, and find by search string
    - `[ ]` Honors: two entities with GET controller methods to find all, find by id, and find by search string  
- `[ ]` POST/PUT/DELETE controller methods are created for one or more entities 
    - `[ ]` Honors: two entities with POST / PUT / DELETE controller methods  
- `[ ]` Polished Bruno collection(s) that support testing your implemented endpoints
- `[ ]` Updated API definitions document that *also* denotes what is currently implemented (keep this up to date as your team continues implementing pieces of the API)
- `[ ]` README.md in repo with project instructions (tools needed, how to execute, how to test with Bruno)
- `[ ]` Code is pushed to the repository with a clear commit message

## Content / Task Expectations for the `CS4900-UI` Group Repository

Here is the final checklist for items in your UI repository. 

UI Implementation:
- `[ ]` Application makes one or more HTTP GET requests. (READ) Data is successfully fetched and displayed.
- `[ ]` Application makes one or more HTTP POST requests. (CREATE) A reactive form can create and POST new items via the service.
- `[ ]` Application makes one or more HTTP DELETE requests. (DELETE) UI includes functionality to delete items, which calls the service.
- `[ ]` The UI list correctly refreshes after CREATE and DELETE operations.
- `[ ]` Good commit structure based on the completion of CRUD components.

Honors (pick one or more):
- `[ ]` Application makes one or more HTTP PUT requests. (UPDATE) A reactive form can update existing items via the service.
- `[ ]` Application interfaces with an external API (not the group project API)

`README.md` in the root of the repository folder with:  
- `[ ]` required tools (Angular version, any other dependencies)
- `[ ]` how to run UI (which branch, point to API repo & instructions, how to start application)
- `[ ]` screenshot(s) or video clips of working state of application and one or two things it currently does (this should be something the user could also try)

> The README document should be cliff notes of software dependencies and what runs in your project. 