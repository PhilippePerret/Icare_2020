# encoding: UTF-8
=begin
  Méthodes d'instance d'un travail
=end
class CJWork
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
def initialize data
  data.each {|k,v|instance_variable_set("@#{k}",v)}
end #/ initialize

# Méthode principale qui joue le travail (mais seulement s'il n'a
# pas encore été joué)
def run
  # On exécute le job
  eval(exec)
  # On mémorise sa date de dernière exécution
  @last_run_time = NOW_S
end #/ run

# La méthode retourne true si le job courant doit être
# joué.
def time_has_come?
  if ran_today?
    puts "#{id} a déjà été joué aujourd'hui"
    return false
  end
  if at && NOW.hour != at
    puts "L'heure n'est pas venue pour #{id} : attendu:#{at} / actuelle:#{NOW.hour}"
    return false
  end
  return true
end #/ time_has_come?

# La date de dernière exécution
def last_run_time
  @last_run_time ||= 0
end #/ last_run_time
alias :lrt :last_run_time

# La méthode retourne TRUE si le job a été joué aujourd'hui.
# Quel que soit le job, il ne peut pas être joué deux fois par
# jour.
def ran_today?
  last_run_time > TODAY_S
end #/ ran_today?


# ---------------------------------------------------------------------
#   NON VOLATILE PROPERTIES
# ---------------------------------------------------------------------
def id ; @id ||= data[:id] end
def every ; @every ||= data[:every] end
def at ; @at ||= data[:at] end
def exec ; @exec ||= data[:exec] end

end #/CJWork
