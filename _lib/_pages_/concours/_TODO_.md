# TODO LIST

Voir dans GHI les tâches avec le tag 'concours'.

## Identifiant d'un inscrit

~~~

20210123 234 => 20210123234
-------- ---
   ^      ^
   |      |_____ Numéro d'inscription
   |
   |_____ Date d'inscription


~~~

* confirmation du mail de l'inscrit
  À son inscription, on lui attribue un identifiant

### Table des données

La table qui contient les participants (qui peuvent participer à plusieurs
concours)

~~~SQL

DROP TABLE IF EXISTS `concours_concurrents`;
CREATE TABLE `concours_concurrents` (
  id              INT(12)  PRIMARY KEY AUTO_INCREMENT,
  session_id      VARCHAR(64) NOT NULL,
  user_id         VARCHAR(14) NOT NULL,
  user_mail       VARCHAR(255) NOT NULL,
  patronyme       VARCHAR(200) NOT NULL,
  sexe            VARCHAR(1) NOT NULL,
  mail_confirmed  BOOLEAN DEFAULT FALSE,
  created_at      VARCHAR(10),
  updated_at      VARCHAR(10)
);

~~~

### Table de participation

~~~SQL

DROP TABLE IF EXISTS `concours`;
CREATE TABLE `concours`(
  annee             VARCHAR(4) NOT NULL,
  user_id           VARCHAR(14) NOT NULL,
  dossier_complete  BOOLEAN DEFAULT FALSE,
  fiche_required    BOOLEAN DEFAULT TRUE,
  titre             VARCHAR(200),
  prix              VARCHAR(1), --  0, 1, 2, ou 3
  created_at        VARCHAR(10),
  updated_at        VARCHAR(10)
);

~~~
