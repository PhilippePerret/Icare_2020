CREATE TABLE `frigo_users` (
  discussion_id INT(11) NOT NULL,
  user_id INT(11) NOT NULL,
  last_message_id INT(11) DEFAULT NULL,
  created_at INT(10) NOT NULL,
  updated_at INT(10) NOT NULL,
  PRIMARY KEY(discussion_id, user_id)
);
