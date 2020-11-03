# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module pour travailler avec le cron distant
=end
require_relative './cron/constants'
require_relative './cron/methods'

class IcareCLI
class << self

# = main =
def proceed_cron
  clear unless tests?
  what = params[1] || begin
    Q.select("Commande à jouer : ", required: true) do |q|
      q.choices formate_choices('cron', DATA_COMMANDES)
      q.per_page DATA_COMMANDES.count
    end
  end
  case what
  when 'log', 'journal'
    cron_load_and_display_main_log
  when 'run'
    run_distant_cron
  when 'report'
    display_today_report
  when 'remove-log'
    remove_distant_journal
  when 'add'
    require_relative './cron/notification_ponctuelle'
    add_notification_ponctuelle
  end
end #/ degel

MODES_NOOP = [
  {name: "NOOP (aucune opération vraiment jouée)", value: true},
  {name: "OP (les opérations seront vraiment jouées)", value: false},
  {name: "Renoncer", value: :cancel}
]
HEURES_CHOICES = [
  {name: "5 h (produit le test)", value: 5},
  {name: "3 h (envoi des activités, etc.)", value: 3},
  {name: "1 h (nettoyage mails, etc.)", value: 1},
  {name: "2 h (nettoyage des dossiers, etc.)", value: 2},
  {name: "Renoncer", value: :cancel}
]

# Pour jour le cron distant (et afficher le résultat)
def run_distant_cron
  puts "#{RC*2}=== ACTIVATION DU CRONJOB DISTANT ===".bleu
  mode_noop = Q.select("Quel mode choisir ?") do |q|
    q.choices MODES_NOOP
    q.per_page MODES_NOOP.count
  end
  mode_noop != :cancel || return

  heure = Q.select("À quelle heure simuler l'appel aujourd'hui ?") do |q|
    q.choices HEURES_CHOICES
    q.per_page HEURES_CHOICES.count
  end
  heure != :cancel || return

  now = Time.now

  cmd = []
  cmd << "ssh #{SSH_ICARE_SERVER}"
  cmd << "ONLINE=true"
  cmd << "NOOP=true" if mode_noop
  cmd << "CRON_CURRENT_TIME='#{now.year}/#{now.month}/#{now.day}/#{heure}/18'"
  cmd << "ruby"
  cmd << "./www/cronjob2/runner.rb"
  cmd = cmd.join(' ')
  puts "Commande finale : #{cmd}"
  res = system(cmd)
  puts "Résultat obtenu : #{res.inspect}"
  # RAPATRIER et afficher LE LOG
  cron_load_and_display_main_log
end #/ run_distant_cron

# Pour afficher le rapport du jour
def display_today_report
  display_distant_file("RAPPORT DU #{todayJJMMAAAA}", today_report_path)
end #/ display_today_report


# Pour détruire le journal distant
def remove_distant_journal
  puts "#{RC*2}=== Destruction du journal distant ===".bleu
  cmd = "File.delete('#{log_path}') if File.exists?('#{log_path}')"
  run_ruby_command(cmd)
end #/ remove_distant_journal


def today_report_path
  @today_report_path ||= report_path_of(Time.now)
end #/ path

def todayJJMMAAAA
  @todayJJMMAAAA ||= Time.now.strftime('%d %m %Y')
end #/ today

private

  def display_distant_file(designation, path)
    titre = "=========== LECTURE DU #{designation.upcase} ==========="
    puts "#{RC*2}#{titre}".bleu
    puts read_distant_file(path)
    puts ("="*titre.length).bleu + RC*2
  end #/ display_distant_file

  def read_distant_file(path)
    cmd = <<-CMD.strip
require '/home/icare/www/cronjob/_lib/_required/extensions/String_CLI'
if !File.exists?('#{path}')
  puts "L'élément '#{path}' est introuvable… Impossible de lire son contenu.".rouge
else
  puts File.open('#{path}','rb'){|f|f.read}
end
    CMD
    return run_ruby_command(cmd)
  end #/ read_file

  def report_path_of(time)
    "./www/cronjob/data/report-#{time.strftime('%Y-%m-%d')}.txt"
  end #/ report_path_of

  # Joue la commande ruby +cmd+ sur le site distant
  # Et retourne le résultat
  def run_ruby_command(cmd)
    cmd = <<-CMD.strip
ssh icare@ssh-icare.alwaysdata.net ruby << SSH
#{cmd}
SSH
    CMD
    return system(cmd)
  end #/ run_ruby_command
end # /<< self
end #/IcareCLI
