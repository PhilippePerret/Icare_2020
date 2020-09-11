# Filtrage des documents

Pour la procédure de filtrage, en fonction des critères, utiliser la façon dynamique de créer des procédures avec '>>' (ou '<<')

~~~ruby
a = proc { |x| x + x }
if ajouter_multiplication
  a = a >> proc { |y| y * y }
  # C'est-à-dire que le résultat de a est envoyé comme y dans cette
  # Procédure
end
if ajouter_division
  a = a >> proc { |z| z.to_f / 3 }
  # C'est-à-dire que le résultat du nouveau a est envoyé comme z
  # dans cette procédure
end
~~~

Note : bien noter que c'est le *résultat* qui est envoyé à la procédure suivante.
