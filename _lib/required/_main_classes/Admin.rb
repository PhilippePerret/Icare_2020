# encoding: UTF-8
=begin
  Module pour l'administration générale
=end
class Admin
class << self

  # Mettre ici tous les boutons utiles pour le développement
  def section_essais
    <<-HTML
<section id="developpement-tools" class="mt2">
  <a href="bureau/home" class='btn'>Rejoindre bureau</a>
</section>
    HTML
  end
end #/<< self
end #/Admin
