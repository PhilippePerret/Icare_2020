# encoding: UTF-8

class HTML
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
  def proceed_exec
    begin
      self.exec
    rescue IdentificationRequiredError
      # L'user doit être identifié pour atteindre la page voulue.
      # On le renvoie à l'identification et on met dans 'back_to'
      # la route qu'il voulait atteindre
      session['back_to'] = route.to_s
      erreur('Pour atteindre cette page, merci de vous identifier.'.freeze)
      Route.redirect_to('user/login')
    rescue PrivilegesLevelError
      # L'user est identifié mais il n'a pas un niveau de privilèges
      # suffisant pour voir la page demandée. On le renvoie vers une
      # page sans issue
      Route.redirect_to('errors/acces_interdit')
    end

  end #/proceed_exec

end
