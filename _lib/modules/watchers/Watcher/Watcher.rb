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

# Méthode qui affiche le watcher
def out(options = nil)
  require_folder_processus
  key = user.admin? ? :admin : :user
  erbpath = path_notification(key)
  if File.exists?(erbpath)
    Tag.div(text:deserb(erbpath, self), class:'watcher')
  else '' end
end #/ out

# Méthode qui joue le watcher
def run
  message "Je joue le watcher #{id}"
end #/ run

def require_folder_processus
  require_module("watchers_processus/#{objet_class}/#{processus}")
end #/ require_folder_processus

# Retourne true si le watcher a été vu par l'icarien
def vu?
  # data[user.admin? ? :vu_admin : :vu_user] == true
  log("data: #{data.inspect}")
  data[:vu_user] == true
end #/ vu?

def objet
  @objet ||= Object.const_get(objet_class).get(objet_id)
end #/ objet

def owner
  @owner ||= User.get(user_id)
end #/ owner

# Retourne le chemin d'accès au template de notification du watcher,
# pour l'admin ou l'user suivant la valeur de +who+
def path_notification(who)
  fname = "notification_#{who}.erb".freeze
  File.join(folder, fname)
end #/ path_notification

def folder
  @folder ||= File.join(PROCESSUS_WATCHERS_FOLDER,objet_class,processus)
end #/ folder

end #/Watcher
