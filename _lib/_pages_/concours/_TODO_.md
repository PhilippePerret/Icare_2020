# TODO LIST

Voir dans GHI les tâches avec le tag 'concours'.

## Identifiant d'un inscrit

L'identifiant est construit avec la date et le temps courant au moment de l'inscription : Année, mois, jour, heures, minutes et secondes. Par exemple 2020, 11, 13, 10, 44, 32 sans espaces ni virgules ("20201113104432"). Si cet identifiant est déjà trouvé dans la base (très improbable, on ajoute une seconde.)

### Table des données

#### Table des données du concours

~~~SQL
DROP TABLE IF EXISTS `concours`;
CREATE TABLE `concours` (
  annee       VARCHAR(4) NOT NULL,
  theme       VARCHAR(100) NOT NULL,
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
  dossier_complete  BOOLEAN DEFAULT FALSE,
  titre             VARCHAR(200),
  prix              VARCHAR(1), --  0, 1, 2, ou 3
  options           VARCHAR(8) DEFAULT "00000000",
  created_at        VARCHAR(10),
  updated_at        VARCHAR(10)
);

~~~
