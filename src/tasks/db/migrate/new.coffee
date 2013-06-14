colors = require('colors')
fs = require('fs')
moment = require('moment')

fileData =
"
exports.change = (callback) ->\n
  return callback []
"

exports.help = ->
  console.log "example:"
  console.log "  cake -n [file_name] db:migrate:new"

exports.main = (options) ->
  if options.name?
    fileName = moment().format('YYYYMMDDHHmmss') + "_#{options.name}.coffee"
    fs.writeFile "db/migrate/#{fileName}", fileData, (err) ->
      return console.log err.toString().red if err
      return console.log "file #{fileName} created".green
  else
    console.log 'missing file name'.red
    @help()
