# encoding: UTF-8
=begin
  Script assistant pour créer un nouveau type de watcher
=end

unless defined?(NEW_WATCHER)
  ID_WATCHER = 'qdd_sharing'
  DATA_WATCHER = {
    titre: 'Définition du partage des documents', # pour la notification (user et admin)
    objet_class:  'IcEtape',       # le dossier principal
    processus:    'qdd_sharing', # le processus (~ nom méthode)
    # L'ID-Watcher suivant SI ET SEULEMENT SI l'objet_class reste la même
    # NOTE : il s'agit d' ID_WATCHER, pas du processus (dans ce cas, il vaut mieux
    # que les deux soient identiques, si c'est possible — en général, c'est
    # toujours possible).
    next:         nil,
    # Notifications
    notif_user:   true,
    notif_admin:  false,
    # Mails
    mail_user:    false,
    mail_admin:   true,
    # Actualité
    actu_id:      '', # mettre l'identifiant (majuscules) actualité, si actualité
    actualite:    false
  }
else
  ID_WATCHER    = NEW_WATCHER[:id]
  DATA_WATCHER  = NEW_WATCHER
end

# Ne rien toucher en dessous de cette ligne
# ---------------------------------------------------------------------

if DATA_WATCHER[:actualite] && DATA_WATCHER[:actu_id].nil?
  raise "Il faut absolumemnt fournir l'ID actualité"
end

class WatcherCreator
class << self
  def folder
    @folder ||= File.expand_path(File.join('.','_lib','_watchers_processus_'))
  end #/ folder
end # /<< self
attr_reader :id, :data, :objet_class, :processus
def initialize(id, data)
  @id = id
  @data = data
  data.each {|k,v| instance_variable_set("@#{k}",v)}
end #/ initialize
# ---------------------------------------------------------------------
#   Méthodes de fabrication
# ---------------------------------------------------------------------
def build
  valid? || raise("Je dois renoncer")
  build_folder unless File.exists?(folder)
  build_main_file unless File.exists?(main_file)
  build_actualite_file if DATA_WATCHER[:actualite] && !File.exists?(self.actualite_path)
  [:admin,:user].each do |who|
    # La notification
    key = "notif_#{who}".to_sym
    if data[key]
      path = send("notification_#{who}_path".to_sym)
      next if File.exists?(path)
      code = "<p>Notification à afficher sur le bureau</p>"
      File.open(path,'wb'){|f| f.write code}
    end
    # Le mail
    key = "mail_#{who}".to_sym
    if data[key]
      path = send("#{key}_path".to_sym)
      next if File.exists?(path)
      code = "<p>Bonjour #{who == :admin ? 'Phil' : '<%= owner.pseudo %>'},</p>\n\n<p>Message du mail</p>\n\n<p><%= Le_Bot %></p>"
      File.open(path,'wb'){|f| f.write code}
    end
  end
end #/ build

def build_folder
  `mkdir -p "#{folder}"`
end #/ build_folder

def build_main_file
  code = <<-RUBY
# encoding: UTF-8
class Watcher < ContainerClass
  def #{processus}
    message "Je dois jouer le processus #{objet_class}/#{processus}"
  end # / #{processus}
  def contre_#{processus}
    message "Je dois jouer le contre processus #{objet_class}/contre_#{processus}"
  end # / contre_#{processus}
end # /Watcher < ContainerClass
  RUBY
  File.open(main_file,'wb'){|f| f.write code}
end #/ build_main_file

def build_actualite_file
  File.open(actualite_path,'wb'){|f| f.write <<-HTML }
<span>TEXTE DE L'ACTUALITÉ POUR <strong><%= owner.pseudo %></strong></span>
  HTML
end #/ build_actualite_file
# ---------------------------------------------------------------------
#   Vérification
# ---------------------------------------------------------------------
def valid?
  true
end #/ valid?
# ---------------------------------------------------------------------
#   Paths
# ---------------------------------------------------------------------
def actualite_path
  @actualite_path ||= File.join(folder,'actualite.erb')
end #/ actualite_path
def mail_admin_path
  @mail_admin_path ||= mail_path_for(:admin)
end #/ mail_admin_path
def mail_user_path
  @mail_user_path ||= mail_path_for(:user)
end #/ mail_user_path
def notification_admin_path
  @notification_admin_path ||= notification_path_for(:admin)
end #/ notification_admin_path
def notification_user_path
  @notification_user_path ||= notification_path_for(:user)
end #/ notification_user_path
def main_file
  @main_file ||= File.join(folder,'main.rb')
end #/ main_file
def folder
  @folder ||= File.join(self.class.folder, objet_class, processus)
end #/ folder
# ---------------------------------------------------------------------
#   Data
# ---------------------------------------------------------------------
def notif_user? ; @notif_user == true end #/ notif_user?
def notif_admin? ; @notif_admin == true end #/ notif_admin?
def mail_user? ; @mail_user == true end #/ mail_user?
def mail_admin? ; @mail_admin == true end #/ mail_admin?

private
  def mail_path_for(who)
    File.join(folder, "mail_#{who}.erb")
  end #/ mail_path_for
  def notification_path_for(who)
    File.join(folder, "notification_#{who}.erb")
  end #/ notification_path_for
end #/WatcherCreator

creator = WatcherCreator.new(ID_WATCHER, DATA_WATCHER)
creator.build
path_data = "/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/_watchers_processus_/_constants_.rb"
code = File.read(path_data).force_encoding('utf-8')
unless code.include?("#{ID_WATCHER}:")
  puts "\n\nIl faut ajouter le code suivant au fichier que je vais ouvrir dans Atom :\n\n"
  puts <<-RUBY
    #{ID_WATCHER}: {
      titre: '#{DATA_WATCHER[:titre]}'.freeze,
      relpath: '#{DATA_WATCHER[:objet_class]}/#{DATA_WATCHER[:processus]}'.freeze,
      actu_id: #{DATA_WATCHER[:actu_id].inspect},
      next: #{DATA_WATCHER[:next] ? "'#{DATA_WATCHER[:next]}'.freeze" : 'nil'}
    },
  RUBY
  sleep 4
  `open -a Atom #{path_data}`
end
puts "\n\nWatcher créé avec succès"
