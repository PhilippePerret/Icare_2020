# encoding: UTF-8
=begin
  Class URL
  pour le traitement de l'URL, à commencer par les paramètres
=end

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
