# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module pour travailler avec le cron distant
=end
require_relative './cron/constants'
class IcareCLI
class << self

# = main =
def proceed_cron
  clear
  what = params[1] || begin
    Q.select("Commande à jouer : ", required: true) do |q|
      q.choices DATA_COMMANDES
      q.per_page DATA_COMMANDES.count
    end
  end
  case what
  when 'log', 'journal'
    read_journal
  when 'run'
    run_distant_cron
  when 'report'
    display_today_report
  when 'remove-log'
    remove_distant_journal
  end
end #/ degel

# Pour jour le cron distant (et afficher le résultat)
def run_distant_cron
  puts "#{RC*2}=== ACTIVATION DU CRONJOB DISTANT ===".bleu
  cmd = "ssh icare@ssh-icare.alwaysdata.net ruby ./www/cronjob/cronjob.rb"
  res = system(cmd)
  puts "Résultat obtenu : #{res.inspect}"
  display_today_report
end #/ run_distant_cron

# Pour afficher le rapport du jour
def display_today_report
  display_distant_file("RAPPORT DU #{todayJJMMAAAA}", today_report_path)
end #/ display_today_report

# Pour lire et afficher le journal.log distant
def read_journal
  display_distant_file("JOURNAL CRON", log_path)
end #read_journal

# Pour détruire le journal distant
def remove_distant_journal
  puts "#{RC*2}=== Destruction du journal distant ===".bleu
  cmd = "File.delete('#{log_path}') if File.exists?('#{log_path}')"
  run_ruby_command(cmd)
end #/ remove_distant_journal

def log_path
  @log_path ||= './www/cronjob/journal.log'
end #/ path

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
