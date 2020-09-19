# Ouverture du nouveau site Icare 2020

## À faire AVANT l'ouverture

### Modifications à faire dans la base de données

* Dans les témoignages, il y a une erreur : 'désormais partie d\'une vraie communauté : <a href=\"./icariens\">les Icariens</a>'. Il faut remplacer l'href par 'overview/icariens'

### Avant de faire l'annonce, détruire les users suivant :

* Naja (chrystèle) + paiement

---------------------------------------------------------------------

## À faire POUR l'ouverture (le déploiement)

* Récupérer toutes les données DB en lançant le script de déploiement
* Mettre le site hors service (pour tout le monde sauf moi)
* Détruire tout ce qui appartenait à l'ancien site (peut-être tout, pour être plus sûr, sauf le fichier HTML d'information de mise en chantier)
* Uploader tous les fichiers
* Utiliser le script [\_dev\_/destroy_user_in_DB_online](/Users/philippeperret/Sites/AlwaysData/Icare_2020/_dev_/destroy_user_in_DB_online.rb) pour détruire Naja (Chystèle).
* Checks à faire
  - [ ] Lancer le PageChecker en online
  - [ ] Vérifier la justesse des actualités sur la home page


---------------------------------------------------------------------

## À faire APRÈS l'ouverture

### Actualiser les gems

En SSH, jouer `bundle install` pour installer tous les gems.

### Modifications diverses

* Changer la date de prochain paiement de Charlotte

### Envoi d'un mail d'annonce

~~~html
<p>Bonjour #{user},</p>
<p>Je suis heureux et fier de vous annoncer la mise en place du nouveau site de l'atelier icare, que vous pouvez découvrir à l'adresse habituelle : https://www.atelier-icare.net.</p>
<p>Vous devriez vous familiariser rapidement à cette nouvelle version qui, au niveau de l'ergonomie, ne s'éloigne pas trop de l'ancienne version.</p>
<p>Merci de noter les points suivants :</p>
<ul>
  <li>après <a href="https://www.atelier-icare.net/user/login">vous être connecté#{fem(:e)}</a>, vous devriez <a href="https://www.atelier-icare.net/bureau/preferences">rejoindre vos préférences</a> afin de les régler car certains nouveaux paramètres sont à prendre en compte (notamment de le partage de votre historique de travail).</li>
</ul>
<p>Il est fort possible que des problèmes techniques surviennent dans les jours qui viennent, on ne peut jamais penser à tout. N'hésitez jamais à nous les remonter, afin que nous puissions les corriger. Merci d'avance de votre compréhension et de votre patience.</p>
<p>Bien à vous,</p>
~~~


### Tâches à faire ensuite

- [ ] Sur [AlwaysData](https://admin.alwaysdata.com/), détruire les autres DB (laisser juste `icare_db`)
