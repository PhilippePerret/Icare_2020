CREATE TABLE `qdd_lectures` (
  icdocument_id   INT(11) NOT NULL,
  user_id         INT(11) NOT NULL,
  cote_original   TINYINT,
  cote_comments   TINYINT,
  comments        TEXT,
  PRIMARY KEY(icdocument_id, user_id)
);
