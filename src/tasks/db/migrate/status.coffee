colors = require('colors')
fs = require('fs')
db = require('../../../db')
async = require('async')

module.exports = (options)->
  tPath = "#{global.__basepath}/db/migrate"
  fs.readdir tPath, (err, fileList)->
    throw err if err?
    fileList.sort()
    console.log "Status\t\tMigration ID\t\tMigration Name"
    console.log new Array(80).join('-')
    db.loadSchema (err, schema)->
      async.each fileList, ((file, next)->
        [version] = file.split('_')
        if version in schema
          msg = "up\t\t#{version}\t" + file.split('.')[0].substr(version.length + 1).replace(/_/g, ' ')
          console.log msg
        else
          msg = "down\t\t#{version}\t" + file.split('.')[0].substr(version.length + 1).replace(/_/g, ' ')
          console.log msg.red
        next()
        ), (err, result)->
        console.log err.red if err?
        process.exit()