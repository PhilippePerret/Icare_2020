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


class IcEtape

  # Procéder au changement d'échéance
  def modify_echeance
    old_eche = Time.at(data[:expected_end])
    new_eche = Form.date_field_value('echeance')
    now_eche = Time.now
    # Pour vérification
    old_jour = Time.new(old_eche.year, old_eche.month, old_eche.day)
    new_jour = Time.new(new_eche.year, new_eche.month, new_eche.day)
    # On vérifie que la valeur soit bonne
    old_jour != new_jour  || raise(ERRORS[:same_echeance])
    new_eche > now_eche   || raise(ERRORS[:bad_echeance])
    # On peut sauver la nouvelle échéance (en indiquand le nombre de jours
    # restants)
    save(expected_end: new_eche.to_i)
    message(MESSAGES[:echeance_changed] % formate_date(new_eche, duree:true))
  rescue Exception => e
    erreur e.message
    log(e)
  end #/ modify_echeance

end #/IcEtape < ContainerClass
