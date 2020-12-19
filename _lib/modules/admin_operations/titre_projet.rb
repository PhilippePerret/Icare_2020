# encoding: UTF-8
# frozen_string_literal: true
class Admin::Operation
  # Procédure permettant de définir le titre d'un projet d'un Icarien
  #
  # Si la short_value est définie, c'est l'ID de l'IcModule (car l'icarien
  # peut en avoir fait plusieurs et on peut définir ce titre plus tard)
  # Donc short_value contient l'ID du projet et medium_value contient
  # le titre du projet.
  def titre_projet
    require_module('user/modules')
    msg = []

    imodule = owner.icmodule || IcModule.get(short_value)
    imodule || raise('L’icarien ne possède pas de module courant, et aucun module n’est spécifié… Donnez l’ID dans le champ court.')
    imodule.exists? || raise("Impossible d'obtenir le module à titrer…")

    # Le titre du projet (noter qu'il peut être nil)
    titre_projet = medium_value.nil_if_empty

    if titre_projet.nil?
      if noop?
        msg << "Le titre du projet du module #{imodule.ref} de #{owner.ref} sera supprimé."
      else
        msg << "Le titre du projet du module #{imodule.ref} de #{owner.ref} a été supprimé."
      end
    else
      if noop?
        msg << "Le titre du module #{imodule.ref} de #{owner.ref} sera mis à “#{titre_projet}”."
      else
        # On peut donner le titre du projet
        msg << "Le titre du module #{imodule.ref} de #{owner.ref} a été mis à “#{titre_projet}”."
      end
    end

    noop? || imodule.set(project_name: titre_projet)

    msg = msg.join("<br/>")
    Ajax << {message: msg}

  rescue Exception => e
    log(e)
    Ajax << {error: e.message}
  end
end #/class
