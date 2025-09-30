# Database Docker Container

## Starting the Database Container

1. Make sure you have Docker desktop installed for your platform: [https://www.docker.com/](https://www.docker.com/). Use the default options when prompted during installation.
2. Open a terminal
3. `cd` into the directory with `docker-compose.yml`
4. Run `docker compose up`

## Updating the init script

1. Copy `docker-compose.yml` to the root of your group repo.
2. Create a file called `init.sql` in the same location
3. Change line 9 in `docker-compose.yml` to the following `- ./init_mr_fix_it.sql:/docker-entrypoint-initdb.d/init.sql`

## Using DBeaver to Interact with Database

1. Install [DBeaver Community Edition](https://dbeaver.io/download/)
2. Follow connection / setup instructions in [README.md](DBeaver%20Usage%20Instructions/README.md)