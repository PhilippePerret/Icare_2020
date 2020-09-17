-- Pour la table contenant les ids à usage unique
--

-- pour version online
USE icare_db;
-- Pour version locale
-- USE icare_test;
-- USE icare;

DROP TABLE IF EXISTS `unique_usage_ids`;
CREATE TABLE `unique_usage_ids` (
  uuid        VARCHAR(20),
  session_id  VARCHAR(32),
  user_id     INT(11),
  scope       VARCHAR(32),
  created_at  VARCHAR(10),
  updated_at  VARCHAR(10)
);
