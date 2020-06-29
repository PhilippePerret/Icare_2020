# encoding: UTF-8
=begin
  Cette page présente le synopsis des choses à faire pour ouvrir le nouvel
  atelier Icare.
=end

# [1] RÉCUPÉRER TOUTES LES DONNÉES DU SITE DISTANT
# Mettre chaque table dans un fichier séparé, portant le nom de la table,
# dans le dossier ~/Sites/AlwaysData/xbackups/Icare_pre2020/
# Note : ça se fait depuis mon compte AlwaysData avec phpMyAdmin.

# [2] CRÉER LA BASE DE DONNÉES `icare` DISTANTE
# Sur AlwaysData, à partir de mon compte (obligé)

# BONNES DONNÉES ABSOLUES POUR LES MODULES (ÉTAPES, MODULES, TRAVAUX-TYPES)
# Pour ça, il suffit de lancer le script
# - Récupérer les absetapes sur le site et en faire une table current_absetapes
#   sur icare en local. Note : ces données se trouvent déjà dans Icare_pre2020/absetapes.sql
#   établi à l'étape [1].
# - Lancer le script ./_dev_/scripts/new_site/update_etapes_modules.rb pour
#   mettre les données les plus à jour dans icare.absetapes
# - Exporter les absetapes dans un fichier 'absetapes.sql'
#   $> mysqldump -u root icare absetapes > absetapes.sql

# Note : on doit maintenant passer en revue toutes les tables pour qu'elles
# soient conforme.

# USERS
# TODO

# ACTUALITÉS
# TODO

# WATCHERS COURANTS
# TODO

# Ici, la nouvelle base de données doit être prête.

# UPLOADER LE DOSSIER ./_lib
# UPLOADER LE DOSSIER ./public

# BLOQUER LE SITE EN DIRIGEANT VERS LA PAGE EN TRAVAUX
# TODO (je peux simplement télécharger un .htaccess vers index.html)

# À partir d'ici le site est bloqué et inactif

# UPLOADER LE DOSSIER ./css
# UPLOADER LE DOSSIER ./js
# UPLOADER LE DOSSIER ./img (mais en gardant l'autre car des images sont utiles ailleurs)


# FAIRE QUELQUES TESTS
# TODO

# PAGE DES ICARIENS
# Voir si la liste des anciens icariens présente bien la liste des modules suivis.

# DÉBLOQUER LA PAGE DE TRAVAUX
# TODO

# ANNONCER LA RÉ-OUVERTURE DU SITE
# TODO Faire un message de ré-ouverture et l'envoyer à tous les icariens

# LANCER LE TRACEUR POUR SURVEILLER LES OPÉRATIONS
# TODO
