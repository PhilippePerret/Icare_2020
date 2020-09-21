# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module operation administrateur permettant d'ajouter une actualité
=end
class Admin::Operation
  def add_actualite
    self.admin_required
    Actualite.add(type:medium_value, user_id:owner.id, message:long_value)
    Ajax << {message: "Actualité “#{long_value}” de type #{medium_value} ajoutée pour #{owner.pseudo}."}
  end #/ add_actualite
end #/Admin::Operation
