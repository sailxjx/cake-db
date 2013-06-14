path = require('path')
fs = require('fs')
global.__basepath = fs.realpathSync('.')

run = (taskName, options) ->
  taskPath = taskName.replace(/:/g, '/')
  try
    task = require("./tasks/#{taskPath}")
    if options.help && task.help?
      return task.help()
    return task.main(options)
  catch e
    throw e

tasks =
  'db:migrate': 'migrate the database'
  'db:migrate:new': 'create a new migrate file'
  'db:migrate:status': 'display status of migrations'
  'db:schema:dump': "create a db/schema/version.json to store each table's readable schema"
  'db:rollback': 'rollback the post migrations'
  'db:structure:dump': 'dump the database structure'

exports.tasks = ->
  option '-h', '--help', 'show helps'
  option '-n', '--name [name]', 'set the migrate file name'
  option '-v', '--version [version]', 'set rollback version'

  for key of tasks
    task key, tasks[key], (options) ->
      for taskName in options.arguments
        run(taskName, options)