# Databases
Handles all database builds, migrations, table and schema generation 
Currently supports: PostgreSQL
## How to build postgres:
If constructing new database from scratch, first create the database league_analytics in postgres: 
> ./gradlew flywaymigrate

If database contains old data:
> ./gradlew flywayclean flywaymigrate
