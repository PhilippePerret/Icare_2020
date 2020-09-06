# encoding: UTF-8
# frozen_string_literal: true

CONFIG = {}

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
    # On charge le fichier de configuration
    load_configuration || return
    # On doit faire l'analyse de la commande passée
    CLI.analyse_command_line
    # Une URL a dû être définie, sinon, on ne peut pas procéder
    # Noter que l'URL peut se définir soit en argument soit dans le fichier
    # de configuration.
    define_url || return
    # On peut commencer
    check_url
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

  # Chargement du fichier de configuration (défini CONFIG)
  def load_configuration
    CONFIG.merge!(YAML.load_file(config_file).to_sym(deep=true))
    return true
  end #/ load_configuration

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
