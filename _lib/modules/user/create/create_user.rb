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
    options = "0"*32
    newdata = {
      pseudo:       chuser.pseudo,
      patronyme:    chuser.patronyme,
      naissance:    chuser.naissance,
      sexe:         chuser.sexe,
      mail:         chuser.mail,
      salt:         salt,
      cpassword:    Digest::MD5.hexdigest("#{chuser.password}#{chuser.mail}#{salt}"),
      options:      options,
      session_id:   session.id, # dossier de candidature
      created_at:   now,
      updated_at:   now
    }
    valeurs = newdata.values
    columns = newdata.keys.join(VG)
    interro = Array.new(valeurs.count, '?').join(VG)
    request = "INSERT INTO users (#{columns}) VALUES (#{interro})"
    db_exec(request, valeurs)
    if MyDB.error
      log("MyDB.error: #{MyDB.error.inspect}")
      raise "Une erreur SQL est malheureusement survenue…"
    end
    newid = db_last_id
    log("last id : #{newid.inspect}")
    newu = User.get(newid)

    require_module('mail')

    # Envoi d'un message pour valider l'adresse mail
    newu.send_mail_validation_mail

    # Envoi d'un message pour confirmer l'inscription
    newu.send_mail_confirmation_inscription

    # Le watcher qui permettra à l'administrateur de valider l'inscription
    require_module('watchers')
    newu.watchers.add(:validation_inscription, data: {session_id:session.id, modules:chuser.modules_ids}.to_json)
    return newu
  rescue Exception => e
    log(e)
    erreur e.message
    return nil
  end
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# Envoi du mail de validation de l'adresse mail
attr_reader :ticket_validation_mail
def send_mail_validation_mail
  require_module('ticket')
  @ticket_validation_mail = Ticket.create({user_id:id, code:'owner.validate_mail'})
  body = deserb('mail_pour_validation_mail', self)
  Mail.send(to:mail, message:body)
end #/ send_mail_validation_mail

def send_mail_confirmation_inscription
  body = deserb('confirmation_inscription', self)
  Mail.send(to:mail, message:body)
end #/ send_mail_confirmation_inscription

end #/User
