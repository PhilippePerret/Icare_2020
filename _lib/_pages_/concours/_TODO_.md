# TODO LIST

## Identifiant d'un inscrit

~~~

001 20210123 234 => 00120210123234
--- -------- ---
 ^     ^      ^
 |     |      |_____ Numéro d'inscription
 |     |
 |     |_____ Date d'inscription
 |    
 |____ Numéro du concours

~~~

* confirmation du mail de l'inscrit
  À son inscription, on lui attribue un identifiant

### Table des données

concours

id          INTEGER  AUTO_INCREMENTE
concours_id VARCHAR(3)
user_id     VARCHAR(14)
user_mail   VARCHAR(255)
specs       VARCHAR(8)
            bit 0     Confirmation mail
            bit 1     Dossier complet (validé)
            bit 7     Résultat (0: rien, 1: 1er prix, 2: 2e, 3: 3e)
created_at  VARCHAR(10)
updated_at  VARCHAR(10)
