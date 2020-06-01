# encoding: UTF-8
class App
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
    log("-> App::finish")
    Route.last = route.to_s
    Session.finish
  end

  # L'url courante, en fonction du fait qu'on est offline ou online
  def url
    OFFLINE ? 'http://localhost/AlwaysData/Icare_2020'.freeze : 'http://www.atelier-icare.net'.freeze
  end

end #/ << self
end #/App
