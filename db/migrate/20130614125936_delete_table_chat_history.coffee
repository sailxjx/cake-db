exports.change = (callback) ->
  data =
    table: 'chat_history'
  return callback ['dropTable', data]

exports.rollback = (callback) ->
  data =
    table: "chat_history"
    fields:
      room: ['string', '房间']
      appid: ['int', '应用id']
      username: ['string', '用户名']
      message: ['text', '消息']
      description: ['string', '描述']
    timestamps: true
    comment: '聊天记录表'
  return callback ['createTable', data]