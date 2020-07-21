# encoding: UTF-8
=begin
  Méthode pour "nourrir" la base de données locale (icare_test)
=end

MESSAGES = {
  question_read: 'Que voulez-vous lire sur le site distant ?'
}

DATA_WHAT_READ = [
  {name:'Journal (log)'.freeze, value: :log},
  {name:'Traceur'.freeze, value: :tracer},
  {name:'Dossier…'.freeze, value: :folder},
  {name:'Fichier…'.freeze, value: :file}
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


  def read_it(path)
    cmd = <<-CMD.strip.freeze
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
