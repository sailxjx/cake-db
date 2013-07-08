db = require('../../../db')
async = require('async')
colors = require('colors')
fs = require('fs')
config = require('../../../config')

exports.main = (options) ->
  console.log "structure dumping..."
  dbConfig = config(config('db_env', 'db'), 'db');
  tPath = "#{global.__basepath}/db/structure"
  db.showTables (err, tableNames) ->
    throw err.toString().red if err?
    async.each tableNames, ((tableName, next) ->
      db.dumpStructure tableName, (err, structure)->
        return next(err) if err?
        fs.writeFile "#{tPath}/#{dbConfig.database}.#{tableName}.sql", structure, (err) ->
          next(err)
      ), (err) ->
        if err? then console.log err.toString().red else console.log 'structure dump finish'.green
        process.exit()