# encoding: UTF-8
=begin
  Module chargé quand on est à l'accueil du site, pour avoir une
  page tout à fait différente.
=end
require_module('citation')
class HTML
  def build_body
    @body = <<-HTML
<div id="main-cadre">
  <img src="img/papillon-logo.png" id="papillon">
  <div id="titre"><a href="plan">Atelier Icare</a></div>
  <div id="sous-titre">L’écriture dans tous ses états (*) </div>
</div>
#{Citation.rand.out}
<div id="legende">
  (*) aussi bien dans la forme (roman, scénario, BD, etc.) que dans le fond (pitch, résumé, synopsis, scénario, etc.).
</div>
    HTML
  end

  def build_header
    @header = []
    @header << MAIN_LINKS[:overview]
    if user.guest?
      @header << MAIN_LINKS[:signup]
    end
    @header << MAIN_LINKS[user.icarien? ? :logout : :login]
    @header = @header.join(' ')
  end
end
