fs = require('fs')
async = require('async')
colors = require('colors')
db = require('../../db')
config = require('../../config')
Migrate = require('../../modules/migrate')

exports.main = (options)->
  console.log 'migrate start'
  tPath = "#{global.__basepath}/db/migrate"
  fs.readdir tPath, (err, fileList)->
    throw err.red if err?
    fileList.sort()
    db.loadSchema (err, schema)->
      async.eachSeries fileList, ((file, next)->
        [version] = file.split('_')
        if version in schema
          next()
        else
          console.log new Array(60).join('-')
          console.log "migrate file #{file}"
          task = require("#{tPath}/#{file}")
          if typeof task.change == 'function'
            task.change ()->
              mig = new Migrate()
              async.eachSeries arguments, ((action, _next)->
                if typeof mig[action[0]] == 'function'
                  mig[action[0]] action[1], (err, result)->
                    return _next(err) if err?
                    mig.register(version, action)  # register every success action for further rollback
                    _next()
                else
                  _next("no function called #{action[0]}")
                ), (err)->
                if err?
                  mig.rollback (_err) -> next(err)
                else
                  mig.addSchema version, next  # add schema after every successful migrate
          else
            next("#{file} has no function change!")
        ), (err)->
        if err? then console.log err.toString().red else console.log 'migrate finish'.green
        process.exit()