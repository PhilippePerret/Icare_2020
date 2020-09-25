# encoding: UTF-8
class User

  # ---------------------------------------------------------------------
  #
  #   Méthodes d'affectation
  #
  # ---------------------------------------------------------------------

  def statut=(val)
    set_option(16, DATA_STATUT[val][:value])
    @statut = val
  end #/ statut=

  # ---------------------------------------------------------------------
  #
  #   Méthodes de récupération des données
  #
  # ---------------------------------------------------------------------

  def icetape_id
    icmodule.icetape_id
  end #/ icetape_id

  def project_name
    @projet_name ||= icmodule.project_name
  end
  def project_name=(new_titre)
    icmodule.set(project_name: new_titre)
    @projet_name = new_titre
  end #/ project_name=

end #/User
