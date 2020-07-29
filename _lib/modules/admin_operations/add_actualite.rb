# encoding: UTF-8
=begin
  Module operation administrateur permettant d'ajouter une actualité
=end
class Admin::Operation
  def add_actualite
    Ajax << {message: "J'ai ajouté une actualité “#{long_value}” pour #{owner.pseudo}"}
  end #/ add_actualite
end #/Admin::Operation
