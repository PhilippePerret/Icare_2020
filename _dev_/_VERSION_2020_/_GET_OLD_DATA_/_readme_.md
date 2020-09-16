# Récupération des données

Ce dossier contient tous les scripts permettant de récupérer les données de l'ancien site pour les transformer dans la base `icare_db` pour la version 2020 de l'atelier (version "COVID").

## Synopsis général

* On prend les données dans les différentes bases distantes (il y en a plusieur)
* on les met toutes dans la database unique `icare` local,
* on les transforme,
* on les réinjecte dans la database `icare_db` distante.
