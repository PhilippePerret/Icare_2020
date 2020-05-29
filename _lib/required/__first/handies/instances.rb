# encoding: UTF-8
=begin
  Méthodes facilités
  Attention aux collisions de nom, il ne faut absolument pas utiliser
  ces noms dans les méthodes, quelles qu'elles soient.
=end

def user
  User.current
end

def param key
  URL.param(key)
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
