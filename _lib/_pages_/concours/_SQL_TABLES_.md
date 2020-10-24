#### Table des données du concours

~~~SQL

DROP TABLE IF EXISTS `concours`;
CREATE TABLE `concours` (
  annee       VARCHAR(4) NOT NULL,
  theme       VARCHAR(100) NOT NULL,
  theme_d     TEXT DEFAULT NULL,
  step        INTEGER(1) NOT NULL DEFAULT 0,
  prix1       VARCHAR(200),
  prix2       VARCHAR(200),
  prix3       VARCHAR(200),
  prix4       VARCHAR(200),
  prix5       VARCHAR(200),
  created_at  VARCHAR(10),
  updated_at  VARCHAR(10)
);

~~~

La table qui contient les participants (qui peuvent participer à plusieurs
concours)

~~~SQL

DROP TABLE IF EXISTS `concours_concurrents`;
CREATE TABLE `concours_concurrents` (
  id              INT(12)  PRIMARY KEY AUTO_INCREMENT,
  session_id      VARCHAR(64) NOT NULL,
  concurrent_id   VARCHAR(14) NOT NULL,
  mail            VARCHAR(255) NOT NULL,
  patronyme       VARCHAR(200) NOT NULL,
  sexe            VARCHAR(1) NOT NULL,
  options         VARCHAR(8) DEFAULT "00000000",
  created_at      VARCHAR(10),
  updated_at      VARCHAR(10)
);

~~~

### Table de participation

~~~SQL

DROP TABLE IF EXISTS `concurrents_per_concours`;
CREATE TABLE `concurrents_per_concours`(
  annee             VARCHAR(4) NOT NULL,
  concurrent_id     VARCHAR(14) NOT NULL,
  titre             VARCHAR(200),
  auteurs           VARCHAR(255) DEFAULT NULL,
  keywords          VARCHAR(255) DEFAULT NULL,
  prix              VARCHAR(1), --  0, 1, 2, ou 3
  specs             VARCHAR(8) DEFAULT "00000000",
  created_at        VARCHAR(10),
  updated_at        VARCHAR(10)
);

~~~
