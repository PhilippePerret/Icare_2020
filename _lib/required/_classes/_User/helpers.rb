# encoding: UTF-8
=begin
  Module User pour les helpers methods
=end
class User
  # Retourne le visage de l'utilisateur, en fonction du fait que c'est
  # un homme ou une femme
  def visage
    @face ||= (femme? ? '👩‍🎓' : '👨‍🎓').freeze
  end #/ face
end #/User
