-- Pour la table contenant les ids à usage unique
--

USE icare_db;

DROP TABLE IF EXISTS `unique_usage_ids`;

CREATE TABLE `unique_usage_ids` (
  uuid        INT(5),
  session_id  VARCHAR(32),
  user_id     INT(11),
  scope       VARCHAR(32),
  created_at  INT(10),
  updated_at  INT(10)
);
