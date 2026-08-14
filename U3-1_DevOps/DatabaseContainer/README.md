# Database Docker Container

## Starting the Database Container

1. Make sure you have Docker desktop installed for your platform: [https://www.docker.com/](https://www.docker.com/). Use the default options when prompted during installation.
2. Open a terminal
3. `cd` into the directory with `docker-compose.yml`
4. Run `docker compose up`
  - `up` will start a container per your instructions in the docker compose file including intializing the DB with your script
  - You may Ctrl+C out of this - it will stop the container
  - `docker compose start` will start the container running again
5. `docker compose down` will end AND remove the container process.  You don't want to run this unless you are ready to blow away your DB and all it's data.

## Updating the docker compose file (What to change)

```
version: '3.8'

services:
  mariadb:
    image: mariadb:latest
    # Container processes must use a unique name - this one would refer to the Mr. Fix It DB
    container_name: WSU_4900_DB_Design
    restart: always
    volumes:
      # change init_mr_fix_it.sql to your DB init script name - leave everything else
      - ./init_mr_fix_it.sql:/docker-entrypoint-initdb.d/init.sql
      # - ./data:/var/lib/mysql                   # Mount a volume for data persistence (optional)
    environment:
      - MYSQL_ROOT_PASSWORD=password
      # Recommend making this table name the same as the table name in your script.  Does not actually matter
      - MYSQL_DATABASE=Mr_Fix_It
      - MYSQL_USER=user
      - MYSQL_PASSWORD=password
    ports:
      # MariaDB runs on port 3306 internal to the container.  Pick a unique host port - you'll refer to this in DBeaver
      # Mr Fix It (if running) would be bound to port 3306 on your system (and in DBeaver)
      - 3306:3306
      # Note the second value must stay 3306.  The first just needs to be available (not taken by another container)
      # 3320:3306
```

## Using DBeaver to Interact with Database

1. Install [DBeaver Community Edition](https://dbeaver.io/download/)
2. Follow connection / setup instructions in [README.md](DBeaver%20Usage%20Instructions/README.md)
  - Remember to use port according to what's in the Docker Compose file

## Running Multiple MariaDB Containers

1. Make a folder that contains a docker-compose.yml and DB init script for EACH DB
   - Make sure the compose files each use a unique host port followed by the default MariaDB port: `####:3306`
2. Run `docker compose up` (and `docker compose start` here forward) to initialize and start the container.  Run this in each folder.
3. In DBeaver, establish a connection to EACH MariaDB container by specifying the unique host port defined in the docker-compose.yml file for each DB

## Troubleshooting

Port is already in use (sometimes also a password error)
- you already have MariaDB installed on your host system. Choose a different host port in your docker-compose.yml file.
- you already have a container using that host port. Choose a different host port in your docker-compose.yml file.


