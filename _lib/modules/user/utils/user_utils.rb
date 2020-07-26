# encoding: UTF-8
=begin
  Méthodes utilitaires pour un icarien
=end
class User

  # Attribut un nouveau mot de passe à l'user
  def password=(new_password)
    cpass = Digest::MD5.hexdigest("#{new_password}#{mail}#{salt}")
    set(cpassword: cpass)
    message(MESSAGES[:new_password_saved])
  end #/ password= new_password

end #/User
