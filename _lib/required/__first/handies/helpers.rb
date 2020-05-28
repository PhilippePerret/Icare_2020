# encoding: UTF-8
=begin
  Ce module contient des méthodes pratiques pour les codes helpers récurrents.
=end

# Pour construire un div "goto", comme on en trouve à l'accueil des sections
# en général, avec des blocs cliquables.
def divGoto(inner)
  <<-HTML
<div class="goto">
  #{inner}
</div>
  HTML
end #/ divGoto
