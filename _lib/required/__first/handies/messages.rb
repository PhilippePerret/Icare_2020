# encoding: UTF-8
=begin

  Méthodes pratiques (raccourcis) pour les messages

  Note : les méthodes/classes principales sont définies dans le module
  ./required/_first/messagerie.rb

=end

# Envoi une erreur produite à l'administration
def send_error msg, data = nil
  require_module('mail')
  if msg.is_a?(String)
    # <= C'est un simple message d'erreur
    # => Il faut faire un backtrace pour le remonter
    backtrace = Kernel.caller[0..4]
  elsif msg.respond_to?(:message)
    # <= C'est une erreur directement envoyée
    # => Il faut en construire le texte
    msg = msg.message
    backtrace = msg.backtrace
  end

  # On trace cette erreur
  trace(message:msg, backtrace:backtrace, data:data) rescue nil

  msg = "<div style='color:red;font-size:1.1em;'>ERREUR : #{msg}</div>"
  msg << "<div style='color:red;'>#{backtrace.join(BR)}</div>".freeze

  # On ajoute les éventuelles données fournies
  unless data.nil?
    msg << "<pre><code>#{RC2}"
    msg << data.collect do |k, v|
      v = v.inspect unless k == :backtrace
      "#{k} : #{v}"
    end.join(RC)
    msg << '</code></pre>'
  end

  # On peut envoyer l'erreur
  Mail.send({
    subject: '🧨 Problème sur l’atelier Icare'.freeze,
    message: msg
  }) rescue nil
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
