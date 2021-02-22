# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la class Concours::CFile qui permet de marquer que
  le fichier est conforme et avertir l'auteur.
=end
class Concours
class CFile
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# Méthode pour indiquer que le fichier a été contrôlé et qu'il est valide,
# conforme au règlement.
#   - met le 2e bit des specs à 1
#   - envoie un message de confirmation à l'auteur
def confirme_validite
  concurrent.set_spec(1,1)
  require_module('mail')
  mail_path = File.join(XMODULES_FOLDER, 'mails','phase1','inform_fichier_conforme.erb')
  MailSender.send(to:concurrent.mail, from:CONCOURS_MAIL, file:mail_path, bind:self)
  message("Le projet “#{synopsis.titre}” (#{name}) a bien été marqué conforme.<br/>#{concurrent.pseudo}, son auteur#{concurrent.fem(:e)}, a été informé#{concurrent.fem(:e)}.")
end #/ confirme_validite

end #/Concours::CFile
end #/Concours
