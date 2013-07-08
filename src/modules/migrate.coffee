async = require('async')
db = require('../db')
queryBuilder = require('../query-builder')
async = require('async')

module.exports = class Migrate
  constructor: (version, task) ->
    @calledSteps = []
    @version = version
    @task = task

  start: (callback) ->
    if typeof @task.change == 'function'
      @task.change =>
        async.eachSeries arguments, ((action, next) =>
          func = @[action[0]]
          if typeof func == 'function'
            func.call @, action[1], (err, result) =>
              return next(err) if err?
              @register(action)  # register every success action for further rollback
              next()
          else
            next("no function called #{func}")
          ), (err) =>
          if err?
            @rollback (_err) ->
              callback(err)
          else
            @addSchema callback  # add schema after every successful migrate
    else
      callback("no change function!")

  register: (action) ->
    @calledSteps.unshift action
    return this

  query: (query, callback) ->
    db.loadDb (err, conn) ->
      console.log "query -> #{query}"
      conn.query query, callback

  createTable: (data, callback) ->
    return callback('missing table name') until data.table?
    @query queryBuilder.createTable(data), callback

  rollCreateTable: (data, callback) ->
    @dropTable(data, callback)

  dropTable: (data, callback) ->
    return callback('missing table name') until data.table?
    @query queryBuilder.dropTable(data), callback

  addColumn: (data, callback) ->
    return callback('missing table name') until data.table?
    @query queryBuilder.addColumn(data), callback

  rollAddColumn: (data, callback) ->
    @dropColumn(data, callback)

  dropColumn: (data, callback) ->
    return callback('missing table name') until data.table?
    @query queryBuilder.dropColumn(data), callback;

  addSchema: (callback) ->
    query = "INSERT INTO `schema_migrations` (version) VALUES (#{@version})"
    @query query, callback

  delSchema: (callback) ->
    query = "DELETE FROM `schema_migrations` WHERE `version` = '#{@version}'"
    @query query, callback

  rollback: (callback) ->
    if typeof @task.rollback == 'function'
      @task.rollback =>
        async.eachSeries arguments, ((action, next) =>
          func = @[action[0]]
          if typeof func == 'function'
            func action[1], (err, result) =>
              return next(err) if err?
              next()
          else
            next("no function called #{func}")
          ), (err) =>
          return callback(err) if err?
          @delSchema callback
    else
      console.log 'rollback -> ' + JSON.stringify(@calledSteps)
      async.eachSeries @calledSteps, ((action, next) =>
        roll = 'roll' + action[0][0].toUpperCase() + action[0][1..]
        if typeof @[roll] == 'function'
          @[roll] action[1], next
        else
          next("could not find rollback function #{roll}")
        ), (err) =>
        return callback(err) if err?
        @delSchema callback