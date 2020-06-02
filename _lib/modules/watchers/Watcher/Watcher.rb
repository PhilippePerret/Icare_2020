# encoding: UTF-8
=begin
  class Watchers
  --------------
  Pour la gestion des watchers
=end
class Watcher < ContainerClass
class << self

  # Retourne tous les watchers de l'icarien +icarien+
  # {Array de Watcher}
  def watchers_of icarien
    icarien = User.get(icarien) if icarien.is_a?(Integer)
    request = "SELECT * FROM #{table} WHERE user_id = #{icarien.id}"
    db_exec(request).collect do |dwatcher| new(dwatcher) end
  end #/ watchers_of

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
  require_folder_processus
  self.send(processus.to_sym)
  destroy
  send_mail
end #/ run

def unrun
  require_folder_processus
  self.send("contre_#{processus}".to_sym)
  destroy
  send_contre_mail
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

# / Fin méthodes publiques
# ---------------------------------------------------------------------

def require_folder_processus
  require_module("watchers_processus/#{relpath}")
end #/ require_folder_processus

# Retourne true si le watcher a été vu par l'icarien
def vu?
  # data[user.admin? ? :vu_admin : :vu_user] == true
  log("data: #{data.inspect}")
  data[:vu_user] == true
end #/ vu?

# ---------------------------------------------------------------------
#
#   DATA
#
# ---------------------------------------------------------------------

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

# Retourne le chemin d'accès au template de notification du watcher,
# pour l'admin ou l'user suivant la valeur de +who+
def path_notification(who)
  fname = "notification_#{who}.erb".freeze
  File.join(folder, fname)
end #/ path_notification

# Dossier du processus
def folder
  @folder ||= File.join(PROCESSUS_WATCHERS_FOLDER,objet_class,processus)
end #/ folder

end #/Watcher
