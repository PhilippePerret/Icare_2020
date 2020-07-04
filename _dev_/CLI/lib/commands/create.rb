# encoding: UTF-8
=begin
  Extension de IcareCLI pour les créations
=end
WATCHERS_FOLDER = File.expand_path('./_lib/_watchers_processus_')
PAGES_FOLDER = File.expand_path('./_lib/pages')

MESSAGES = {
  question_creer: 'Que souhaitez-vous créer ?'.freeze,
  ask_id_whatcher: 'Identifiant (son wtype dans les données)'.freeze,
  ask_titre_watcher: 'Titre (sera affiché sur la notification)'.freeze,
  ask_class_watcher: 'Classe de l’objet concerné'.freeze,
  ask_processus_watcher: 'Processus (nom du dossier dans %s, p.e. "qdd_sharing")'.freeze,
  ask_next_watcher: 'Processus suivant (nom de son dossier, p.e. "qdd_sharing")'.freeze,
  ask_for_notif_user: 'Une notification icarien ?'.freeze,
  ask_for_notif_admin: 'Une notification administrateur ?'.freeze,
  ask_for_mail_admin: 'Un mail à l’administrateur après avoir joué ce watcher ?'.freeze,
  ask_for_mail_user: 'Un mail à l’icarien après avoir joué ce watcher ?'.freeze,
  ask_for_actualite: 'Une actualité devra-t-elle être produite ?'.freeze,
  ask_for_actu_id: 'Identifiant de l’actualité (p.e. "QDDDEPOT")'.freeze,
  confirm_watcher: 'Confirmez-vous la création de ce watcher ?'.freeze,
  ask_for_route: 'Nouvelle route à créer : (dossier/sousdossier)'.freeze,
  titre_route: 'Titre qu’affichera la page de cette route'.freeze,
  ask_if_body_erb: 'Faut-il une page body.erb pour construire la page ?'.freeze,
  ask_if_fichier_constantes: 'Y a-t-il un fichier de constantes (pour les messages par exemple) ?'.freeze,
  ask_if_module_user: 'Y a-t-il besoin d’une extension User (user.rb) ?'.freeze,
  ask_if_form: 'Y aura-t-il besoin d’un formulaire ?'.freeze,
  ask_if_icarien_required: 'L’accès est-il réservé à un icarien ?'.freeze,
  ask_if_admin_required: 'L’accès est-il réservé à un administrateur ?'.freeze,
  confirm_route: 'Confirmez-vous la création de cette nouvelle route ?'.freeze
}
ERRORS = {
  id_watcher_exists: 'Cet identifiant de watcher existe déjà !'.freeze,
  titre_watcher_exists: 'Ce titre de watcher existe déjà'.freeze,
  relpath_watcher_exists: 'Le processus %s existe déjà !'.freeze,
  actu_id_exists: "Cet identifiant actualité existe déjà !".freeze,
  route_exists: 'Cette route existe déjà !'.freeze,
  route_invalid: 'Le nom de cette route est invalide'.freeze,
}

DATA_CREATE = [
  {name: 'un watcher',  value: :watcher},
  {name: 'une route',   value: :route},
  {name: 'rien, en fait', value: nil}
]

LISTE_CLASSES = [
  {name: 'IcDocument'},
  {name: 'IcEtape'},
  {name: 'IcModule'},
  {name: 'User'},
  {name: 'FrigoDiscussion'}
]

NEW_WATCHER = {
  id:nil, titre:nil, objet_class:nil, processus:nil, next:nil,
  notif_user:false, notif_admin:false, mail_user:false, mail_admin:false,
  actu_id:nil, actualite:false
}

# Pour une nouvelle page
DATA_PAGE = {
  id: nil, titre:nil, body_erb:false, form:false, module_user:false,
  icarien_required:false, admin_required: false,
  fichier_constantes: false
}
class IcareCLI
class << self
  def proceed_create
    what = params[1]
    if what
      unless respond_to?("create_#{what}".to_sym)
        puts "Je ne sais pas créer la chose '#{what}'. Choisissez-la.".rouge
        what = nil
      end
    end
    what ||= Q.select(MESSAGES[:question_creer]) do |q|
      q.choices DATA_CREATE
      q.per_page DATA_CREATE.count
    end || return
    send("create_#{what}".to_sym)
  end #/ help

  def create_watcher
    clear
    puts "Création d'un nouveau watcher".bleu
    require './_lib/_watchers_processus_/_constants_.rb'
    NEW_WATCHER[:id] = Q.ask(MESSAGES[:ask_id_whatcher]) do |q|
      q.required true
      q.validate{|input|!DATA_WATCHERS.key?(input.to_sym)}
      q.messages[:valid?] = ERRORS[:id_watcher_exists]
    end
    NEW_WATCHER[:titre] = Q.ask(MESSAGES[:ask_titre_watcher]) do |q|
      q.required true
      q.validate do |input|
        res = true
        DATA_WATCHERS.each { |k,dv| (res = false ; break) if dv.value?(input) }
        res
      end
      q.messages[:valid?] = ERRORS[:titre_watcher_exists]
    end

    # objet_class
    NEW_WATCHER[:objet_class] = Q.select(MESSAGES[:ask_class_watcher]) do |q|
      q.choices LISTE_CLASSES
      q.per_page LISTE_CLASSES.count
    end

    # processus
    NEW_WATCHER[:processus] = Q.ask(MESSAGES[:ask_processus_watcher] % [NEW_WATCHER[:objet_class]]) do |q|
      q.required true
      q.validate do |input|
        q.messages[:valid?] = ERRORS[:relpath_watcher_exists] % ["#{NEW_WATCHER[:objet_class]}/#{input}"]
        !File.exists?(File.join(WATCHERS_FOLDER, NEW_WATCHER[:objet_class], input))
      end
    end

    # processus suivant
    NEW_WATCHER[:next] = Q.ask(MESSAGES[:ask_next_watcher])

    # Notifs et mail
    [
      :notif_user, :notif_admin, :mail_user, :mail_admin, :actualite
    ].each do |key|
      NEW_WATCHER[key] = Q.select(MESSAGES["ask_for_#{key}".to_sym]) do |q|
        q.choices [{name:'oui', value:true}, {name:'non', value:false}]
      end
    end

    if NEW_WATCHER[:actualite]
      NEW_WATCHER[:actu_id] = Q.ask(MESSAGES[:ask_for_actu_id]) do |q|
        q.required true
        q.validate do |input|
          res = true
          DATA_WATCHERS.each { |k,dv| (res = false ; break) if dv[:actu_id] == input }
          res
        end
        q.messages[:valid?] = ERRORS[:actu_id_exists]
      end
    end

    # Un petit récapitulatif avec création
    clear
    puts "Merci de confirmer ce choix :\n\n".freeze
    NEW_WATCHER.each do |k, v|
      msg = "\t#{"#{k}:".ljust(15)}#{v.inspect}"
      if v === true
        msg = msg.vert
      elsif v === false
        msg = msg.rouge
      end
      puts msg
    end
    puts "\n\n"
    Q.yes?(MESSAGES[:confirm_watcher]) || return
    require './_dev_/CLI/script/create_watcher.rb'
  end #/ create_watcher

  def create_route
    clear
    DATA_PAGE[:route] = Q.ask(MESSAGES[:ask_for_route]) do |q|
      q.validate do |input|
        path = File.join(PAGES_FOLDER,input)
        if input.gsub(/[a-z0-9_\/]/,'') != ''
          q.messages[:valid?] = ERRORS[:route_invalid]
          false
        elsif File.exists?(path)
          q.messages[:valid?] = ERRORS[:route_exists]
          false
        else
          true
        end
      end
    end
    DATA_PAGE[:titre] = Q.ask(MESSAGES[:titre_route])
    [
      :body_erb, :form, :module_user, :icarien_required, :admin_required, :fichier_constantes
    ].each do |key|
      DATA_PAGE[key] = Q.select(MESSAGES["ask_if_#{key}".to_sym]) do |q|
        q.choices [{name:'oui', value:true}, {name:'non', value:false}]
      end
    end

    # Un petit récapitulatif avec création
    clear
    puts "Merci de confirmer ce choix :\n\n".freeze
    DATA_PAGE.each do |k, v|
      msg = "\t#{"#{k}:".ljust(15)}#{v.inspect}"
      if v === true
        msg = msg.vert
      elsif v === false
        msg = msg.rouge
      end
      puts msg
    end

    puts "\n\n"
    Q.yes?(MESSAGES[:confirm_route]) || return
    require './_dev_/CLI/script/create_route.rb'

  end #/ create_route

end # /<< self
end #/IcareCLI
