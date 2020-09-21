# encoding: UTF-8
# frozen_string_literal: true
ERRORS.merge!({
  id_owner_required: "Il faut fournir l’identifiant du propriétaire pour confirmation !",
  id_owner_doesnt_match: "L'identifiant ne correspond pas (%s / %i)"
})
class Admin::Operation
  def marquer_detruit
    self.admin_required
    raise_if_short_value_empty
    raise_if_ids_dont_match
    # *** On peut procéder à l'opération ***
    opts = owner.options
    opts[3]   = '1'
    opts[16]  = '5'
    db_compose_update('users', owner.id, {options: opts})
    Ajax << {message: "#{owner.pseudo} a été marqué détruit#{owner.fem(:e)}."}
  rescue Exception => e
    Ajax << {error: e.message + " --- short_value: #{short_value.inspect}"}
    log(e)
  end #/ marquer_detruit


private

  def raise_if_short_value_empty
    raise ERRORS[:id_owner_required] if short_value.nil_if_empty.nil?
  end #/ raise_if_short_value_empty

  def raise_if_ids_dont_match
    raise (ERRORS[:id_owner_doesnt_match] % [short_value, owner.id]) if short_value.to_i != owner.id
  end #/ raise_if_ids_dont_match

end #/Admin::Operation
