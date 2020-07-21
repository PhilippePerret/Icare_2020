# encoding: UTF-8
class Route
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
    trace({id:"REDIRECTION",message:"--> #{road}", data:{options:options}})
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
def initialize init_route
  @route_init = init_route
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
