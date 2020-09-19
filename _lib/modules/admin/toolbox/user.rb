# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extention User quand l'administrateur est connecté
=end
class User
class << self

  # Méthode appelée quand je veux visiter le site comme un icarien
  # choisi dans la liste des icariens.
  # Note : pour éviter les intrusions, je suis prévenu en cas d'appel de
  # cette méthode
  def visit_as(uid)
    prenom = user.pseudo
    phil.send_mail(subject:"Connexion “Visite comme…”", message:"<p>Phil,</p><p>Je t'informe qu'une visite “comme…” vient d'être activée.</p><p>Si ça n'est pas toi, il faut faire quelque chose.</p>")
    login_user(uid)
    message("#{prenom}, tu peux maintenant visiter le site comme #{user.pseudo}.")
  end #/ visit_as

end # /<< self
end #/User
