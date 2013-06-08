async = require('async')

arr = [1,2,3]
async.eachSeries arr, ((ele, next)->
  console.log ele
  next()
  ), (err)->
  console.log err