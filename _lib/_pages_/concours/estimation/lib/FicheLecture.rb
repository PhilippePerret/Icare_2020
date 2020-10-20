# encoding: UTF-8
# frozen_string_literal: true
=begin
  Classe FicheLecture
  -------------------
  Pour la gestion de la fiche de lecture qui sera produite

  C'est cette fiche de lecture qui:
    - calcule les notes finales
    - calcule LA note générale du synopsis
    - produit la note en langage humain d'après les résultats
=end
class FicheLecture
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :synopsis
def initialize(synopsis)
  @synopsis
end #/ initialize
end #/FicheLecture
