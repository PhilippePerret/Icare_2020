# encoding: UTF-8
# frozen_string_literal: true
class Cronjob
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :path
def initialize(path)
  @path = path
  require(@path)
end #/ initialize

# DO    Joue le job
def run
  start_mark_report || return
  finish if self.send(method_name)
rescue Exception => e
  Logger << "# ERREUR [#{method_name}] : #{e.message}\n#{e.backtrace.join("\n")}"
ensure
  Report.prefix = ''
end #/ run

# Juste pour la ligne de rapport, pour préciser si le job doit être
# joué ou non.
def start_mark_report
  if not runnable?
    Report << "NOT TIME FOR [#{method_name}]"
    return
  else
    Report << "RUN [#{method_name}] (#{name})"
  end
  Report.prefix = " " * 4
  return true
end #/ start_mark_report

def finish
  Report << "END [#{method_name}]"
end #/ finish

# OUT   True s'il faut jouer le job.
#
# Le job n'est pas à jouer si :
#   - Sa fréquence ne correspond pas à l'heure/jour courant
#   - Il a déjà été joué (est-ce qu'on tient vraiment compte de ça ?)
def runnable?
  return good_hour? && good_day?
end #/ runnable?

def name; @name ||= data[:name] end
def frequency; @frequency ||= data[:frequency] end

def cur_time
  @cur_time ||= self.class.current_time
end #/ cur_time

def good_day?
  return true if not frequency.key?(:day)
  cur_time.wday == frequency[:day]
end #/ good_day?

def good_hour?
  return true if not frequency.key?(:hour)
  cur_time.hour == frequency[:hour]
end #/ good_hour?

# OUT   Le nom de la méthode
#       Correspond à l'affixe du fichier job
def method_name
  @method_name ||= File.basename(path,File.extname(path)).to_sym
end #/ method_name

def noop?; self.class.noop? end #/ noop?

def bind; binding() end

end #/Cronjob
