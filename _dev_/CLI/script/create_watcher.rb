# encoding: UTF-8
=begin
  Script assistant pour créer un nouveau type de watcher
=end

ID_WATCHER = 'validation_adresse_mail'
DATA_WATCHER = {
  titre: 'Validation de votre adresse mail', # pour la notification (user et admin)
  objet_class:  'User',       # le dossier principal
  processus:    'valid_mail', # le processus
  # Notifications
  notif_user:   true,
  notif_admin:  false,
  # Mails
  mail_user:    false,
  mail_admin:   false,
  # Actualité
  actu_id: nil # mettre l'identifiant (majuscules) actualité, si actualité
  actualite:    false
}

if DATA_WATCHER[:actualite] && DATA_WATCHER[:actu_id].nil?
  raise "Il faut absolumemnt fournir l'ID actualité"
end

class WatcherCreator
class << self
  def folder
    @folder ||= File.expand_path(File.join('.','_lib','modules','watchers_processus'))
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
  [:admin,:user].each do |who|
    # La notification
    key = "notif_#{who}".to_sym
    data[key] || next
    path = send("notification_#{who}_path".to_sym)
    next if File.exists?(path)
    code = "<p>Notification à afficher sur le bureau</p>"
    File.open(path,'wb'){|f| f.write code}
    # Le mail
    key = "mail_#{who}".to_sym
    data[key] || next
    path = send("#{key}_path".to_sym)
    next if File.exists?(path)
    code = "<p>Bonjour #{who == :admin ? 'Phil' : '<%= owner.pseudo %>'},</p>#{RC}<p>Message du mail</p>"
    File.open(path,'wb'){|f| f.write code}
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
# ---------------------------------------------------------------------
#   Vérification
# ---------------------------------------------------------------------
def valid?
  true
end #/ valid?
# ---------------------------------------------------------------------
#   Paths
# ---------------------------------------------------------------------
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
path_data = "/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/modules/watchers/constants.rb"
code = File.read(path_data).force_encoding('utf-8')
unless code.include?("#{ID_WATCHER}:")
  `open -a Atom #{path_data}`
  puts "Il faut ajouter le code suivant au fichier que je vais ouvrir :"
  puts <<-RUBY
    #{ID_WATCHER}: {
      titre: '#{DATA_WATCHER[:titre]}'.freeze,
      relpath: '#{DATA_WATCHER[:objet_class]}/#{DATA_WATCHER[:processus]}'.freeze,
      actu_id: #{DATA_WATCHER[:actu_id].inspect}
    },
  RUBY
end
puts "\n\nWatcher créé avec succès"
