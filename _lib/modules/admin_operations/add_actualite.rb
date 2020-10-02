# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module operation administrateur permettant d'ajouter une actualité
=end
class Admin::Operation
def add_actualite
  self.admin_required
  data_actu = {type:select_value, user_id:(owner||phil).id, message:long_value}
  if short_value # une date différente de maintenant
    j, m, a = short_value.split(/[\/ ]/)
    a ||= Time.now.year
    data_actu.merge!(date: Time.new(a.to_i, m.to_i, j.to_i))
  else
    data_actu.merge!(date: Time.now)
  end
  Actualite.add(data_actu)
  Ajax << {message: "Actualité “#{data_actu[:message]}” de type #{data_actu[:type]} ajoutée pour #{(owner||phil).pseudo}."}
end #/ add_actualite
end #/Admin::Operation
