mysql = require('mysql')
crypto = require('crypto')
config = require('./config')
conn = null

exports.loadDb = (callback) ->
  if conn?
    callback(null, conn)
  else
    dbConfig = config(config('db_env', 'db'), 'db')
    if dbConfig.database?
      connName = dbConfig.database
      delete dbConfig.database
      conn = mysql.createConnection(dbConfig)
      conn.query "CREATE DATABASE IF NOT EXISTS #{connName}", (err, result) ->
        throw err if err?
        conn.query "USE #{connName}", (err, result) ->
          throw err if err?
          callback(null, conn)
    else
      conn = mysql.createConnection(dbConfig)
      callback(null, conn)
    return true

exports.loadSchema = (callback) ->
  loadSchema = ->
    conn.query "SELECT version FROM schema_migrations", (err, result) ->
      if err? and err.code == 'ER_NO_SUCH_TABLE'
        conn.query "CREATE TABLE `schema_migrations` (
                      `version` varchar(255) NOT NULL DEFAULT '' COMMENT 'version',
                      PRIMARY KEY (`version`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='schema_migrations'",
          (err, result) ->
            callback(err, [])
      else
        schema = []
        for row of result
          schema.push(result[row]['version']) if result[row]['version']?
        callback(err, schema.sort())
  if conn?
    loadSchema()
  else
    @loadDb ->
      loadSchema()