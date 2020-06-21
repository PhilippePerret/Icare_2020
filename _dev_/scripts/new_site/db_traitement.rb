# encoding: UTF-8
=begin
  Script de récupération des données
=end

=begin
Il faut donc récupérer les informations des colonnes `cote_original`, `cotes_original`, `cote_comments`, `cotes_comments`, `readers_original` et `readers_comments` pour alimenter cette nouvelle table (en sachant qu'on sera obligé, ici, d'attribuer une note moyenne pour chaque lecture — ou plus exactement une note dont le total devra être cohérent — peut-être, pour simplifier, prendra-t-on une fois la valeur arrondie au-dessus et une fois en dessous).
=end

request = <<-SQL
SELECT id, cote_original, cotes_original, cote_comments, cotes_comments, readers_original, readers_comments FROM icdocuments
SQL
data_lectures = db_exec(request)

# On ajoute ces documents à la table `lectures_qdd`
# TODO

# On détruit ces données dans la table
requests = [

]
