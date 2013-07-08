mysql = require('mysql')
fs = require('fs')
conn = mysql.createConnection({user: 'root', host: '127.0.0.1', database: 'cakedb'})
conn.query 'SHOW CREATE TABLE chat_history', (err, result)->
  console.log result
  process.exit()
  ddl = result[0]['Create Table']
  console.log ddl
  process.exit()
  fs.writeFile 'chat_history.sql', ddl, (err)->
    console.log 'saved'
    conn.end()
