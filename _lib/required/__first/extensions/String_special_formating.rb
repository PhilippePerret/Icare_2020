# encoding: UTF-8
=begin
  Extension de la class String qui traite les formatages propres à
  l'atelier Icare.

  Tous les textes qui font appel à `deserb`, `kramdown` (pour les fichiers)
  ou `deserb_or_kramdown` (pour les textes) passent à la fin par cette
  méthode
=end
class String
  def special_formating
    self
      .gsub(/&lt;\!div.document&gt;/,'<div class="document">')
      .gsub(/&lt;\!\/div.document&gt;/,'</div><!-- /div.document -->')
  end #/ special_formating

  # Méthode in-place
  def special_formating!
    replace(special_formating)
  end #/ special_formating!

end #/String
