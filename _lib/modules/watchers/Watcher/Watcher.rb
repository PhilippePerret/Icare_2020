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
  send_mails
  add_actualite
  next_watcher if absdata[:next]
  destroy
  send(:onSuccess) if respond_to?(:onSuccess)
rescue WatcherInterruption => e
  log("L'erreur (e) dans WatcherInterruption est :")
  log(e)
  erreur(e.message) if e.message
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

# Génération du watcher suivant (automatique)
# SI ET SEULEMENT SI :
#   + la propriété :next du watcher est définie dans ses données absolues
#   + :object_class est la même entre celui-ci et le suivant
def next_watcher
  unless absdata[:next].nil?
    owner.watchers.add(wtype:absdata[:next], objet_id:objet_id)
  else
    erreur "ERREUR SYSTÉMIQUE : la propriété :next du watcher n'est pas définie. impossible d'utiliser next_watcher.".freeze
  end
end #/ next_watcher

# Destruction du watcher
def destroy
  request = "DELETE FROM watchers WHERE id = #{id}"
  db_exec(request)
end #/ destroy

# Cf. le mode d'emploi pour le détail de cette procédure (dans la section
# des téléchargements, pas des watchers)
# NOTE Attention, dans le code ci-dessous, il s'agit bien de `user` (le
# visiteur actuel) et non pas le `owner` de ce watcher. Un watcher appartient
# à un icarien et ça peut être moi qui télécharge des fichiers.
def download_from_watcher(path_folder)
  require_module('ticket')
  ticket = Ticket.create(user_id:user.id, code:"download('#{path_folder}')")
  redirect_to("#{route.to_s}?tikd=#{ticket.id}")
end #/ download_from_watcher

# Édition du watcher
def edit
  admin_required # protection supplémentaire
  message "Je dois éditer le watcher ##{id}"
end #/ edit

# / Fin méthodes publiques
# ---------------------------------------------------------------------

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
  Actualite.add(absdata[:actu_id], owner.id, deserb(path_actualite, self))
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
