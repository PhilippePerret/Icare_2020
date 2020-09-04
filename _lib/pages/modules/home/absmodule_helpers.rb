# encoding: UTF-8
=begin
  Extension de la classe AbsModule pour l'affichage des modules
=end
class AbsModule < ContainerClass
  attr_reader :options
  def out(options = {})
    @options = options
    <<-HTML
<div class="absmodule" id="absmodule-#{id}">
  <H3 class="titre">#{formated_name(options)}</H3>
  <div class="description mg2 small">
    <div class="titre">Description courte</div>
    <div>#{short_description}</div>
    #{ligne_infos}
    #{ligne_boutons}
    <div class="titre">Description détaillée</div>
    <div>#{long_description}</div>
    #{ancre_next_module}
    #{ligne_boutons}
  </div>
  <div class="minifaq">
    #{MiniFaq.full_block(:absmodule, id)}
  </div>
</div>
    HTML
  end #/ out

  def ligne_infos
    @ligne_infos ||= begin
      <<-HTML
<div class="ligne-infos">
  <span class="libelle">Tarif</span>
  <span class="value">#{formated_tarif}</span>
  <span class="libelle">• Durée approximative</span>
  <span>#{hduree ? hduree : 'indéfinie'}</span>
</div>
      HTML
    end
  end #/ ligne_infos
  # Retourne la ligne pour les boutons (revenir en haut et commande)
  def ligne_boutons
    @ligne_boutons ||= begin
      <<-HTML
<div class="btn-command-module mt1 mb1">
  <a href="modules/commande?mid=#{id}" class="btn main">#{UI_TEXTS[:btn_commander_module]}</a>
</div>
      HTML
    end
  end #/ ligne_boutons

  # Pour l'insertion dans la table des matières
  def as_data_tdm
    {route: "#{route.to_s}#absmodule-#{id}", titre: formated_name}
  end #/ as_tdm

  def formated_name(options = {})
    "#{"<span class='vmiddle'>#{options[:picto]}</span> " if options.key?(:picto)}#{"#{id} " if user.admin?}#{name}"
  end #/ formated_name

  def formated_tarif
    @formated_tarif ||= begin
      "<span class='bold red'>#{tarif} €#{' / mois' unless hduree}</span>"
    end
  end #/ formated_tarif

  # Pour que le module se place bien dans la page quand on clique dans
  # la table des matières, il faut que son ancre soit placée dans le code
  # du module précédent. C'est options[:next] qui contient l'id du module
  # suivant et qui permet de placer cette ancre.
  def ancre_next_module
    @ancre_next_module ||= begin
      if options[:next]
        Tag.aname("absmodule-#{options[:next]}")
      else '' end
    end
  end #/ ancre_next_module
end #/AbsModule
