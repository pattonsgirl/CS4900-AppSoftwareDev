# Group Assignment - Database

In your GROUP database repository, assert all of the following requirements on your `main` branch. You may create sub-folders to further organize information / files

All documents must be updated to address feedback given for submissions. Ex - if you received physical model feedback that effects the conceptual model, redraw it.  If it effected the table initialization script, make sure the script reflects those changes.

Collaborate with your group members to finalize your GROUP submissions of the following documents:

- Model summary file containing (visually):
    - Conceptual model
        - may be hand-drawn if the picture / scan is clean and legible, otherwise must be created in a diagramming / drawing software
    - Logical model
        - must be created in a diagramming / drawing software (hand-drawn is not acceptable)
    - Physical model
        - **NOTE** include the "source code" exported to a file if you used a platform like `dbdiagram.io`
    - Label each model (headers recommended to break up document)
    - Include a description of each model
- Table initialization
    - DB initialization script with all tables required for your DB
        - **NOTE** where possible / logical, add 3-4 entries to your tables so that your team can have a base of data to begin with (and to run some basic queries)
    - docker-compose.yml file
    - `README.md` file with instructions of how to use `docker compose` to stand up your DB and how to connect to it with `DBeaver`
- Business questions & SQL queries
    - A file presenting 3-5 business questions & the SQL queries that will answer them from your database.
    - A minimum of one query should be something to display in a "dashboard" view of your application (think on the homepage)
- `README.md` file describing contents in the root of the repo.

## Rules of Contribution

Each team member must make *some* contribution to the GROUP repository for these required Database elements, as proved by their authorship in the commit history of the repository.  If a group member has no contributions, they will receive a 0 grade for this portion of the group assignment - all other team members will receive the score set in the feedback.

It is strongly recommended to have group members make PR requests of changes to documents via branches.

## Rubric

Total Score: / 13

Organization
- [ ] Content supporting DB is well organized
- [ ] Database folder contains README describing layout of contents and links to supporting files
- [ ] Instructions on how to start DB with docker-compose / initialization script

DB Components
- [ ] Business queries formed into working SQL queries answerable by database
- [ ] docker-compose file properly starts Maria DB environment
- [ ] DB initialization script reflects physical model
- [ ] Physical Model reflects logical model
- [ ] Logical model reflects conceptual model
- [ ] Conceptual model is understandable

DB Feedback
- [ ] Feedback for conceptual model applied to logical model
- [ ] Feedback for logical model applied to physical model
- [ ] Feedback for physical model applied to DB init script
- [ ] Feedback for business queries applied


