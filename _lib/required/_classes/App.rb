# encoding: UTF-8
class App

URL_ONLINE  = 'www.atelier-icare.net'.freeze
URL_OFFLINE = 'localhost/AlwaysData/Icare_2020'.freeze
FULL_URL_ONLINE   = "http://#{URL_ONLINE}".freeze
FULL_URL_OFFLINE  = "http://#{URL_OFFLINE}".freeze

class << self

  # Main method
  def run
    log("-> App::run")
    self.init
    html.build_page
    html.out
    self.finish
    log("<- App::run")
  end

  # Initialisation de l'atelier
  def init
    log("-> App::init")
    Session.init
    Errorer.desessionnize
    Noticer.desessionnize
    User.init
  end

  # Pour finir
  def finish
    log("-> App::finish".freeze)
    Route.last = route.to_s.dup
    Session.finish
    log("<- App::finish#{RC2}".freeze)
  rescue Exception => e
    log("ERREUR DANS finish: #{e.message}")
    log(e)
  end

  # L'url courante, en fonction du fait qu'on est offline ou online
  def url
    OFFLINE ? FULL_URL_OFFLINE : FULL_URL_ONLINE
  end

end #/ << self
end #/App
