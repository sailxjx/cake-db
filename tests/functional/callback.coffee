a = (err, callback)->
  return callback() if err?
  console.log 'you will not see me'

b = ->
  console.log 'I am a callback'

a('error', b)

#normal

first = (callback)->
  console.log 'I am the first function'
  callback()

second = (callback)->
  console.log 'I am the second function'
  callback()

third = ()->
  console.log 'I am the third function'

first ->
  second ->
    third()

# use async

async = require('async')

async.waterfall [
  first,
  second,
  third
], (err)->
