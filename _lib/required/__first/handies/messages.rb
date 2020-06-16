# encoding: UTF-8
=begin

  Méthodes pratiques (raccourcis) pour les messages

  Note : les méthodes/classes principales sont définies dans le module
  ./required/_first/messagerie.rb

=end

# Envoi une erreur produite à l'administration
def send_error msg, data = nil
  msg = "<p style='color:red;font-size:1.1em;'>#{msg}</p>"
  unless data.nil?
    msg << '<pre><code>'
    msg << data.collect { |k, v| msg << "#{k} : #{v}"}.join(RC)
    msg << '</code></pre>'
  end
  # Pour situer l'appel de la méthode
  msg << '<pre><code>BACKTRACE'
  msg << Kernel.caller[0..2].join(RC)
  msg << '</code></pre>'
  dmail = {subject: '🧨 Problème sur l’atelier Icare'.freeze, message: msg}
end #/ send_error

def debug msg
  Debugger.add(msg)
end

def erreur(msg)
  Errorer.add(msg)
  return false
end
alias :error :erreur

def notice(msg)
  Noticer.add(msg)
end
alias :message :notice # def message <- pour le retrouver

def log(msg)
  Logger.add(msg)
end
