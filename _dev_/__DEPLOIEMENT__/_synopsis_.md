# Synopsis du déploiement du site de l'atelier version 2020



- [ ] [UNE SEMAINE AVANT] Prévenir les icariens que le site va être actualisé (nouvelle version)

  - [ ] Nouveau système pour les discussions frigo. Donc les discussions actuelles seront détruites. Les récupérer si nécessaire ou répondre aux derniers messages.

- [ ] Récupérer les données DB telles que décrites dans [fichier de récupération des données DB][].

- [ ] Lancer le [fichier de récupération des données DB][]. (qui va transformer toutes les données anciennes en données nouvelles)

- [ ] Créer la base `icare_db` sur [AlwaysData](https://admin.alwaysdata.com/) si ce n’est pas encore fait.

- [ ] Injecter les données récupérées et traitées dans la base `icare_db`. Pour ce faire :
	- [ ] Lancer le  [script feed](/Users/philippeperret/Sites/AlwaysData/Icare_2020/_dev_/__DEPLOIEMENT__/feed_db_icare.rb)
	- [ ] Comme on ne peut pas automatiser l'injection dans la base distante, se rendre sur PhpMySql sur [AlwaysData](https://admin.alwaysdata.com/) et injecter tous les fichiers du dossier `home/deploiement/db`.

- [ ] Uploader tout le dossier `./_lib`.

- [ ] Uploader le fichier `./favicon.ico`.

- [ ] Uploader le fichier `./config.rb`.

- [ ] METTRE LE SITE EN CHANTIER

- [ ] Uploader le dossier `./css`.

- [ ] UPloader le dossier `./js`.

- [ ] Uploader le dossier `./public`

- [ ] Uploader le fichier `./index-online.rb` et le renommer `index.rb` (s’assurer qu’il soit exécutable)

- [ ] Uploader le fichier `./.htaccess` (en le réglant pour qu’il accepte de laisser passer mon IP)

- [ ] Lancer le fichier [premiers tests online](/Users/philippeperret/Sites/AlwaysData/Icare_2020/_dev_/__DEPLOIEMENT__/premiers_tests_online.rb).

- [ ]  Corriger les éventuelles erreurs et relancer le script jusqu’à ce que tout passe.

- [ ] RETIRER LA MISE EN CHANTIER DU SITE

- [ ] Se balader un peu partout pour voir si tout se passe bien. Corriger les éventuels problèmes.

- [ ] Se balader en mode téléphone (avec l’iPhone et en simulation sur Safari) et corriger les éventuels problèmes.

- [ ] Annoncer le nouveau site :

  ~~~
  Bonjour à tous,

  J’ai l’immense plaisir de vous annoncer l’installation du tout nouveau site de l’atelier Icare.

  Vous pourrez le trouver à l’adresse habituelle [http://www.atelier-icare.net](http://www.atelier-icare.net).

  En espérant que vous vous y fassiez rapidement, je vous souhaite à toutes et tous une excellente rentrée.

  Bien à vous,

  Phil
  ~~~



- [ ] Sur [AlwaysData](https://admin.alwaysdata.com/), détruire les autres DB (laisser juste `icare_db`)



[fichier de récupération des données DB]: /Users/philippeperret/Sites/AlwaysData/Icare_2020/_dev_/__DEPLOIEMENT__/recuperation_donnees_DB.rb

[dossier des bonnes données DB]: /Users/philippeperret/Sites/AlwaysData/xbackups/Goods_for_2020
