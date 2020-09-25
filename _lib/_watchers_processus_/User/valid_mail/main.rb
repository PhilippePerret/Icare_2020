# encoding: UTF-8
# frozen_string_literal: true
class Watcher < ContainerClass
  def valid_mail
    icarien_required
    user.valide_mail
  end # / valid_mail

  # Méthode appelée pour envoyer à nouveau le message de demande de
  # confirmation de l'adresse mail.
  def resend_valid_mail
    icarien_required
    # On cherche le ticket jouant ce watcher (run_watcher(xxx)). S'il n'existe
    # pas, c'est que la procédure n'existe plus.
    dticket = db_exec("SELECT id FROM tickets WHERE code = 'run_watcher(#{id})'").first
    dticket || raise("Aucun ticket ne permet de jouer ce watcher…")
    # On détruit ce ticket car un nouveau va être créé
    db_exec("DELETE FROM tickets WHERE id = #{dticket[:id]}")
    # Renvoyer le mail de confirmation du mail
    require './_lib/modules/user/create/user_send_mails.rb'
    user.send_mail_validation_mail(watcher_id: id)
    message(MESSAGES[:mail_confirmation_mail_resent] % user.pseudo)
    # On doit empêcher le message d'alerte de la confirmation du mail
    session['no_alerte_confirmation_mail'] = 'true'
  end #/ resend_valid_mail
end #/Watcher < ContainerClass

class User
  def valide_mail
    set_option(2,1,{save:true})
    message("Votre mail a été confirmé, merci à vous.")
  end #/ valide_mail
end #/User
