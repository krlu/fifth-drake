Fifth-Drake
===========
This is the core application that we are building.

# Requirements
 - PostgreSQL 9.4
 - MongoDB 3.2.7
 - Sbt 0.13.11

# Setup
There's a few parts to setup when first initializing this project:
 - Frontend package installation
 - Database Migrations

## Frontend dependencies
You will need to install a few components for the front end. You can do so via
the following command:

`npm install && elm package install`

## Database Initialization and Migrations
You will also need to create a new database called league\_analytics in
postgres. Flyway cannot create the database for you programmatically. However,
after creating that database flyway will handle all other tasks for you. In
order to create the database, you can use `createdb league_analytics` on the
command line or `CREATE DATABASE league_analytics;` in psql.

After the database is created, you can simply use the following command to
actually create the proper schema structure:

`sbt -Dflyway.user=$postgresUser flywayMigrate`

For development purposes, you may need to use the following, but NEVER run this
in production. The command drops all you existing data and migrates reapplies
the schemas from scratch.

`sbt -Dflyway.user=$postgresUser flywayClean flywayMigrate`

# Running play server for both front and backend
You can run the play server using activator. To do so, simply run:
`./bin/activator ui`

This will launch a server that will continuously build any changes in your code
so that you may simply reload the webpage. You will first connect to
`http://localhost:8888` and from there use the `run` tab to launch the
application.

# Run developement server
It's possible that you'll want a lighter weight server to rapidly test front end
changes. You will likely not need this, but as of now, it is supported via the
following command.

`npm run dev`

# Style
Quick notes on style in this repo
 - Style is enforced by scalastyle. You can find the rules in
   `project/scalastyle-config.xml`
 - Names should conform to [Google's style guide](https://google.github.io/style
guide/javaguide.html#s5.1-identifier-names)
 - Use 2 spaces for indentation
 - As much as I wish to use tabs, it's difficult to enforce proper usage, so
   we'll be indenting with spaces.
