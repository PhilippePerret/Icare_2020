# encoding: UTF-8
# frozen_string_literal: true
=begin
  Méthode pour "nourrir" la base de données locale (icare_test)
=end

MESSAGES.merge!({
  question_read: 'Que voulez-vous lire sur le site distant ?'
})

DATA_WHAT_READ = [
  {name:'Journal [log]', value: :log},
  {name:'Journal [cronjob]', value: :cronjob},
  {name:'Traceur [tracer]', value: :tracer},
  {name:'Manuel [manuel_pdf]', value: :manuel_pdf},
  {name:'Manuel [manuel_md]', value: :manuel_md},
  {name:'Dossier… [folder]', value: :folder},
  {name:'Fichier… [file]', value: :file}
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
    # path = './www/tmp/logs/journal.log'
    path = './www/tmp/logs/journal2020.log'
    read_it(path)
  end #/ read_log
  def read_cronjob
    path = './www/cronjob/journal.log'
    # path = './www/tmp/logs/cronjob.log'
    read_it(path)
  end #/ read_cronjob
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
  def read_manuel_pdf
    `open "#{File.join(DEV_FOLDER,'Manuel','Manuel_developper.pdf')}"`
  end #/ manuel_pdf
  # Pour ouvrir la version modifiable du mode d'emploi
  def read_manuel_md
    `open -a Typora "#{File.join(DEV_FOLDER,'Manuel','Manuel_developper.md')}"`
  end #/ manuel_md

  # Pour lire le fichier distant voulu
  # Avec l'option -d/--delete, le fichier est ramené localement
  # et détruit en online.
  def read_it(path)
    and_delete_id = options[:delete]
    cmd = <<-CMD.strip
    ssh icare@ssh-icare.alwaysdata.net ruby << SSH
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
end # /<< self
end #/IcareCLI
