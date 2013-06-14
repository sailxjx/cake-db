db = require('../../src/db')
db.loadDb (err, conn) ->
  conn.query 'START TRANSACTION'
  conn.query "INSERT INTO chat_history(`roomm`) VALUES ('fasdfasdf')", (err, result) ->
    console.log err
    console.log result