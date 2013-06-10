module.exports =
  createTable: (data) ->
    data.pk = 'id' until data.pk?
    query = "CREATE TABLE `#{data.table}` (" + @getFields(data).join(',') + ", PRIMARY KEY (`id`)) " +
      "ENGINE=InnoDB DEFAULT CHARSET=utf8" + @getComment(data) + ";"

  dropTable: (data) ->
    query = "DROP TABLE `#{data.table}`";

  addColumn: (data) ->
    columns = @getFields(data)
    if data.after? 
      columns = columns.reverse().map (r) ->
        return "ADD #{r} AFTER `#{data.after}`"
    else
      columns = columns.map (r) ->
        return "ADD #{r}"
    query = "ALTER TABLE `#{data.table}` " + columns.join(',')

  delColumn: (data) ->
    deleteFields = []
    for field of data.fields
      deleteFields.push("DROP #{field}")
    query = "ALTER TABLE #{data.table} " + deleteFields.join(',')

  getFields: (data) ->
    fields = data.fields
    fieldArr = []
    if data.pk?
      fieldArr = ["`#{data.pk}` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'identify'"]
    for name of fields
      type = ""
      comment = ""
      switch fields[name][0]
        when 'string' then type = "varchar(50) NOT NULL DEFAULT ''"
        when 'int' then type = "int(10) unsigned NOT NULL DEFAULT '0'"
        when 'text' then type = "text"
        else type = fields[name][0]
      comment = if fields[name][1] then fields[name][1] else name
      fieldArr.push("`#{name}` #{type} COMMENT '#{comment}'")
    if data.timestamps
      fieldArr.push("`create_time` datetime NOT NULL")
      fieldArr.push("`update_time` datetime NOT NULL")
    return fieldArr

  getComment: (data) ->
    return if data.comment? then " COMMENT '#{data.comment}' " else ""