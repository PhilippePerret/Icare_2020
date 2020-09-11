# encoding: UTF-8
=begin
  Module contenant les opérations à exécuter
=end
class HTML
  def exec_operation
    case param(:ope)
    when 'restart_module'
      raise "La procédure de redémarrage de module doit être implémentée."
    when 'echeance'
      user.icetape.modify_echeance
    when 'minifaq-add-question'
      MiniFaq.add_question
    end
  end #/ exec_operation

end #/HTML


class IcEtape < ContainerClass

  # Procéder au changement d'échéance
  def modify_echeance
    old_eche = Time.at(data[:expected_end])
    new_eche = Form.date_field_value('echeance')
    now_eche = Time.now
    # On vérifie que la valeur soit bonne
    old_eche != new_eche  || raise("Il faut choisir une autre date !")
    new_eche > now_eche   || raise("Il faut choisir une échéance dans le futur, voyons…")
    # On peut sauver la nouvelle échéance (en indiquand le nombre de jours
    # restants)
    save(expected_end: new_eche.to_i)
    message("L’échéance a été mise au #{formate_date(new_eche, duree:true)}.")
  rescue Exception => e
    erreur e.message
    log(e)
  end #/ modify_echeance

end #/IcEtape < ContainerClass
