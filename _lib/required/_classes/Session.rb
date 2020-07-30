# encoding: UTF-8
=begin
  Class Session
  Pour la gestion des sessions
=end
require 'cgi'
require 'cgi/session'
class Session
class << self
  attr_accessor :current
  def init
    # Pour prévenir des attaques malicieuses
    begin
        sess = CGI::Session.new(cgi, 'new_session' => false)
        sess.delete
    rescue ArgumentError  # if no old session
    end
    # Et on réveille la nouvelle session
    self.current = new()
  end

  def finish
    self.current.session.close
  end
end #/<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

def id
  @id ||= self.session.session_id
end

def []= key, value
  self.session[key] = value
end
alias :set :[]=

def [] key
  self.session[key]
end

def delete key
  self.session[key] = nil
end
alias :remove :delete

def session
  @session ||= begin
    CGI::Session::new(
      cgi,
      'session_key'       => 'SESSIONATELIERICARE',
      'session_expires'   => Time.now + 60 * 60,
      'prefix'            => 'icaress'
    )
  end
end

# def delete_last_session
#   sess = CGI::Session.new(cgi, 'new_session' => false)
#   sess.delete
# rescue ArgumentError
#   # S'il n'y a pas encore de session
# end

end #/Session
