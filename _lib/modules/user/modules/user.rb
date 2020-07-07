# encoding: UTF-8
require_module('icmodules')
class User

  # Retourne true si l'icare a un module en cours
  def has_module?
    !data[:icmodule_id].nil?
  end #/ has_module?

  # Retourne tous les modules suivis par l'icarien
  def modules
    @modules ||= IcModule.get_instances({user_id: id})
  end #/ modules

  def icmodule
    @icmodule ||= data[:icmodule_id] && IcModule.get(data[:icmodule_id])
  end #/ icmodule

  def absmodule
    @absmodule ||= icmodule && icmodule.absmodule
  end #/ absmodule

  def icetape
    @icetape ||= icmodule && IcEtape.get(icmodule.data[:icetape_id])
  end #/ icetape

  def absetape
    @absetape ||= icmodule && icetape.absetape
  end #/ absetape

  # Retourne le titre du projet s'il est défini
  def project_name
    @project_name ||= icmodule&.project_name
  end #/ project_name

end #/User
