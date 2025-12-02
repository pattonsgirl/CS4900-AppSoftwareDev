# Final Project Delivery Rubric

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