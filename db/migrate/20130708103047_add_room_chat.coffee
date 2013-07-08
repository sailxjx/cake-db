exports.change = (callback) ->
  query = "INSERT INTO chat_history(`room`, `appid`, `username`) VALUES ('chat', '001', '聊天用户')";
  return callback ['query', query]

exports.rollback = (callback) ->
  query = "DELETE FROM chat_history WHERE `room` = 'chat'";
  return callback ['query', query]