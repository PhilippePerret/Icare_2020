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
    save(:options)
  end #/ statut=

  # ---------------------------------------------------------------------
  #
  #   Méthodes de récupération des données
  #
  # ---------------------------------------------------------------------

  def icetape_id
    icmodule.icetape_id
  end #/ icetape_id

end #/User
