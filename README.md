# Climb-Core
Handles all database builds, migrations, table and schema generation 

Provides Data handling and abstractions in both Java and Python 

Currently supports: PostgreSQL, MongoDB

Requirements: PostgreSQL 9.4+, MongoDB 3.2.7 
## Setup:
If constructing new database from scratch, first create the database league_analytics in postgres. Unfortunately, flyway does not support creating Databases programmatically, so you must login to PostgreSQL and run the command:

```CREATE DB League_analytics;```

Next we generate the desired schema by running: 
```
./gradlew flywaymigrate
```

If database contains old data:
```
./gradlew flywayclean flywaymigrate
```
Note: MongoDB requires no migrations, simply start your local mongo server
