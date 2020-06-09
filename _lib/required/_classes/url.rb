# encoding: UTF-8
=begin
  Class URL
  pour le traitement de l'URL, à commencer par les paramètres
=end

MAIN_LINKS = {
  home:     '<a href="home">ATELIER ICARE</a>'.freeze,
  overview: '<a href="overview"><span class="emoji">👀</span> <span>en savoir plus</span></a>'.freeze,
  signup:   '<a id="signup-btn" href="user/signup" class="main">📋 s’inscrire</a>'.freeze,
  login:    '<a href="user/login">🔓 s’identifier</a>'.freeze,
  logout:   '<a class="btn-logout" href="user/logout">🔒 se déconnecter</a>'.freeze,
  # BUREAU
  bureau:   '<a href="bureau/home">bureau</a>'.freeze,
  work:     '<a href="bureau/travail">Travail courant</a>'.freeze,
  notices:  '<a href="bureau/notifications">Notifications%{non_vus}</a>'.freeze,
  admin_notifications:  '<a href="admin/notifications">Notifications%{non_vus}</a>'.freeze,
  frigo:    '<a href="bureau/frigo">Porte de frigo%{non_vus}'.freeze,
  # DIVERS
  aide:     '<a href="aide/home"><span class="emoji">🚨</span>aide</a>'.freeze,
  contact:  '<a href="contact"><span class="emoji">📧</span> contact</a>'.freeze,
  plan:     '<a href="plan" class="btn small"><span class="emoji">📍</span>PLAN</a>'.freeze,
  qdd:      '<a href="qdd/home"><span class="emoji">🗄</span>️Quai Des Docs</a>'.freeze
}


class URL
  class << self
    def current
      @current ||= new()
    end

    def cgi
      @cgi ||= CGI.new('html4')
    end

    # Initialisation
    #
    # Appelée juste avant html.out, au tout départ du script index.rb car
    # sinon les paramètres "disparaissent", je n'ai pas trouvé pourquoi,
    # mais ça tient certainement à CGI.new et à la session.
    def init
      current.params
    end

    # Raccourci
    def param(key, value = nil)
      current.param(key, value)
    end
  end #/<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# Obtenir ou redéfinir un paramètre
# Note pour affecter la valeur nil, il faut utiliser :null
def param(key, value = nil)
  if value.nil?
    params[key]
  else
    value = nil if value == :null
    params[key] = value
  end
end

def params
  @params ||= begin
    debug "Tous les paramètres: #{cgi.params.inspect}"
    h = {}
    cgi.params.each do |key, value|
      value = value[0] if value.count == 1
      value = nil if value == ''
      h.merge!(key.to_sym => value)
    end;h
  end
end
end #/URL
