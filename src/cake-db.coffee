path = require('path')
fs = require('fs')
global.__basepath = fs.realpathSync('.')

exports.tasks = ->
  option '-h', '--help', 'show helps'
  option '-n', '--name [file]', 'set the migrate file name'

  task 'db:migrate', 'migrate the database', (options)->
    require('./tasks/migrate').migrate(options)

  task 'db:migrate:create', 'create a migrate file', (options)->
    require('./tasks/migrate').create(options)

  task 'db:migrate:status', 'display status of migrations', (options)->
    require('./tasks/migrate').status()