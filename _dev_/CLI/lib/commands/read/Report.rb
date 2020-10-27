# encoding: UTF-8
# frozen_string_literal: true
=begin
  Pour l'affichage simplifié des rapports de cron
=end
require 'json'

Report = Struct.new(:name,:lines) do
DEL_DATA = '°°°°°'

# DO   Écrit le rapport
def out
  puts "\n--- Rapport du #{formate_date(date).jaune} (#{name})---"
  puts parse
end #/ out

def parse
  lines.split("\n").collect do |line|
    line = line.gsub(/§\$\%\°£\&/, DEL_DATA) # ancien délimiteur
    txt, data = line.split(DEL_DATA)
    unless data.nil?
      data = JSON.parse(data)
      if data.key?('time')
        time = formate_date(data['time'], {hour:true, mois: :court})
      else
        time = ""
      end
    else
      time = ""
    end
    time.ljust(24) + txt + RC
  end.join
end #/ parse

# Date du rapport
def date
  @data ||= begin
    affixe, ext = name.split('.')
    p = affixe.split('-').collect{|i|i.to_i}
    p.shift
    Time.new(*p)
  end
end #/ date

end

# Commande pour relever tous les rapports online et les rappatrier
SSH_COMMAND_CRON_REPORTS = <<-SSH
ssh #{SSH_ICARE_SERVER} ruby << RUBY
reports = {}
Dir["./www/cronjob/data/report-*.*"].each do |rpath|
reports.merge!(File.basename(rpath) => File.read(rpath).force_encoding('UTF-8'))
end
puts Marshal.dump(reports)
RUBY
SSH
