# encoding: UTF-8
=begin
  class Watchers
  --------------
  Pour la gestion des watchers
=end
class Watcher < ContainerClass
class << self
  def table
    @table ||= 'watchers'
  end #/ table
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
#   Méthodes publiques
# ---------------------------------------------------------------------

# Méthode qui joue le watcher
def run
  require_folder_processus unless folder_processus_required?
  self.send(processus.to_sym)
  if poursuivre
    send_mails
    add_actualite
    destroy
    send(:onSuccess) if respond_to?(:onSuccess)
  end
rescue Exception => e
  log(e)
  erreur(e.message)
end #/ run

def unrun
  require_folder_processus unless folder_processus_required?
  self.send("contre_#{processus}".to_sym)
  send_contre_mails
  destroy
  send(:onSuccess) if respond_to?(:onSuccess)
rescue Exception => e
  log(e)
  erreur(e.message)
end #/ unrun

# Destruction du watcher
def destroy
  request = "DELETE FROM watchers WHERE id = #{id}"
  db_exec(request)
end #/ destroy

# Édition du watcher
def edit
  admin_required # protection supplémentaire
  message "Je dois éditer le watcher ##{id}"
end #/ edit

# Pour interrompre le processus joué par le watcher et ne pas le détruire
# ni n'envoyer les mails
def stop_process
  self.poursuivre = false
end #/ stop

# / Fin méthodes publiques
# ---------------------------------------------------------------------

def poursuivre
  @poursuivre = true if @poursuivre.nil?
  @poursuivre
end #/ poursuivre

def poursuivre= valeur
  @poursuivre = false
end #/ poursuivre=

def folder_processus_required?
  @folder_processus_has_been_already_required === true
end #/ folder_processus_required?

def require_folder_processus
  require_module("watchers_processus/#{relpath}")
  @folder_processus_has_been_already_required = true
end #/ require_folder_processus

# Retourne true si le watcher a été vu par l'icarien +who+
def vu_par?(who)
  data["vu_#{who}".to_sym] == 1
end #/ vu?

# ---------------------------------------------------------------------
#
#   DATA
#
# ---------------------------------------------------------------------

# data des data
def params
  @params ||= begin
    if data[:params]
      h={};JSON.parse(data[:params]).each { |k,v| h.merge!(k.to_sym => v) };h
    end
  end
end #/ params

# Chemin relatif (dans watchers_processus) défini dans les données
# absolues
def relpath
  @relpath ||= absdata[:relpath]
end #/ relpath

# Instance concernée, calculée d'après le objet_class et objet_id
# du watcher.
def objet
  @objet ||= Object.const_get(objet_class).get(objet_id)
end #/ objet

def owner
  @owner ||= User.get(user_id)
end #/ owner

def titre
  @titre ||= absdata[:titre]
end #/ titre

def objet_class
  @objet_class ||= relpath.split('/')[0]
end #/ objet_class

def processus
  @processus ||= relpath.split('/')[1]
end #/ processus

def absdata
  @absdata ||= DATA_WATCHERS[wtype.to_sym]
end #/ absdata

def add_actualite
  return unless File.exists?(path_actualite)
  Actualite.add(owner.id, deserb(path_actualite, self))
end #/ add_actualite

# ---------------------------------------------------------------------
#   PATHS
#
# ---------------------------------------------------------------------

# Retourne le chemin d'accès au template de notification du watcher,
# pour l'admin ou l'user suivant la valeur de +who+
def path_notification(who)
  fname = "notification_#{who}.erb".freeze
  File.join(folder, fname)
end #/ path_notification

def path_actualite
  File.join(folder, "actualite.erb".freeze)
end #/ path_actualite

def path_mail(who)
  fname = "mail_#{who}.erb"
  File.join(folder, fname)
end #/ path_mail

def path_contre_mail(who)
  fname = "contre_mail_#{who}.erb"
  File.join(folder, fname)
end #/ path_mail


# Dossier du processus
def folder
  @folder ||= File.join(PROCESSUS_WATCHERS_FOLDER,objet_class,processus)
end #/ folder

private

  # Procédure d'envoi de mail si tout s'est bien passé
  def send_mails
    send_mail_to(:admin) if File.exists?(path_mail(:admin))
    send_mail_to(:user) if File.exists?(path_mail(:user))
  end #/ send_mail
  def send_contre_mails
    send_contre_mail_to(:admin) if File.exists?(path_contre_mail(:admin))
    send_contre_mail_to(:user) if File.exists?(path_contre_mail(:user))
  end #/ contre_send_mail

  def send_mail_to(who)
    send_mail(who, {body: deserb(path_mail(who), self)})
  end #/ send_mail_to

  def send_contre_mail_to(who)
    send_mail(who, {body: deserb(path_contre_mail(who), self)})
  end #/ send_mail_to

  def send_mail(who, data)
    require_module('mail')
    whouser   = who_is(who)
    otheruser = other_who_is(who)
    Mail.send(
      to: whouser.mail,
      from:otheruser.mail,
      message: data[:body]
    )
  end #/ send_mail

  def who_is(who)
    case who
    when :admin then User.get(1)
    when :user  then owner
    end
  end #/ who_is
  def other_who_is(who)
    case who
    when :admin then owner
    when :user  then User.get(1)
    end
  end #/ other_who_is
end #/Watcher
