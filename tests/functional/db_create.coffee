config = require('../../config/db')
db = require('../../src/db')
console.log config.development
db config.development, ()->
console.log config.development
