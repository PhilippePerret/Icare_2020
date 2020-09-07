# encoding: UTF-8
# frozen_string_literal: true

CONFIG = {}
PAGES_DATA = {}

class PageChecker
class << self

  # = main =
  #
  # Main méthode appelée au lancement l'application
  def run
    # On commence par vérifier que tout est conforme. On doit trouver un
    # fichier pages_data.yaml et un fichier config.yaml à la racine du
    # testeur.
    check_application || return
    # On charge l'extension pour l'application si elle existe
    load_app_extension || return
    # On charge le fichier de configuration
    load_configuration || return
    # On charge le fichier des données de page
    load_pages_data || return
    # On doit faire l'analyse de la commande passée
    CLI.analyse_command_line
    # Une URL a dû être définie, sinon, on ne peut pas procéder
    # Noter que l'URL peut se définir soit en argument soit dans le fichier
    # de configuration.
    define_url || return
    # On peut commencer
    # Si on met l'option --try, c'est pour un essai
    if CLI.option?(:try)
      try_something
    else
      # On lance le check du site
      check_url
    end
  end #/ run


  # ---------------------------------------------------------------------
  #
  #   Méthodes fonctionnelles
  #
  # ---------------------------------------------------------------------


  # Vérifie que le testeur soit bien défini
  def check_application
    File.exists?(pages_data_file) || raise(ERRORS[:pages_data_file_required] % pages_data_file)
    File.exists?(config_file)     || raise(ERRORS[:config_file_required] % config_file)
  rescue Exception => e
    erreur(e.message)
  end #/ check_application

  # Chargement de l'extension pour l'application.
  # C'est cette extension, notamment, qui contient la façon de se mettre
  # dans un contexte (par exemple administrateur ou user identifié)
  def load_app_extension
    pth = File.join(APP_FOLDER,'app_extension.rb')
    require pth if File.exists?(pth)
    return true
  end #/ load_app_extension

  # Chargement du fichier de configuration (défini CONFIG)
  def load_configuration
    CONFIG.merge!(YAML.load_file(config_file).to_sym(deep=true))
    return true
  end #/ load_configuration

  def load_pages_data
    PAGES_DATA.merge!(YAML.load_file(pages_data_file).to_sym(deep=true))
    return true
  end #/ load_pages_data

  # Définit définitivement l'URL, soit en la prenant dans le fichier
  # de configuration, soit en la prenant dans le premier argument.
  def define_url
    CONFIG[:url] ||= {}
    confkey = CLI.option?(:online) ? :online : :offline
    if CLI.command&.start_with?('http')
      CONFIG[:url].merge!(confkey => CLI.command)
    end

    not(CONFIG[:url][confkey].nil?) || raise(ERRORS[:url_required])
  end #/ define_url

  # ---------------------------------------------------------------------
  #
  #   Pour des essais
  #
  # ---------------------------------------------------------------------

  def try_something
    # On essaie d'appeler le formulaire une première fois
    # res = `cUrl -s --data "user_mail=phil@atelier-icare.net&user_password=19ElieSalome64&press=S’identifier&form_id=user-login" http://localhost/AlwaysData/Icare_2020/user/login`
    require 'securerandom'
    curluser = SecureRandom.hex(10)
    pth = File.join('.','tmp', curluser)
    File.open(pth,'wb'){|f| f.write(1)}
    res = `cUrl -s --cookie-jar cookies.txt http://localhost/AlwaysData/Icare_2020/?curluser=#{curluser}`
    puts "#{RC*4}---- res: #{res}"
    res = `cUrl -s --cookie cookies.txt --cookie-jar cookies.txt http://localhost/AlwaysData/Icare_2020/bureau/home`
    puts "#{RC*4}---- res: #{res}"
    res = `cUrl -s --cookie cookies.txt --cookie-jar cookies.txt http://localhost/AlwaysData/Icare_2020/user/logout`
    puts "#{RC*4}---- res: #{res}"
  end #/ try_something
  # ---------------------------------------------------------------------
  #
  #   PATHS
  #
  # ---------------------------------------------------------------------
  def config_file
    @config_file ||= File.join(APP_FOLDER,'config.yaml')
  end #/ config_file
  def pages_data_file
    @pages_data_file ||= File.join(APP_FOLDER,'pages_data.yaml')
  end #/ pages_data_file
end # /<< self
end #/PageChecker
