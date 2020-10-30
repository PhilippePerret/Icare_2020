# encoding: UTF-8
# frozen_string_literal: true
CRONJOB_FOLDER = File.expand_path(File.join('.','cronjob2'))
RUNNER_PATH = File.join(CRONJOB_FOLDER, 'runner.rb')
MAIN_LOG_PATH = File.join('.','tmp','logs','cronjob.log')
CRON_REPORT_PATH = File.join(CRONJOB_FOLDER,'tmp', "report-#{Time.now.strftime('%Y-%m-%d')}.txt")

# Pour jouer le cron job à une certaine heure, ajouter
# params[:time] = 'AAAA/MM/JJ/HH/MM[/SS]'
# Pour ne pas exécuter les opérations mais seulement les voir : params[:noop] = true
def run_cronjob(params = nil)
  params ||= {}
  cmd = "ONLINE=false ruby #{RUNNER_PATH}"
  cmd = "CRON_CURRENT_TIME='#{params[:time]}' #{cmd}" if params.key?(:time)
  cmd = "NOOP=true #{cmd}" if params[:noop]
  # puts "Command cronjob: #{cmd.inspect}"
  res = `#{cmd}`
  if res.include?("FATAL ERROR:")
    raise res
  end
  return res
end #/ run_cron

def remove_main_log
  File.delete(MAIN_LOG_PATH) if File.exists?(MAIN_LOG_PATH)
end #/ remove_main_log

def read_main_log
  File.read(MAIN_LOG_PATH) if File.exists?(MAIN_LOG_PATH)
end #/ read_main_log

# IN    {String}  Le temps, sous la forme d'un "AAAA/MM/DD/H/M"
# OUT   {String}  Le contenu du rapport de cron du temps +time+
#                 Nil s'il n'existe pas.
def cron_report(time)
  cpath = cron_report_path(time)
  File.read(cpath) if File.exists?(cpath)
end #/ cron_report

def cron_report_path(time)
  time = realtime(time)
  File.join(CRONJOB_FOLDER,'tmp', "report-#{time.strftime('%Y-%m-%d')}.txt")
end #/ cron_report_path

def remove_report(time = nil)
  path =  time.nil? ? CRON_REPORT_PATH : cron_report_path(time)
  # On procède à la suppression
  File.delete(path) if File.exists?(path)
  # On retourne le path dont le test peut avoir besoin
  return path
end #/ remove_report

def remove_all_reports
  Dir["#{CRONJOB_FOLDER}/tmp/report-*.txt"].each{|fp|File.delete(fp)}
end #/ remove_all_reports

# IN    {String}  Un temps sous la forme "AAAA/MM/DD/HH/MM"
# OUT   {Time}    Le temps correspondant à l'entrée
def realtime(time)
  Time.new(*(time.split('/').collect { |i| i.to_i })) if time.is_a?(String)
end #/ real_time
