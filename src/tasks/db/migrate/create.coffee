colors = require('colors')
fs = require('fs')

help = ->
  console.log 'example: cake -n [file_name] db:migrate:create'

module.exports = (options)->
  if options.name?
    fileName = new Date().toJSON().replace(/[^0-9]/g, '') + "_#{options.name}.coffee"
    fs.writeFile "db/migrate/#{fileName}", '', (err)->
        console.log "file #{fileName} created".green
  else
    console.log 'missing file name'.red
    help()