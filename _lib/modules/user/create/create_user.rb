# encoding: UTF-8
=begin
  Extension de User pour la création d'un nouvel icarien
=end
require 'digest/md5'

class User
class << self

  # = main =
  # Pour créer l'user
  #
  # +chuser+ est un CheckedUser qui a été vérifié
  def create_new(chuser)
    now  = Time.now.to_i
    salt = now.to_s
    newdata = {
      pseudo:       chuser.pseudo,
      patronyme:    chuser.patronyme,
      naissance:    chuser.naissance,
      sexe:         chuser.sexe,
      mail:         chuser.mail,
      salt:         salt,
      cpassword:    Digest::MD5.hexdigest("#{chuser.password}#{chuser.mail}#{salt}"),
      options:      options_new_icarien,
      session_id:   session.id,
      created_at:   now,
      updated_at:   now
    }
    db_compose_insert('users', newdata)
    if MyDB.error
      log("MyDB.error: #{MyDB.error.inspect}")
      raise "Une erreur SQL est malheureusement survenue…"
    end
    newid = db_last_id
    newu = User.get(newid)

    # === WATCHERS ===
    require_module('watchers')
    # Le watcher qui permettra à l'administrateur de valider l'inscription
    newu.watchers.add(:validation_inscription, {params: {folder:session.id, modules:chuser.modules_ids}})
    # Le watcher qui rappellera au candidat qu'il doit valider son mail
    id_watcher_mail = newu.watchers.add(:validation_adresse_mail, {vu_admin:true, vu_user:false})

    # === MAILS ===
    require_module('mail')
    # Envoi d'un message pour valider l'adresse mail
    newu.send_mail_validation_mail(watcher_id:id_watcher_mail)

    # Envoi d'un message pour confirmer l'inscription
    newu.send_mail_confirmation_inscription


    # Une actualité pour mentionner l'inscription
    Actualite.add('SIGNUP', newu, "Candidature posée par <strong>#{newu.pseudo}</strong>".freeze)

    return newu
  rescue Exception => e
    log(e)
    erreur e.message
    return nil
  end

  # Retourne les options pour un nouvel icarien. On détaille ici les
  # choix, pour référence.
  def options_new_icarien
    o = "0"*32
    o[4]  = '1' # Mail quotidien
    o[16] = '3' # Statut candidat
    o[18] = '0' # Après l'identification, l'icarien rejoint son bureau
    o[22] = '1' # l'icarien est averti par mail en cas de message frigo
    o[26] = '3' # Contact par mail+frigo avec l'administration
    o[27] = '3' # Contact par mail+frigo avec les autres icariens
    o[28] = '0' # Contact par frigo avec le reste du monde
    return o
  end #/ options_new_icarien
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# Envoi du mail de validation de l'adresse mail
attr_reader :ticket_validation_mail

def send_mail_validation_mail(params)
  require_module('ticket')
  @ticket_validation_mail = Ticket.create({user_id:id, code:"run_watcher(#{params[:watcher_id]})".freeze})
  body = deserb('mail_pour_validation_mail', self)
  Mail.send(to:mail, message:body)
end #/ send_mail_validation_mail

def send_mail_confirmation_inscription
  body = deserb('confirmation_inscription', self)
  Mail.send(to:mail, message:body)
end #/ send_mail_confirmation_inscription

end #/User
