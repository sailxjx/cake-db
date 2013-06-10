async = require('async')
db = require('../db')
queryBuilder = require('../query-builder')

module.exports = class Migrate
  constructor: ->
    @calledSteps = {}

  register: (version, action) ->
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
      ((conn, next) ->
        query = queryBuilder.createTable(data)
        console.log "query -> #{query}"
        conn.query query, next
      )
    ], (err, result) ->
      callback(err, result)

  rollCreateTable: (data, callback) ->
    @dropTable(data, callback)      

  dropTable: (data, callback) ->
    return callback('missing table name') until data.table?
    table = data.table
    async.waterfall [
      ((next) ->
        db.loadDb next
        ),
      ((conn, next) ->
        query = queryBuilder.dropTable(data)
        console.log "query -> #{query}"
        conn.query query, next
        )
    ], (err, result) ->
      callback(err, result)

  addColumn: (data, callback) ->
    return callback('missing table name') until data.table?
    table = data.table
    async.waterfall [
      ((next) ->
        db.loadDb next
        ),
      ((conn, next) ->
        query = queryBuilder.addColumn(data);
        console.log "query -> #{query}"
        conn.query query, next
        )
    ], (err, result) ->
      callback(err, result)

  rollAddColumn: (data, callback) ->
    @dropColumn(data, callback)

  dropColumn: (data, callback) ->
    return callback('missing table name') until data.table?
    table = data.table
    async.waterfall [
      ((next) ->
        db.loadDb next
        ),
      ((conn, next) ->
        query = queryBuilder.dropColumn(data);
        console.log "query -> #{query}"
        conn.query query, next
        )
    ], (err, result) ->
      callback(err, result)

  addSchema: (version, callback) ->
    async.waterfall [
      ((next) ->
        db.loadDb next
      ),
      ((conn, next) ->
        console.log "add schema"
        query = "INSERT INTO `schema_migrations` (version) VALUES (#{version})"
        console.log "query -> #{query}"
        conn.query query, next
      )
    ], (err, result) ->
      callback(err, result)

  delSchema: (version, callback) ->
    async.waterfall [
      ((next) ->
        db.loadDb next
      ),
      ((conn, next) ->
        console.log 'del schema'
        query = "DELETE FROM `schema_migrations` WHERE `version` = '#{version}'"
        console.log "query -> #{query}"
        conn.query query, next
      )
    ], (err, result) ->
      callback(err, result)

  rollback: (callback) ->
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
        ), (_err) ->
        next(_err)
      ), (err) ->
      callback(err)