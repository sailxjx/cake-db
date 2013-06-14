fs = require('fs')
async = require('async')
colors = require('colors')
db = require('../../db')
Migrate = require('../../modules/migrate')

exports.main = (options) ->
  console.log 'migrate start'
  tPath = "#{global.__basepath}/db/migrate"
  fs.readdir tPath, (err, fileList) ->
    throw err.red if err?
    fileList.sort()
    db.loadSchema (err, schema) ->
      async.eachSeries fileList, ((file, next) ->
        [version] = file.split('_')
        if version in schema
          next()
        else
          console.log new Array(60).join('-')
          console.log "migrate file #{file}"
          task = require("#{tPath}/#{file}")

          mig = new Migrate(version, task)
          mig.start next
        ), (err) ->
        if err? then console.log err.toString().red else console.log 'migrate finish'.green
        process.exit()