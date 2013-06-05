colors = require('colors')

exports.A = class
  a: ->

exports.help = ->
  console.log "example:"
  console.log "  cake -v 1 db:rollback"
  console.log "  cake -v 20130530093101810 db:rollback"
exports.main = (options)->
  version = if options.version? then options.version else 1
  if !/\d+/.test(version)
    console.log 'invalid version'.red
    return @help()
  else if /\d{17}/.test(version)
    console.log "rollback to version #{version}"
  else
    console.log "rollback last #{version} versions"