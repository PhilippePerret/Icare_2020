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
    # Informations préliminaires (servent notamment aux tests)
    puts "CRON-CURRENT-TIME: #{current_time.strftime('%d %m %Y - %H:%M')}"
    puts "CRON-NOOP: #{noop?.inspect} #{'(SIMULATION)' if noop?}"
    puts "CRON-START: #{Time.now}"
  end #/ init

  def run_jobs
    Dir["#{CRON_FOLDER}/_lib/JOBS/*.rb"].each do |jpath|
      new(jpath).run
    end
  end #/ run_jobs

  # Fin du travail du cronjob
  # -------------------------
  # DO    M'envoie le rapport de cron si nécessaire.
  #
  def finish
    puts "CRON-FIN: #{Time.now}"
  end #/ finish

  # OUT   {Time} Le temps courant
  #       En temps normal (non test), c'est vraiment le temps courant
  #       En mode test, on peut appeler la commande avec CURRENT_TIME='...'
  #       où le temps fourni a le format 'AAAA/MM/JJ/HH/MM/SS'
  def current_time
    @current_time ||= begin
      if TEST_MODE && ENV['CURRENT_TIME']
        Time.new(*(ENV['CURRENT_TIME'].split('/').collect { |i| i.to_i }))
      else
        Time.now
      end
    end
  end #/ current_time

  def noop?
    (@is_noop ||= begin
      ENV['NOOP'] == "true" ? :true : :false
    end) == :true
  end #/ noop?

end # /<< self
end #/Cronjob
