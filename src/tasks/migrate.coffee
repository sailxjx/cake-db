fs = require('fs')
config = require('../config')
relativePath = 'db/migrate'

(->
  targetPath = global.__basepath
  for dir in relativePath.split('/')
    targetPath += "/#{dir}"
    fs.mkdirSync(targetPath) until fs.existsSync(targetPath)
  )()

helps =
  create: ->
    console.log 'example: cake -n [file_name] db:migrate:create'

exports.help = (task)->
  helps[task]() if helps[task]? else console.log 'missing help'

exports.migrate = (options)->
  console.log config('dev')

exports.create = (options)->
  if options.name?
    fileName = new Date().toJSON().replace(/[^0-9]/g, '') + "_#{options.name}.coffee"
    fs.writeFile "#{relativePath}/#{fileName}", '', (err)->
      console.log "file #{fileName} created"
  else
    console.log 'missing file name'
    helps.create()