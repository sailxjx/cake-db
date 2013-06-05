fs = require('fs')
async = require('async')
colors = require('colors')
db = require('../../db')
config = require('../../config')

calledSteps = []

buildQuery =
  create: (data)->
    query = "CREATE TABLE `#{data.table}` (" + @getFields(data) + ", PRIMARY KEY (`id`))
    ENGINE=InnoDB DEFAULT CHARSET=utf8" + @getComment(data) + ";"
    return query
  getFields: (data)->
    fields = data.fields
    fieldArr = ["`id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'identify'"]
    for name of fields
      type = ""
      comment = ""
      switch fields[name][0]
        when 'string' then type = "varchar(50) NOT NULL DEFAULT ''"
        when 'int' then type = "int(10) unsigned NOT NULL DEFAULT '0'"
        when 'text' then type = "text"
        else type = fields[name][0]
      comment = if fields[name][1] then fields[name][1] else name
      fieldArr.push("`#{name}` #{type} COMMENT '#{comment}'")
    if data.timestamps
      fieldArr.push("`create_time` datetime NOT NULL")
      fieldArr.push("`update_time` datetime NOT NULL")
    return fieldArr.join(',')
  getComment: (data)->
    return if data.comment? then " COMMENT '#{data.comment}' " else ""

mixFoos =
  createTable: (table, data, callback)->
    calledSteps.push({createTable: arguments})
    async.waterfall [
      ((next)->
        db.loadDb next
      ),
      ((conn, next)->
        query = buildQuery.create(data)
        console.log "create table #{table}"
        console.log "query -> #{query}"
        conn.query query, next
      )
    ], (err, result)->
      callback(err, result)
  rollback: (callback)->
    console.log "rollback".red
    callback(null)
  logSchema: (version, callback)->
    calledSteps.push({logSchema: arguments})
    async.waterfall [
      ((next)->
        db.loadDb next
      ),
      ((conn, next)->
        console.log "log schema"
        query = "INSERT INTO `schema_migrations` (version) VALUES (#{version})"
        console.log "query -> #{query}"
        conn.query query, next
      )
    ], (err, result)->
      callback(err, result)

mixin = (migrate)->
  for foo of mixFoos
    migrate[foo] = mixFoos[foo] until migrate[foo]?
  return migrate

exports.main = (options)->
  console.log 'begin migrate'
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
          migrate = require("#{tPath}/#{file}")
          mixin(migrate)
          if typeof migrate.change == 'function'
            migrate.change (err, result)->
              if err?
                console.log err.toString().red
                migrate.rollback(next)
              else
                migrate.logSchema version, (err)->
                  console.log "finish migrate #{file}".green
                  next(err)
          else
            next("#{file} has no function change!")
        ), (err)->
        if err? then console.log err.toString().red else console.log 'finish migrate'.green
        process.exit()