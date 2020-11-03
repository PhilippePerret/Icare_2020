# encoding: UTF-8
# frozen_string_literal: true
=begin
  Envoi de notifications

  Note : on utilise 'icare cron add ...' pour les définir.
=end
class Cronjob

  attr_reader :liste_notifications

  def data
    @data ||= {
      name: "Envoi de notifications",
      frequency: {hour: 11}
    }
  end #/ data

  def send_notifications
    return if not(File.exists?(path))
    rests = [] # pour mettre les notifications qui resteront à envoyer
    sends = [] # pour mettre les notifications à envoyer
    File.read(path).split("\n").each do |line|
      notify = NotifyLine.new(*line.split('___'))
      if notify.today?
        sends << notify
      else
        rests << line
      end
    end
    send_notifications(sends) unless sends.empty?
    consigne_autres_notifications(rests) unless rests.empty?

    return true
  end #/

  def send_notifications(sends)
    require_module('mail')
    @liste_notifications = sends.collect{|note|"<li>#{note.message}</li>"}.join
    MailSender.send(file:mail_path, bind:self)
  end #/ send_notifications(sends)

  def consigne_autres_notifications(rests)
    File.delete(path)
    File.open(path,'wb') { |f| f.write rests.join("\n") + "\n" }
  end

  def mail_path
    @mail_path ||= File.join(__dir__,'send_notifications','mail.erb')
  end #/ mail_path

  # Le fichier qui contient les notifications à envoyer
  def path
    @path ||= File.join(CRON_FOLDER,'_lib','notifications.data')
  end #/ path


end #/Cronjob

NotifyLine = Struct.new(:datestr, :message) do
# OUT   TRUE Si c'est une notification a envoyer aujourd'hui
def today?
  n = Time.now
  time.year == n.year && time.month == n.month && time.day == n.day
end #/ today?

# OUT   La date (le {Time})
def time
  @time ||= DateString.new(datestr).to_time
end #/ time
end
