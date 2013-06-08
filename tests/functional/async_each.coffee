async = require('async')

hashMap =
  a: 'a'
  b: 'b'

iterator = []

for key of hashMap
  iterator.push(key)

async.each iterator, ((key, next)->
  console.log hashMap[key]
  next()
  ), (err)->
  console.log err
