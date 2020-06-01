# encoding: UTF-8
=begin
  Extension de la classe AbsModule pour l'affichage des modules
=end
class AbsModule < ContainerClass
  def out
    <<-HTML
<div class="absmodule mt1" id="absmodule-#{id}">
  <div class="titre">
    #{formated_name}
  </div>
  <div class="description mg2 small">
    #{short_description}
  </div>
</div>
    HTML
  end #/ out

  # Pour l'insertion dans la table des matières
  def as_data_tdm
    {route: "#{route.to_s}#absmodule-#{id}", titre: formated_name}
  end #/ as_tdm

  def formated_name
    @formated_name ||= "#{"#{id} " if user.admin?}#{name}"
  end #/ formated_name

end #/AbsModule
