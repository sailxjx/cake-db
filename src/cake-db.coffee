path = require('path')
fs = require('fs')
global.__basepath = fs.realpathSync('.')

run = (taskName, options)->
  taskPath = taskName.replace(/:/g, '/')
  try
    return require("./tasks/#{taskPath}")(options)
  catch e
    throw e

tasks =
  'db:migrate': 'migrate the database'
  'db:migrate:create': 'create a migrate file'
  'db:migrate:status': 'display status of migrations'

exports.tasks = ->
  option '-h', '--help', 'show helps'
  option '-n', '--name [name]', 'set the migrate file name'

  for key of tasks
    task key, tasks[key], (options)->
      for taskName in options.arguments
        run(taskName, options)