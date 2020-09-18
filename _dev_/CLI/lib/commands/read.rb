# encoding: UTF-8
# frozen_string_literal: true
=begin
  Méthode pour "nourrir" la base de données locale (icare_test)
=end

MESSAGES = {
  question_read: 'Que voulez-vous lire sur le site distant ?'
}

DATA_WHAT_READ = [
  {name:'Journal (log)', value: :log},
  {name:'Traceur', value: :tracer},
  {name:'Manuel (pdf)', value: :manuel_dev},
  {name:'Manuel (md)', value: :manuel_dev_md},
  {name:'Dossier…', value: :folder},
  {name:'Fichier…', value: :file}
]

SSH_SERVER = 'icare@ssh-icare.alwaysdata.net'


class IcareCLI
class << self
  def proceed_read
    what = params[1]
    unless self.respond_to?("read_#{what}".to_sym)
      what = Q.select(MESSAGES[:question_read], required: true) do |q|
        q.choices DATA_WHAT_READ
        q.per_page DATA_WHAT_READ.count
      end
    end
    self.send("read_#{what}".to_sym)
  end #/ proceed_feed

  # Lire le fichier journal
  def read_log
    path = './www/tmp/logs/journal.log'
    path = './www/tmp/logs/journal2020.log'
    read_it(path)
  end #/ read_actualites
  def read_tracer
    path = './www/tmp/logs/tracer.log'
    read_it(path)
  end #/ read_tracer
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
  def read_manuel_dev
    `open "#{File.join(DEV_FOLDER,'Manuel','Manuel_developper.pdf')}"`
  end #/ manuel_dev
  # Pour ouvrir la version modifiable du mode d'emploi
  def read_manuel_dev_md
    `open -a Typora "#{File.join(DEV_FOLDER,'Manuel','Manuel_developper.md')}"`
  end #/ manuel_dev_md

  def read_it(path)
    cmd = <<-CMD.strip
    ssh icare@ssh-icare.alwaysdata.net ruby <<SSH
if !File.exists?('#{path}')
  puts "L'élément '#{path}' est introuvable…"
elsif File.directory?('#{path}')
  puts Dir['#{path}/*'].join("\n")
else
  puts File.open('#{path}','rb'){|f|f.read}
end
    SSH
    CMD
    puts `#{cmd}`
  end #/ read_it
end # /<< self
end #/IcareCLI
