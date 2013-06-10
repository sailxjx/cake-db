CREATE TABLE `chat_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'identify',
  `room` varchar(50) NOT NULL DEFAULT '' COMMENT '房间',
  `appid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '应用id',
  `username` varchar(50) NOT NULL DEFAULT '' COMMENT '用户名',
  `message` text COMMENT '消息',
  `description` varchar(50) NOT NULL DEFAULT '' COMMENT '描述',
  `create_time` datetime NOT NULL,
  `update_time` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='聊天记录表'