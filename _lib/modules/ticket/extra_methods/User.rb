# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la class User pour les tickets
=end
class User
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
# Méthode appelée pour ne plus recevoir les activités de l'atelier
# Appelée depuis un ticket dans le mail des informations sur l'activité
def nomore_news
  set_option(4,9)
  message("OK, #{pseudo}, vous ne recevrez plus les mails d'activité de l'atelier Icare.")
end #/ nomore_news
end #/User
