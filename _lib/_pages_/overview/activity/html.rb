# encoding: UTF-8
# frozen_string_literal: true

class HTML
  def titre
    "#{retour_base}#{Emoji.get('objets/sablier-coule').page_title+ISPACE}Activité de l'atelier Icare".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    add_css("#{FOLD_REL_PAGES}/home/actualites.css")
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end

  # = main =
  # Méthode appelée par body.erb pour construire la liste des activités
  # du site.
  # L'URL contient les paramètres `pp` et `pg` qui définissent respectivement
  # le nombre d'activités à afficher en même temps (pp, per_page) et la page à
  # afficher (pg, from_page)
  def activites_from_for()
    Activity.get_formated_from_for(from_page, per_page)
  end #/ activites_from_for

  def per_page
    @per_page ||= (param(:pp) || 40).to_i
  end #/ per_page

  def from_page
    @from_page ||= param(:pg).to_i
  end #/ from_page

  def last_page
    @last_page ||= begin
      (param(:lp) || db_count('actualites') / per_page).to_i
    end
  end #/ last_page

  TAG_OTHER_PAGE = '<a href="overview/activity?lp='+html.last_page.to_s+'&pg=%{fpage}&pp=%{ppage}" class="%{visu}">%{titre}</a>'.freeze
  def boutons_navigation
    div = []
    div << TAG_OTHER_PAGE % {titre:'Dernières', fpage:0, ppage:per_page, visu: from_page > 0 ? '' : 'invisible'}
    div << TAG_OTHER_PAGE % {titre:'Précédentes', fpage:from_page + 1, ppage:per_page, visu:from_page < last_page ? '' : 'invisible'}
    div << TAG_OTHER_PAGE % {titre:'Suivantes', fpage:from_page - 1, ppage:per_page, visu:from_page > 0 ? '' : 'invisible'}
    div << TAG_OTHER_PAGE % {titre:'Premières', fpage:last_page, ppage:per_page, visu:from_page != last_page ? '' : 'invisible'}
    Tag.div(text:div.join, class:'horizontal_links right small')
  end #/ boutons_navigation
end #/HTML

class Activity < ContainerClass # attention, ce n'est pas Actualite
class << self
  def get_formated_from_for(from_page, per_page)
    from_page ||= 0
    from_page = 0   if from_page < 0
    per_page  = 40  if not per_page > 0
    request = "SELECT message, created_at FROM #{table} ORDER BY created_at DESC LIMIT #{per_page} OFFSET #{from_page * per_page}"
    db_exec(request).collect do |dactu|
      Actualite.instantiate(dactu).out
    end.join
  end #/ get_from_for
  def table
    @table ||= 'actualites'
  end #/ table
end # /<< self
end #/Activity
