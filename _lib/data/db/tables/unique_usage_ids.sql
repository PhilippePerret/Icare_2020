DROP TABLE IF EXISTS `unique_usage_ids`;
CREATE TABLE `unique_usage_ids`
(
  user_id     INT(11) DEFAULT NULL, -- null par exemple lors de l'inscription
  session_id  VARCHAR(32) NOT NULL, -- obligatoire
  uuid        SMALLINT NOT NULL,    -- obligatoire
  scope       VARCHAR(32) DEFAULT NULL, -- champ d'application, pour limiter l'autorisation
  created_at VARCHAR(10) NOT NULL,
  updated_at VARCHAR(10) NOT NULL,
  PRIMARY KEY (uuid)
);
