# encoding: UTF-8
# frozen_string_literal: true
=begin
  Méthode pour "nourrir" la base de données locale (icare_test)
=end

MESSAGES.merge!({
  question_read: 'Que voulez-vous lire sur le site distant ?'
})

DATA_WHAT_READ = [
  {name:'Journal', value: :log},
  {name:'Journal', value: :cronjob},
  {name:'Rapports Cronjob', value: :report},
  {name:'Traceur', value: :tracer},
  {name:'Manuel', value: :manuel},
  {name:'Dossier…', value: :folder},
  {name:'Fichier…', value: :file},
  {name:'Règlement concours', value: :reglement_concours},
  {name:'Renoncer', value: :cancel}
]

SSH_SERVER = 'icare@ssh-icare.alwaysdata.net'


class IcareCLI
class << self
  def proceed_read
    what = params[1]
    unless self.respond_to?("read_#{what}".to_sym)
      what = Q.select(MESSAGES[:question_read], required: true) do |q|
        q.choices DATA_WHAT_READ.collect{|d|d.merge(name:"#{d[:name]} [#{d[:value]}]")}
        q.per_page DATA_WHAT_READ.count
      end
    end
    return if what == :cancel
    self.send("read_#{what}".to_sym)
  end #/ proceed_feed

  # Lire le fichier journal
  def read_log
    # path = './www/tmp/logs/journal.log'
    path = './www/tmp/logs/journal2020.log'
    read_it(path)
  end #/ read_log
  def read_cronjob
    path = './www/cronjob/journal.log'
    read_it(path)
  end #/ read_cronjob
  # Pour lire tous les rapports de cronjob
  def read_report
    require_relative './read/Report'
    res = `#{SSH_COMMAND_CRON_REPORTS}`
    res = Marshal.load(res)
    res.each do |nreport, dreport|
      Report.new(nreport, dreport).out
    end
  end #/ read_report
  alias :read_reports :read_report

  def read_tracer
    path = './www/tmp/logs/tracer.log'
    read_it(path)
  end #/ read_tracer
  def read_reglement_concours
    `open "#{File.join(PUBLIC_FOLDER,"Concours_ICARE_#{annee_concours}")}"`
  end #/ read_reglement_concours
  def read_file
    fichier = params[2] ||= Q.ask('Fichier (depuis racine)')
    path = "./www/#{fichier}"
    read_it(path)
  end #/ read_file
  def read_folder
    dossier = params[2] ||= Q.ask('Dossier (depuis racine)')
    path = "./www/#{dossier}"
    read_it(path)
  end #/ read_folder
  # Pour ouvrir le manuel développeur
  def read_manuel
    `open "#{File.join(DEV_FOLDER,'Manuel','Manuel_developper.pdf')}"`
  end #/ manuel_pdf

  # Pour lire le fichier distant voulu
  # Avec l'option -d/--delete, le fichier est ramené localement
  # et détruit en online.
  def read_it(path)
    and_delete_id = options[:delete]
    cmd = <<-CMD.strip
    ssh #{SSH_ICARE_SERVER} ruby << SSH
if !File.exists?('#{path}')
  puts "L'élément '#{path}' est introuvable…"
elsif File.directory?('#{path}')
  puts Dir['#{path}/*'].join("\n")
else
  puts File.open('#{path}','rb'){|f|f.read}
  #{"File.delete('#{path}')" if options[:delete]}
end
SSH
    CMD
    puts "#{RC*2}= Lecture du fichier… ="
    unless and_delete_id
      puts "(ajouter l'option #{'-d/--delete'.jaune}) pour charger le fichier localement et le détruire)"
    end
    content = `#{cmd}`
    path_copie = File.join('.', File.basename(path))
    if and_delete_id
      File.open(path_copie,'wb'){|f|f.write content}
    end
    puts content
    puts "= / fin lecture fichier =#{RC*2}"
    puts "= Le fichier a été enregistré dans #{path_copie}" if and_delete_id
  end #/ read_it

private

  def annee_concours
    @annee_concours ||= Time.now.month < 3 ? Time.now.year : Time.now.year + 1
  end #/ annee_concours
end # /<< self
end #/IcareCLI
