mysql = require('mysql')
config = require('./config')
conn = null

exports.loadDb = (callback) ->
  return callback(null, conn) if conn?
  dbConfig = config(config('db_env', 'db'), 'db')
  if dbConfig.database?
    connName = dbConfig.database
    delete dbConfig.database
    conn = mysql.createConnection(dbConfig)
    conn.query "CREATE DATABASE IF NOT EXISTS #{connName}", (err, result) ->
      throw err if err?
      conn.query "USE #{connName}", (err, result) ->
        throw err if err?
        dbConfig.database = connName
        callback(null, conn)
  else
    conn = mysql.createConnection(dbConfig)
    callback(null, conn)

exports.loadSchema = (callback) ->
  @loadDb ->
    conn.query "SELECT version FROM schema_migrations", (err, result) ->
      if err? and err.code == 'ER_NO_SUCH_TABLE'
        conn.query "CREATE TABLE `schema_migrations` (
                      `version` varchar(255) NOT NULL DEFAULT '' COMMENT 'version',
                      PRIMARY KEY (`version`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='schema_migrations'",
          (err, result) ->
            callback(err, [])
      else
        schema = (row['version'] for row in result when row['version']?)
        callback(err, schema.sort())

exports.showTables = (callback) ->
  @loadDb ->
    conn.query "SHOW TABLES", (err, result) ->
      return callback(err) if err?
      tableNames = (table.Tables_in_cakedb for table in result)
      callback(err, tableNames)

exports.dumpStructure = (table, callback) ->
  @loadDb ->
    conn.query "SHOW CREATE TABLE #{table}", (err, result) ->
      return callback(err) if err?
      callback(err, result[0]['Create Table'])