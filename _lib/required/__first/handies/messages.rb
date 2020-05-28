# encoding: UTF-8
=begin

  Méthodes pratiques (raccourcis) pour les messages

  Note : les méthodes/classes principales sont définies dans le module
  ./required/_first/messagerie.rb

=end
def debug msg
  Debugger.add(msg)
end

def erreur(msg)
  Errorer.add(msg)
end
alias :error :erreur

def notice(msg)
  Noticer.add(msg)
end
alias :message :notice

def log(msg)
  Logger.add(msg)
end
