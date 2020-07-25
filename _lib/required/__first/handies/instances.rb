# encoding: UTF-8
=begin
  Méthodes facilités
  Attention aux collisions de nom, il ne faut absolument pas utiliser
  ces noms dans les méthodes, quelles qu'elles soient.
=end

def user
  User.current
end

def phil
  @phil ||= User.get(1)
end #/ phil

def param key, value = nil
  key = key.to_sym if key.is_a?(String)
  URL.param(key, value)
end

def html
  HTML.current
end

def route
  Route.current
end

def session
  Session.current
end

def cgi
  URL.cgi
end
