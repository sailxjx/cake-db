mysql = require('mysql')
fs = require('fs')
conn = mysql.createConnection({user: 'root', host: '127.0.0.1', database: 'cakedb'})
conn.query 'SHOW CREATE TABLE chat_history', (err, result)->
  ddl = result[0]['Create Table']
  fs.writeFile 'chat_history.sql', ddl, (err)->
    console.log 'saved'
    conn.end()