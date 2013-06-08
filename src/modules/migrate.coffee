async = require('async')
db = require('../db')

module.exports = class Migrate
  calledSteps: {}

  buildQuery:

    create: (data) ->
      query = "CREATE TABLE `#{data.table}` (" + @getFields(data) + ", PRIMARY KEY (`id`)) " +
        "ENGINE=InnoDB DEFAULT CHARSET=utf8" + @getComment(data) + ";"
      return query

    delete: (data) ->
      query = "DROP TABLE `#{data.table}`";
      return query;

    getFields: (data) ->
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

    getComment: (data) ->
      return if data.comment? then " COMMENT '#{data.comment}' " else ""

  register: (version, action)->
    @calledSteps[version] = [] until @calledSteps[version]?
    @calledSteps[version].unshift action
    return @

  createTable: (data, callback) ->
    return callback('missing table name') until data.table?
    table = data.table
    async.waterfall [
      ((next) ->
        db.loadDb next
      ),
      ((conn, next) =>
        query = @buildQuery.create(data)
        console.log "create table -> #{table}"
        console.log "query -> #{query}"
        conn.query query, next
      )
    ], (err, result) ->
      callback(err, result)

  deleteTable: (data, callback) ->
    return callback('missing table name') until data.table?
    table = data.table
    async.waterfall [
      ((next) ->
        db.loadDb next
        ),
      ((conn, next) =>
        query = @buildQuery.delete(data)
        console.log "delete table -> #{table}"
        console.log "query -> #{query}"
        conn.query query, next
        )
    ], (err, result) ->
      callback(err, result)

  addSchema: (version, callback)->
    async.waterfall [
      ((next)->
        db.loadDb next
      ),
      ((conn, next)->
        console.log "add schema"
        query = "INSERT INTO `schema_migrations` (version) VALUES (#{version})"
        console.log "query -> #{query}"
        conn.query query, next
      )
    ], (err, result)->
      callback(err, result)

  delSchema: (version, callback)->
    async.waterfall [
      ((next)->
        db.loadDb next
      ),
      ((conn, next)->
        console.log 'del schema'
        query = "DELETE FROM `schema_migrations` WHERE `version` = '#{version}'"
        console.log "query -> #{query}"
        conn.query query, next
      )
    ], (err, result)->
      callback(err, result)

  rollCreateTable: (data, callback)->
    @deleteTable(data, callback)

  rollback: (callback)->
    console.log 'rollback -> ' + JSON.stringify(@calledSteps)
    iterator = []
    for version of @calledSteps
      iterator.push(version)
    async.eachSeries iterator, ((version, next)=>
      async.eachSeries @calledSteps[version], ((action, _next)=>
        roll = 'roll' + action[0][0].toUpperCase() + action[0][1..]
        if typeof @[roll] == 'function'
          @[roll] action[1], _next
        else
          _next("could not find rollback function #{roll}")
        ), (_err)->
        next(_err)
      ), (err)->
      callback(err)