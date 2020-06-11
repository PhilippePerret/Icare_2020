# encoding: UTF-8
=begin
  Module chargé quand on est à l'accueil du site, pour avoir une
  page tout à fait différente.
=end
require_module('citation')
class HTML
  def build_body
    @body = <<-HTML
<div id="bandeau" class="nolimit">
  <div id="main-cadre">
    <div id="titre"><a href="plan">Atelier Icare</a></div>
    <div id="sous-titre"><span class="nowrap">L’écriture dans</span> <span class="nowrap">tous ses états (*)</span></div>
  </div>
</div>
<div id="legende" class="nolimit">
  (*) aussi bien dans la forme (roman, scénario, BD, etc.) que dans le fond (pitch, résumé, synopsis, scénario, etc.).
</div>
<div id="air-sous-bandeau">&nbsp;</div>
#{Citation.rand.out}
<div id="actualites">
  #{Actualite.out}
</div>
    HTML
  end

  def build_header
    @header = []
    @header << MAIN_LINKS[:overview_s]
    if user.guest?
      @header << MAIN_LINKS[:login_s]
      @header << MAIN_LINKS[:signup_s]
    else
      @header << MAIN_LINKS[:logout_s]
      @header << MAIN_LINKS[:bureau_s]
    end
    @header = @header.join(' ')
  end
end
