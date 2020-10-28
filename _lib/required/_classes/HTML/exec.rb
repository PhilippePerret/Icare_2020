# encoding: UTF-8
class HTML
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
  def proceed_exec
    begin
      run_ticket if param(:tik)
      self.exec
    rescue IdentificationRequiredError => e
      # L'user doit être identifié pour atteindre la page voulue.
      # On le renvoie à l'identification et on met dans 'back_to'
      # la route qu'il voulait atteindre
      session['back_to'] = route.to_s if session['back_to'].nil?
      erreur(e.message)
      Route.redirect_to('user/login')
    rescue PrivilegesLevelError
      # L'user est identifié mais il n'a pas un niveau de privilèges
      # suffisant pour voir la page demandée. On le renvoie vers une
      # page sans issue
      Route.redirect_to('errors/acces_interdit')
    end

  end #/proceed_exec

  def run_ticket
    require_module('ticket')
    Ticket.run(param(:tik).to_i, param(:tckauth))
  end #/ run_ticket

end
