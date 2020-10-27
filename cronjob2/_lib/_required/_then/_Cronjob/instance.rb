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
  if self.send(method_name)
    finish
  end
rescue Exception => e
  Logger << "# ERREUR [#{method_name}] : #{e.message}\n#{e.backtrace.join("\n")}"
end #/ run

def finish
  Logger << "     FIN JOB [#{method_name}] (#{name})"
end #/ finish

# OUT   True s'il faut jouer le job.
# DO    Quand le job n'est pas à jouer, on l'indique sur l'historique
#
# Le job n'est pas aà jouer si :
#   - Sa fréquence ne correspond pas à l'heure/jour courant
#   - Il a déjà été joué (est-ce qu'on tient vraiment compte de ça ?)
def runnable?
  runit = good_hour? && good_day?
  if runit
    Logger << "---> RUN JOB [#{method_name}] (#{name})"
  else
    Logger << "Le job “#{name}” n'est pas à jouer [#{method_name}]"
  end
  return runit
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


end #/Cronjob
