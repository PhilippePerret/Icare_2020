# encoding: UTF-8
# frozen_string_literal: true
class App

ONLINE = ENV['HTTP_HOST'] != "localhost" unless defined?(ONLINE)
URL_ONLINE  = 'www.atelier-icare.net'
URL_OFFLINE = 'localhost/AlwaysData/Icare_2020'
FULL_URL_ONLINE   = "https://#{URL_ONLINE}"
FULL_URL_OFFLINE  = "http://#{URL_OFFLINE}"

# L'url courante
# @usage    App::URL
URL = ONLINE ? FULL_URL_ONLINE : FULL_URL_OFFLINE

class << self

  # = Main method =
  def run
    log("#{RC*2}")
    log("------> App::run")
    self.init
    User.init
    html.build_page
    html.out
    self.finish
    log("<------ App::run")
  end

  # Initialisation de l'atelier
  def init
    log("-> App::init")
    Session.init
    Errorer.desessionnize
    Noticer.desessionnize
  end

  # Pour finir
  def finish
    log("-> App::finish")
    Route.last = route.to_s.dup
    Session.finish
    log("<- App::finish")
  rescue Exception => e
    log("ERREUR DANS finish: #{e.message}")
    log(e)
  end

  # L'url courante, en fonction du fait qu'on est offline ou online
  def url
    OFFLINE ? FULL_URL_OFFLINE : FULL_URL_ONLINE
  end

  # Version de l'application
  #
  # Cette version sert notamment à forcer l'actualisation des javascript et
  # des CSS. Pour forcer une une version version, on peut utiliser la commande
  # > icare next_version
  def version
    @version ||= begin
      if File.exists?(version_path)
        File.read(version_path)
      else
        '0.0.1'
      end
    end
  end #/ version

  # Pour incrémenter la version courante
  # +ajout+ {Symbol}
  #   :patch    Augmente de 1 le numéro de patch
  #   :minor    Augmente le numéro mineur et met le patch à 0
  #   :major    Augmente le numéro majeur et met les autres à 0
  #
  def incremente_version(what)
    dv = version.split('.').collect{|i|i.to_i}
    case what
    when :path
      dv[2] += 1
    when :minor
      dv[1] += 1
      dv[2]  = 0
    when :major
      dv[0] += 1
      dv[1]  = 0
      dv[2]  = 0
    end
    @version = dv.join('.')
    File.open(version_path,'wb') { |f| f.write(@version) }
  end #/ incremente_versio

  def version_path
    @version_path ||= File.join(APP_FOLDER,'VERSION')
  end #/ version_path
  
end #/ << self
end #/App
