configs =
  db: require("#{global.__basepath}/config/db")

mergeConfigs = {}

(->
  for k of configs
    for kk of configs[k]
      mergeConfigs[kk] = configs[k][kk]
  )()

module.exports = (key, file) ->
  if file? and configs[file]?
    return configs[file][key]
  else
    return mergeConfigs[key]