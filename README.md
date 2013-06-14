cake-migrate
============

A database migrate module with cake task

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