# Homework 1 - Setup Verification

## Purpose / Objectives
> This assignment creates the Angular project your team will build for the rest of the unit.
> [Mr Fix It UI](https://github.com/WSU-kduncan/mr-fixit-ui) is the reference. Run it so you can see a finished app and confirm your machine can install and serve Angular. Do not put your project code in that repository.

## Description

### 1. Run the reference app

Use [Mr Fix It UI](https://github.com/WSU-kduncan/mr-fixit-ui) as the example of a working Angular app. You will look at it in class. You will not keep building inside it.

1. Clone the reference repository:
   `git clone https://github.com/WSU-kduncan/mr-fixit-ui.git`
2. Open that folder in your editor.
3. In a terminal at the project root, run `npm ci` (or `npm install`).
   - [Class 1, terminal and npm](Class%201%20-%20Setup%20%26%20The%20Anatomy%20of%20a%20Modern%20Angular%20App.md#section-2-terminal-and-npm)
4. Start the UI with `npm start`.
5. Confirm it loads in the browser, usually at `http://localhost:4200`.
6. Start the Mr Fix It database and the Mr Fix It service so the work-order list has data.

While it is running, open these files and notice the same kinds of files you will have in your own app: `package.json`, `src/main.ts`, `src/app/app.config.ts`, `src/app/app.routes.ts`, and `src/app/app.ts`.

### 2. Prove the reference app runs

1. In Mr Fix It UI, open the work-order list.
2. Use the built-in filter so the list on screen is a subset of the full list.
3. In your group UI repository, create a branch named `yourlastname-homework-1`.
4. On that branch, add a `homework1` folder and save a screenshot named `yourlastname-hw1.png` (any image format). The screenshot must show the browser on Mr Fix It UI with the filter applied and the filtered list visible.
5. Commit and push that branch. The commit message should say what the screenshot shows.

### 3. Create the project you will keep working on

This is the app for Homework 2 through Homework 6. One teammate does the scaffold. Everyone else pulls it and runs it.

1. Clone your group UI repository. The link is in Pilot, under Course Info.
2. One group member creates a new Angular 22 app and pushes it to the default branch.
   - Node.js 22 or newer.
   - Angular CLI 22.
   - `ng new` with routing and SCSS.
   - Put the app in the root of the repository, not in a subdirectory. Same layout as the API repository, so nobody has to remember an extra path.
   - [Class 1, transfer into your repo](Class%201%20-%20Setup%20%26%20The%20Anatomy%20of%20a%20Modern%20Angular%20App.md#section-5-transfer-into-students-repo)
3. Every other group member pulls that commit, runs `npm ci` (or `npm install`), then `npm start`, and confirms the default app loads.
4. Change a heading in your new app, save, and confirm the browser updates. Then you know live reload works on the project you will actually edit.

# Rubric

Assignment score: X / 5 points

- `[ ]` Mr Fix It UI runs locally, with the database and service running.
- `[ ]` Screenshot shows a filter applied to the work-order list.
- `[ ]` Screenshot is on the `yourlastname-homework-1` branch, in `homework1/`, and the commit message is clear.
- `[ ]` The group UI repository contains a new Angular app at the repository root, with routing and SCSS, pushed to the default branch.
- `[ ]` Teammates can pull that app and run it with `npm start`.

**Feedback:**
