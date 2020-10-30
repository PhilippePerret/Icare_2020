# encoding: UTF-8
# frozen_string_literal: true
class Cronjob
class << self

  # = main =
  #
  # Méthode principale
  def run
    init
    run_jobs
    finish
  end #/ run

  # Initialise le travail
  # ---------------------
  # DO    Ecrit notamment les variables générales (temps, noop, etc.)
  #
  def init
    formated_current_time = current_time.strftime('%d %m %Y - %H:%M')
    # Informations préliminaires (servent notamment aux tests)
    puts "CRON-CURRENT-TIME: #{formated_current_time}"
    puts "CRON-NOOP: #{noop?.inspect} #{'(SIMULATION)' if noop?}"
    puts "CRON-START: #{Time.now}"
    Report << "***** START OPÉRATIONS #{formated_current_time} *****"
  end #/ init

  def run_jobs
    Dir["#{CRON_FOLDER}/JOBS/*.rb"].each do |jpath|
      new(jpath).run
    end
  end #/ run_jobs

  # Fin du travail du cronjob
  # -------------------------
  # DO    M'envoie le rapport de cron si nécessaire.
  #
  def finish
    puts "CRON-FIN: #{Time.now}"
    Report.send
  end #/ finish

  def bind; binding() end

  # OUT   {Time} Le temps courant
  #       En temps normal (non test), c'est vraiment le temps courant
  #       En mode test, on peut appeler la commande avec CURRENT_TIME='...'
  #       où le temps fourni a le format 'AAAA/MM/JJ/HH/MM/SS'
  def current_time
    @current_time ||= begin
      if ENV['CRON_CURRENT_TIME']
        Time.new(*(ENV['CRON_CURRENT_TIME'].split('/').collect { |i| i.to_i }))
      else
        Time.now
      end
    end
  end #/ current_time

  def noop?
    (@is_noop ||= begin
      ["true", "1"].include?(ENV['NOOP']) ? :true : :false
    end) == :true
  end #/ noop?

end # /<< self
end #/Cronjob
