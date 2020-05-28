# encoding: UTF-8
class Route

  REDIRECTIONS = {
    # - SIMPLE ICARIEN -
    0 => {hname: 'Accueil du site',         route: :home},
    1 => {hname: 'Bureau de travail',       route: :bureau},
    2 => {hname: 'Profil',                  route: :profil},
    3 => {hname: 'Dernière page consultée', route: :last_page},
    # - ADMINISTRATEUR -
    7 => {hname: 'Aperçu Icariens', route: 'admin/overview', admin: true},
    8 => {hname: 'Console', route: 'admin/console', admin: true},
    9 => {hname: 'Tableau de bord', route: 'admin/dashboard', admin: true}
  }

class << self

  # L'instance Route courante
  def current
    # @current ||= new(CGI.new('html4').params['route_init'][1])
    @current ||= new(cgi.params['route_init'][1])
  end

  # Retourne la dernière route, hors route courante
  # C'est utile par exemple lorsqu'on se déconnecte (avec la route user/logout)
  # pour obtenir la vraie route précédente
  def last
    session['last_route']
  end
  # Pour définir la dernière route
  def last= route
    session['last_route'] = route
  end

  def redirect_to road, options = nil
    log("-> Route::redirect_to(#{road})")
    Errorer.sessionnize
    Noticer.sessionnize
    puts cgi.header('status'=>'REDIRECT', 'location' => "#{App.url}/#{road}")
  end

end #/<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :route, :route_init
def initialize route
  @route_init = route
end

def to_s
  route
end

def route
  @route ||= begin
    # debug "-> recherche de la route"
    # debug "   URL.param(:route) = #{URL.param(:route).inspect}"
    # debug "   route_init        = #{route_init.inspect}"
    if URL.param(:route)
      URL.param(:route)
    elsif route_init.nil? || route_init == ''
      'home'
    else
      route_init
    end
  end
end

def home?
  route == 'home'
end

end #/Route
