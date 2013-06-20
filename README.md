cake-migrate
============

A database migrate module with cake task

## usage
puts this line in your Cakefile
```
require('cake-db').tasks()
```
and add a db.json file in your config directory
```
// db.json
{
    "development": {
        "adapter": "mysql",
        "database": "cakedb",
        "user": "root",
        "password": "",
        "host": "127.0.0.1"
    },
    "production": {
        "adapter": "mysql",
        "database": "cakedb_production",
        "user": "root",
        "password": "",
        "host": "127.0.0.1"
    },
    "db_env": "development"
}
```

## commands
* cake db:migrate           # migrate the database
* cake db:migrate:create    # create a migrate file
* cake db:migrate:status    # display status of migrations
* cake db:rollback          # rollback the post migrations

## actions
* createTable
* dropTable (need self defined rollback function)
* addColumn
* dropColumn (need self defined rollback function)
