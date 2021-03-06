# encoding: UTF-8
# frozen_string_literal: true
=begin
  Cette section affiche les fiches de lecture du concurrent et lui permet
  de les télécharger, pendant x années (5 ans).

  Cette partie peut être aussi bien consultée par un administrateur (qui veut
  voir les fiches d'un concurrent) par un membre d'un jury que par un concurrent
  Seul quelqu'un qui n'a aucun rapport avec le concours ne peut pas visiter
  cette partie.

  Les données :cid (concurrent_id) et :an (année) permettent de déterminer
  la fiche de lecture à voir.

=end
class HTML
  def titre
    "#{bouton_retour_espace_perso}#{Emoji.get('objets/porte-document').page_title + SPACE}Vos fiches de lecture"
  end

  # Code à exécuter avant la construction de la page
  def exec
    require_xmodule('synopsis')
    try_to_reconnect_visitor(required = true)
  end

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

  # Retourne un lien vers la fiche de lecture du concours de données +dconcours+
  # +dconcours+ {Hash} Données du concours (et notamment :annee)
  def link_to_fiche_lecture_concours(dconcours)
    @template_link ||= Tag.link(
      route:"concours/fiches_lecture?op=download&cid=#{concurrent.id}&an=%{annee}",
      text: UI_TEXTS[:concours][:fiches_lecture][:download_btn_name_template]
    )
    annee = dconcours[:annee].to_i
    if annee == Concours.current.annee && Concours.current.phase < 5
      MESSAGES[:concours][:fiches_lecture][:too_soon]
    else
      @template_link % {annee: annee}
    end
  end

  def designation_visiteur_courant
    if user.admin?
      "administrateur (#{user.pseudo})"
    elsif user.evaluator?
      "membre du jury (#{evaluator.pseudo} ##{evaluator.id})"
    elsif user.concurrent?
      "concurrent (#{concurrent.pseudo} ##{concurrent.id})"
    else
      raise "Un anonyme ne peut pas passer par cette section."
    end
  end #/ designation_visiteur_courant

  def code_css_fiche_lecture
    <<-STYLESHEET
<style media="screen" type="text/css">
* {color:black!important}
section#header,section#footer,h2.page-title,.noprint{display:none}
.header.hidden,.detail.hidden{display:block!important}
div#lien_revenir{display:normal}
</style>
<style media="print" type="text/css">
section#header {display:none;}
</style>
    STYLESHEET
  end

end #/HTML
