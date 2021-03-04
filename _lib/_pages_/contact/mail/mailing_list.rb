# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module de MailingList
=end
class MailingList
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  attr_accessor :apercu_current
  attr_accessor :procedure_current

  # = main =
  #
  # Pour afficher le mail tel qu'il apparaitra dans les messages femmes/hommes.
  def apercu
    self.apercu_current = new
  end #/ apercu

  # = main =
  #
  # La procédure a été confirmée après affichage des messages, on procède
  # véritablement à l'envoi en se servant du fichier 'tmp/mails/mailing.json'
  # qui a été enregistré.
  def traite
    if not File.exists?(data_path)
      return erreur("Aucun fichier de mailing n'est défini. Je ne peux pas procéder au mailing.")
    end
    self.procedure_current = new
    self.procedure_current.data_proceed = JSON.parse(File.read(data_path))
    self.procedure_current.proceed
  end


  # Pour détruire le mailing enregistré (i.e. le fichier mailing.json sauvé
  # dans ./tmp/mailing.json)
  def destroy_saved_mailing
    user.admin? || raise(ERRORS[:admin_required])
    File.exists?(data_path) || raise(ERRORS[:no_saved_mailing])
    dmailing = JSON.parse(File.read(data_path))
    param(:uuid) == dmailing['uuid'] || raise(ERRORS[:mailing_uuid_invalid])
    # Tout est OK on peut procéder à la destruction du mailing
    File.delete(data_path)
    message("Mailing détruit avec succès.")
  rescue Exception => e
    log(e)
    erreur(e.message)
  end #/ destroy_saved_mailing

  # Lorsqu'il existe un fichier ./tmp/mails/mailing.json, on le considère comme
  # un mailing enregistré. On place donc un bouton dans la page pour l'envoyer.
  def box_procedure
    dmailing = JSON.parse(File.read(data_path))
    <<-HTML
<div class="mt2">
  <div class="right">
    <a href="contact/mail?op=detruire_mailing_list&uuid=#{dmailing['uuid']}" class="fleft">Détruire ce mailing</a>
    <a href="contact/mail?op=traite_mailing_list&uuid=#{dmailing['uuid']}" class="main btn">Procéder à l’envoi du mailing enregistré</a>
  </div>
  <fieldset>
    <legend>Aperçu du mail</legend>
    <div class="bold">#{dmailing['mail_subject']}</div>
    <div>#{dmailing['mail_message']}</div>
  </fieldset>
</div>
    HTML
  end #/ box_procedure

  def data_path
    @data_path ||= begin
      File.join(MAILS_FOLDER,'mailing.json')
    end
  end #/ data_path

end # /<< self









# ---------------------------------------------------------------------
#
#   INSTANCE
#   (un envoi à tous les users choisis est une instance MailingList)
# ---------------------------------------------------------------------


# = main =
def proceed
  ['uuid','mail_format', 'mail_subject'].each do |key|
    instance_variable_set("@#{key}", data_proceed[key])
  end
  @destinataires = data_proceed['destinataires_id'].collect{|id|User.get(id)}
  @mail_message_template = data_proceed['mail_message']
  if uuid != param(:uuid)
    raise("L'UUID du mailing est invalide, je ne peux pas procéder à l'opération.")
  end

  @resultat = ["<p class=bold>=== Mailing #{uuid} du #{formate_date}===</p><ul>"]
  @resultat += MailSender.send_mailing(to:destinataires, message:mail_message, subject:mail_subject)

  # destinataires.each do |u|
  #   u.send_mail({
  #     subject: mail_subject,
  #     message: message_per_format(user: u)
  #   })
  #   @resultat << "<div>Message envoyé à #{u.mail}</div>"
  # end
  @resultat << "</ul><p class='success'>=== Mailing transmis avec succès à #{destinataires.count} destinataires. ===</p>"

  File.delete(self.class.data_path)

end #/ proceed

# Méthode d'affichage qui affiche le résultat de l'envoi par mail
def resultat
  @resultat.join(RC)
end #/ resultat


def data_proceed
  @data_proceed ||= begin
    {
      destinataires_id: destinataires.collect{|u| u.id},
      uuid: uuid,
      mail_format: mail_format,
      mail_message: mail_message,
      mail_subject: mail_subject
    }
  end
end #/ data_proceed
def data_proceed=(v)
  @data_proceed = v
end #/ data_proceed=
# = main =
#
# Traitement d'un mailing
def apercu
  @apercu ||= begin
    raise(ERRORS[:groupe_destinataires_required]) if groupes_destinataires.empty?
    # On construit l'aperçu
    # ---------------------
    # Note : on le met avant le dump marshal notamment pour
    # avoir l'UUID, et puis la liste des destinataires, etc.
    ap = apercu_message_femme + apercu_message_homme + boite_confirmation
    # On enregistre les données dans un fichier Marshal pour les reprendre
    # à la confirmation sans avoir à tout refaire
    File.open(self.class.data_path,'wb'){|f| f.write data_proceed.to_json}

    ap
  end
end #/ apercu

def uuid
  @uuid ||= begin
    require 'securerandom'
    SecureRandom.hex(10)
  end
end #/ uuid

# Simple "boite" HTML pour confirmer l'envoi, après affichage de l'aperçu
def boite_confirmation
  <<-HTML
<fieldset id="liste-destinataires">
  <legend>Destinataires (#{destinataires.count})</legend>
  #{destinataires.collect{|u|u.pseudo}.pretty_join}
</fieldset>
<div class="mt2 right">
  <a href="contact/mail?op=traite_mailing_list&uuid=#{uuid}" class="main btn">#{UI_TEXTS[:proceed_envoi]}</a>
</div>
<div class="explication">Si vous ne procédez pas à l'envoi immédiatement, il sera enregistré et pourra être transmis une prochaine fois, en repassant par ce formulaire de contact.</div>
  HTML
end #/ boite_confirmation

def message_per_format(params)
  case mail_format
  when 'md'   then kramdown(mail_message, params[:user])
  when 'erb'  then deserb(mail_message, params[:user])
  else mail_message
  end
end #/ message_per_format

def apercu_message_homme
  @apercu_message_homme ||= begin
    <<-HTML
<fieldset id="mail-version-homme">
  <legend>Message homme (format : #{mail_format})</legend>
  <div class="bold">#{mail_subject}</div>
  #{message_per_format(user: phil)}
</fieldset>
    HTML
  end
end #/ apercu_message_homme

def apercu_message_femme
  @apercu_message_femme ||= begin
    <<-HTML
<fieldset id="mail-version-femme">
  <legend>Message femme (format : #{mail_format})</legend>
<div class="bold">#{mail_subject}</div>
#{message_per_format(user: User.get(10))}
</fieldset>
    HTML
  end
end #/ apercu_message_femme

def mail_format
  @mail_format ||= param(:message_format)
end #/ mail_format
def mail_message_template
  @mail_message_template ||= param(:envoi_message) + mail_signature
end #/ mail_message_template
def mail_message
  mail_message_template.dup
end #/ mail_message
def mail_subject
  @mail_subject ||= param(:envoi_titre)
end #/ mail_subject
def mail_signature
  @mail_signature ||= begin
    case param(:mail_signature)
    when 'none'
      ''
    when 'phil'
      case mail_format
      when 'html', 'erb' then "<p>😎 Phil, pédagogue de l’atelier</p>"
      when 'md' then "\n\n😎 Phil, pédagogue de l’atelier"
      end
    when 'bot'
      case mail_format
      when 'html' then "<p>🤖 Le Bot de l’atelier Icare</p>"
      when 'erb' then "<p><%= le_bot %></p>"
      when 'md' then "\n\n🤖 Le Bot de l’atelier Icare"
      end
    else
      ''
    end
  end
end #/ mail_signature


# Retourne les instances User des destinataires choisis
def destinataires
  @destinataires ||= begin
    wheres = []
    if groupes_destinataires.include?(:admin)
      wheres << "SUBSTRING(options,1,1) > 0" # admin
    else
      wheres << "SUBSTRING(options,1,1) = '0'" # pas admin
    end
    wheres << "SUBSTRING(options,4,1) = '0'" # pas détruit
    liste_statuts = []
    liste_statuts << 2 if groupes_destinataires.include?(:actif)
    liste_statuts << 3 if groupes_destinataires.include?(:candidat)
    liste_statuts << 4 if groupes_destinataires.include?(:inactif)
    liste_statuts << 6 if groupes_destinataires.include?(:recu)
    liste_statuts << 8 if groupes_destinataires.include?(:pause)
    if liste_statuts.count == 0
      unless groupes_destinataires.include?(:admin)
        raise("Il faut absolument choisir un groupe de destinataire.")
      end
    elsif liste_statuts.count == 1
      wheres << "SUBSTRING(options,17,1) = '#{liste_statuts.first}'"
    else
      wheres << "SUBSTRING(options,17,1) IN (#{liste_statuts.join(VG)})"
    end
    wheres = wheres.join(AND)
    log("wheres destinataires : #{wheres}")
    User.get_instances(order: 'pseudo', where: wheres) << phil
  end
end #/ destinataires

# Les groupes de destinataires, par statut
def groupes_destinataires
  @groupes_destinataires ||= begin
    table = User::DATA_STATUT.dup
    table.merge!(admin: {icarien: true, value:9, name:'admin'})
    table.collect do |statut_id, dstatut|
      next if dstatut.is_a?(Symbol)
      next if not(dstatut[:icarien])
      statut_id if param(statut_id) == 'on'
    end.compact
  end
end #/ groupes_destinataires
end #/MailingList
