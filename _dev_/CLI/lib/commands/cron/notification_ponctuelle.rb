# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension pour l'ajout de notifications ponctuelles
=end
class IcareCLI
class << self
  def add_notification_ponctuelle
    # Peut-être que ce qui suit params[1] définit ce qu'il faut ajouter
    i = 1
    donnees = []
    while param = params[i+=1]; donnees << param end

    # *** LA DATE ***
    datestr = donnees.shift || get_date_notification
    dstring = DateString.new(datestr)
    dstring.valid? || raise("Date invalide : #{dstring.error}.")
    date = dstring.to_time

    puts "Date d'envoi de la notification : #{formate_date(date, {jour:true, hour:true})}"
    datestr = date.strftime("%d/%m/%Y/%H:%M")

    if date.hour != 0 || date.min != 0
      puts "#{'Attention'.rouge} : #{"L'heure ne sera pas vraiment prise en compte,\npuisque le notifieur sera forcément déclenché à 11 heures,\nquelle que soit l'heure définie ici".jaune}."
      Q.keypress("Pressez une touche pour poursuivre.")
    end

    # *** LE MESSAGE ***
    # Pour le moment on ne peut que donner une date et un message
    message = if donnees.empty?
                get_notification_message.nil_if_empty
              else
                donnees.join(' ')
              end
    # Il doit y avoir un message
    not(message.empty?) || raise("Il faut donner le message !")

    # On peut enregistrer le message
    ssh_request = <<-SSH
ssh #{SSH_ICARE_SERVER} ruby << RUBY
File.open('#{cron_notifications_file}','a') do |f|
  f.write %Q{#{datestr}___#{message.gsub(/\}/,'\}').gsub(/\n/,'\n')}}
  f.write "\n"
end
RUBY
    SSH

    res = `#{ssh_request} 2>&1`
    if res.nil_if_empty.nil?
      puts "Retour du travail SSH : #{res.inspect}"
    end

    puts "Notification enregistrée avec succès. Elle sera déclenchée le #{formate_date(date, {jour:true, hour:false})} à 11:00.".vert

  end #/ add_notification_ponctuelle

  # OUT   Le chemin d'accès au fichier qui contient les données de notification
  #       du cron distant (c'est en distant qu'on ).
  def cron_notifications_file
    @cron_notifications_file ||= "www/cronjob2/_lib/notifications.data"
  end #/ cron_notifications_file

private

  # Pour demander la date de la notification (avec l'heure)
  def get_date_notification
    Q.ask("Date et heure de la notification, au format 'JJ MM[ YY[ HH:MM]]'") do |q|
      q.validate do |input|
        error = date_well_formated?(input)
        if error.nil?
          true
        else
          q.value input
          q.messages[:valid?] = error
          false
        end
      end
      # q.messages[:valid?] = "La date doit être fournie au format 'JJ MM[ YY[ HH:MM]]'."
    end
  end #/ get_date_notification

  def get_notification_message
    Q.multiline("Message à envoyer :", help: "(Ctrl-d pour terminer)").join("\n")
  end #/ get_notification_message

  # Méthode qui checke la validatité de la date
  # OUT   NIL Si la date est OK
  #       Le message d'erreur dans la cas contraire.
  # IN    La date au format string.
  def date_well_formated?(dstr)
    dstring = DateString.new(dstr)
    return dstring.valid? ? nil : dstring.error
  end #/ date_well_formated?

end # /<< self
end #/IcareCLI
