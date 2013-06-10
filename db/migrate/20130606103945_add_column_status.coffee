exports.change = (callback) ->
  data =
    table: "chat_history"
    fields:
      description: ['string', '描述']
    after: 'message'
  return callback ['addColumn', data]