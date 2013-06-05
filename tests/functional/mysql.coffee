mysql = require('mysql')
conn = mysql.createConnection({
  user: 'root',
  host: '127.0.0.1',
  database: 'sayhello'
  })

conn.query 'SELECT * FROM chat_history', (err, result)->
  console.log result