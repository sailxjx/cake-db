colors = require('colors')
fs = require('fs')
async = require('async')
db = require('../../db')
Migrate = require('../../modules/migrate')

exports.help = ->
  console.log "example:"
  console.log "  cake -v 1 db:rollback"
  console.log "  cake -v 20130530093101810 db:rollback"

exports.main = (options) ->
  version = if options.version? then options.version else 1
  rollType = 0
  tPath = "#{global.__basepath}/db/migrate"
  if !/\d+/.test(version)
    console.log 'invalid version'.red
    return @help()
  else if /\d{14}/.test(version)
    rollType = 1
    console.log "rollback to version #{version}"
  else
    rollType = 0
    console.log "rollback last #{version} versions"
  fs.readdir tPath, (err, fileList) ->
    throw err if err?
    fileHash = {}
    for file in fileList
      [v] = file.split('_')
      fileHash[v] = file
    db.loadSchema (err, schema) ->
      throw err if err?
      rollVersions = []
      if rollType == 1
        for v in schema.reverse()
          rollVersions.push(v)
          if v == version
            break
      else
        rollVersions = schema.reverse().splice(0, version)
      async.eachSeries rollVersions, ((version, next) ->
        console.log new Array(60).join('-')
        console.log "rollback version #{version}"
        if fileHash[version]?
          task = require("#{tPath}/#{fileHash[version]}")
          if typeof task.change == 'function'
            mig = new Migrate()
            task.change ->
              async.eachSeries arguments, ((action, _next) ->
                mig.register(version, action)
                _next()
                ), (err) ->
                return next(err) if err?
                mig.rollback (_err) ->
                  return next(_err) if _err?
                  mig.delSchema version, next  # delete schema after successful rollback
          else
            next('migration file has no change function')
        else
          next('could not find migration file')
        ), (err) ->
        if err? then console.log err.toString().red else console.log 'rollback finish'.green
        process.exit()