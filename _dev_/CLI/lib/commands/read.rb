# encoding: UTF-8
=begin
  Méthode pour "nourrir" la base de données locale (icare_test)
=end

MESSAGES = {
  question_read: 'Que voulez-vous lire sur le site distant ?'
}

DATA_WHAT_READ = [
  {name:'Journal (log)'.freeze, value: :log},
  {name:'Traceur'.freeze, value: :tracer}
]

SSH_SERVER = 'icare@ssh-icare.alwaysdata.net'


class IcareCLI
class << self
  def proceed_read
    what = params[1]
    unless self.respond_to?("feed_#{what}".to_sym)
      what = Q.select(MESSAGES[:question_read], required: true) do |q|
        q.choices DATA_WHAT_READ
        q.per_page DATA_WHAT_READ.count
      end
    end
    self.send("feed_#{what}".to_sym)
  end #/ proceed_feed

  # Lire le fichier journal
  def feed_log
    path = './www/tmp/logs/journal.log'
    read_it(path)
  end #/ feed_actualites
  def feed_tracer
    path = './www/tmp/logs/tracer.log'
    read_it(path)
  end #/ feed_tracer


  def read_it(path)
    cmd = <<-CMD.strip.freeze
    ssh icare@ssh-icare.alwaysdata.net ruby <<SSH
    puts File.open('#{path}','rb'){|f|f.read}
    SSH
    CMD
    puts `#{cmd}`
  end #/ read_it
end # /<< self
end #/IcareCLI
