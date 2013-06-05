colors = require('colors')
fs = require('fs')
moment = require('moment')

exports.help = ->
  console.log "example:"
  console.log "  cake -n [file_name] db:migrate:create"

exports.main = (options)->
  if options.name?
    fileName = moment().format('YYYYMMDDHHmmss') + "_#{options.name}.coffee"
    fs.writeFile "db/migrate/#{fileName}", '', (err)->
        console.log "file #{fileName} created".green
  else
    console.log 'missing file name'.red
    @help()