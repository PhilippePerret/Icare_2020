# encoding: UTF-8
=begin
  Extension de la class User pour l'inscription
=end
require 'fileutils'

class User
  # = main =
  #
  # Méthode de validation de l'inscription à l'atelier
  def valide_inscription
    require_module('icmodules')
    # Création d'un icmodule pour l'icarien
    log("Création de l'icmodule d'après le module #{param(:module_id).to_i}.")
    icmodule = IcModule.create_new_for(user: self, absmodule_id:param(:module_id).to_i)
    # Modification des informations de l'user (validé)
    set_option(16, 4) # 4 = inactif
  end #/ valide_inscription

  # Quand tout s'est bien passé
  def onSuccess
    # On peut détruire le dossier de candidature si tout est OK
    messsage "Tout s'est bien passé on peut détruire le dossier de candidature"
    FileUtils.rm_rf(signup_folder)

  end #/ onSuccess

end #/User
