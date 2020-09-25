# encoding: UTF-8
# frozen_string_literal: true
=begin

  Ce module est appelé lorsque le mail n'est pas encore validé et qu'on
  veut voir si l'user n'est pas en train de jouer son ticket de validation.
  Si c'est le cas, il ne faut pas afficher le message d'erreur.

=end
class User

  # Return TRUE si l'user reconnecté veut jouer son ticket de validation
  # du mail. Return NIL otherwise.
  def want_to_run_ticket_validation_mail?
    if session['no_alerte_confirmation_mail'] == 'true'
      session.delete('no_alerte_confirmation_mail')
      return true
    end
    param(:tik) || return
    dticket = db_exec("SELECT code FROM tickets WHERE id = #{param(:tik)}").first
    dticket || return
    code = dticket[:code]
    reg = /run_watcher\(([0-9]+)\)/
    code.match?(reg) || return
    watcher_id = code.match(reg).to_a[1].to_i
    dwatcher = db_exec("SELECT wtype FROM watchers WHERE id = #{watcher_id}").first
    dwatcher || return

    return dwatcher[:wtype] == 'validation_adresse_mail'
  end #/ want_to_run_ticket_validation_mail?
end #/User
