# encoding: UTF-8
# frozen_string_literal: true

ONLINE  = ENV['HTTP_HOST'] != "localhost" unless defined?(ONLINE)
OFFLINE = !ONLINE unless defined?(OFFLINE)

class MailSender
class << self
attr_reader :mail_subject

# OUT   True pour un mode sans opération
# ENV   Variable 'NOOP' ("true" ou "1")
#
def noop?(options = {})
  (@with_noop ||= begin
    ["true","1"].include?(ENV['NOOP']) ? :true : :false
  end) == :true || options[:noop]
end #/ noop?

def verbose?(options = {})
  (@is_verbose ||= begin
    ["TRUE","1"].include?(ENV['VERBOSE']) ? :true : :false
  end) == :true || options[:verbose]
end #/ verbose?

def mode_test?
  :TRUE == (@en_mode_test ||= (OFFLINE && File.exists?('./TESTS_ON') ? :TRUE : :FALSE))
end

def maillog(msg)
  if defined?(html) && html.respond_to?(:res)
    html.res << msg
  else
    log(msg)
  end
end #/ log

# La méthode qui wrap l'envoi de mail, pour permettre une définition plus
# simple des mails, et notamment du sujet qui sera, ici, contenu dans le
# mail lui-même
# Cf. le manuel (icare read manuel)
#
# IN    {Hash} Paramètres du mail et notamment :
#         :to     Mail du destinataire    [REQUIS]
#         :from   Mail de l'expéditeur
#         :path   Chemin d'accès une mail en vers ERB [REQUIS]
#         :bind   Le bindee pour composer le mail [REQUIS]
#         :data   Exceptionnellement, des données pour détemplatiser.
#                 [1] Mais il vaut mieux passer par l'objet bindé.
#
# DO    Envoie le mail
#
def send(dmail)
  # S'assurer que l'objet bindé connait les méthodes pour le sujet du mail
  implemente_subject_to( dmail[:bind] ) if not(dmail[:bind].respond_to?(:subject))
  implemente_helpers_methods( dmail[:bind] ) if not(dmail[:bind].respond_to?(:le_bot))
  # Déserber le message et récupérer le sujet du mail
  mail_message = deserb(dmail[:file]||dmail[:path], dmail[:bind]) # => subject
  # Ici, il faudrait templatiser le message avec les données ([1])
  if dmail.key?(:data)
    mail_message = mail_message % dmail[:data]
  end
  # Finaliser les données utiles pour le mail
  dmail.merge!(subject: dmail[:bind].mail_subject, message: mail_message)
  # log("Data mail final: #{dmail.inspect}")
  # Envoyer le mail ou simuler son envoi
  if noop?(dmail)
    simuler_unique_message(dmail)
  else
    Mail.send(dmail)
  end
end #/ send

def simuler_unique_message(dmail, options = nil)
  options ||= {}
  retour = case options[:format]
  when 'html'
    <<-HTML
<div class="simulation">
<p class="bold">Envoi du mail :<br> “#{dmail[:subject]}”</p>
<div class="bold">Message</div>
#{Tag.div(class:'border', text:dmail[:message])}
<p>Destinataire: #{dmail[:to]||'Moi'}</p>
</div>
    HTML
  else # Quand aucun format n'est précisé
    <<-TEXT

#{"SIMULTATION de l'envoi du message #{dmail[:subject]}".bleu}
Destinataire
------------
  #{dmail[:to] || 'Moi'}
Message
-------
#{dmail[:message]}

    TEXT

  end
end #/ simuler_unique_message

# = main =
#
# Envoi des messages
# ------------------
# IN    to:         Array des destinataires
#       file:       Chemin d'accès au mail (fichier ERB)
#       bind:       Objet bindé au fichier ERB.
#       noop:       Simuler seulement l'envoi
#                   Sera mis dans +options+ et supprimé
# IN    +options+
#         noop:     Pour simuler seulement l'envoi.
# OUT   void
# DO    Envoi le mail +mail+ à tous les +destinataires+
#
def send_mailing(dmail, options = nil)
  options ||= {}
  options.merge!(noop: dmail.delete(:noop)) unless options.key?(:noop)

  # Les destinataires
  destinataires = dmail[:to]

  #
  # Deux modes d'utilisation : soit un message dans un fichier, et dans ce
  # cas, dmail[:bind] est défini, soit un message "brut" et dans ce cas,
  # dmail[:message] contient le message, et dmail[:file] n'est pas défini
  #
  message_mail = nil ; sujet_mail = nil ;
  if dmail[:message]
    sujet_mail    = dmail[:subject]
    message_mail  = dmail[:message]
  elsif dmail[:bind]
    # log("Destinataires du mailing: #{destinataires}")
    # S'assurer que l'objet bindé connait les méthodes pour le sujet du mail
    implemente_subject_to( dmail[:bind] ) if not(dmail[:bind].respond_to?(:subject))
    # On construit le texte avant pour définir le titre (si c'est dans un fichier
    # ERB, mais ça pourrait aussi être du code)
    message_mail  = deserb(dmail[:file], dmail[:bind])
    sujet_mail    = dmail[:bind].mail_subject
  elsif dmail[:file]
    sujet_mail    = dmail[:subject]
    message_mail  = deserb(dmail[:file])
  else
    raise "Il faut au moins que :message, :bind ou :file soit défini."
  end

  # Détection automatique du format s'il n'est pas défini, en fonction du
  # message
  options[:format] ||= case
  when message_mail.match?(/<%/) then 'erb'
  when message_mail.match?(/<(p|div|span)>/) then 'html'
  else 'md'
  end

  log("\n\n-> send_mailing\ndmail = #{dmail.inspect}\noptions = #{options.inspect}\n\n")
  log("Message mail template : #{message_mail}")

  # maillog("Sujet du message : #{sujet_mail.inspect}")
  # maillog("Le message template final : #{message_mail}")

  if noop?(options)
    simuler_mailing(sujet_mail, message_mail, destinataires, options)
  else # On procède vraiment à l'opération
    require 'timeout'
    envois = nil
    Timeout.timeout(0) {
      envois = release_mailing(sujet_mail, message_mail, destinataires, options, dmail)
    }
    if verbose?(options)
      ret = case options[:format]
        when 'html'
          "<ul>#{envois.join}</ul><div>= #{destinataires.count} messages envoyés. =</div>"
        else
          envois.join("\n") + "\n#{destinataires.count} messages envoyés."
        end
      maillog(ret)
    end

    return envois
  end
end #/ send_mailing

def release_mailing(sujet_mail, message, destinataires, options, dmail)
  log("Message mail template dans release_mailing : #{message.inspect}")
  destinataires.collect do |ddinit| # NOTE : collect (= retour de la méthode)
    # Si on n'est pas en mode test, on attend environ une seconde entre chaque envoi
    unless mode_test?
      sleep 0.75
    end
    dd = ddinit.is_a?(User) ? ddinit.data : ddinit
    # Si c'est un destinataire sans mail, on ne le traite pas
    if not(dd.key?(:mail)) || dd[:mail].nil_if_empty.nil?
      maillog("<div class='error'>Donnée destinataire sans mail : #{dd.inspect}. Pas d'envoi possible.</div>")
      next
    end
    # Si le sexe est défini dans les données, on renseigne des propriétés
    # de base à commencer par le "e" pour les filles. Cf. ci-dessous la
    # méthode :sexize_destinataire_properties
    dd = sexize_destinataire_properties(dd) if dd.key?(:sexe)
    begin
      message_final = case options[:format]
                      when 'md'   then kramdown(message, ddinit)
                      when 'erb'  then deserb(message, ddinit)
                      else
                        if message.match?('#{')
                          ddinit.bind.eval(%Q{"#{message}"})
                        else
                          message
                        end
                      end
      # On procède à l'envoi du mail
      # Mail.send(to: dd[:mail], from:dmail[:from], subject: sujet_mail, message: (message % dd))
      Mail.send(to: dd[:mail], from:dmail[:from], subject: sujet_mail, message: message_final)

      # Avant, je retournais un message au format différent suivant le format
      # du message à envoyer (erb, html ou md) mais maintenant je prends
      # l'option que c'est toujours une page HTML qui se chargera d'afficher
      # le résultat, donc on retourne :
      "<li>Message envoyé à #{dd[:mail]} (#{dd[:pseudo]})</li>" # collect
    rescue Exception => e
      maillog "<div class='error'>PROBLÈME D'ENVOI DE MAIL : #{e.message} (avec dd = #{dd.inspect})</div>"
      "<li class='error'>ERROR: #{dd[:pseudo]} (#{dd[:mail]}) : #{e.message}</li>" # collect
    end
  end #/ collect
end #/ release_mailing

# Ajouter quelques féminines communes aux propriétés du destinataire
def sexize_destinataire_properties(props)
  is_femme = props[:sexe] == 'F'
  FemininesMethods::FEMININES.each do |key, dkey|
    props.merge!(key => is_femme ? dkey[0] : dkey[1])
  end
  return props
end #/ sexize_destinataire_properties

# Simuler l'envoi du message +message+ aux +destinataires+
# IN    subject     Le sujet du message
#       message     Le message template à utiliser (il lui reste les %{…})
#       destinataires Les destinataires des messages, des tables qui
#                     contiennent :pseudo, :mail, :sexe ainsi que les
#                     propriétés permettant de détemplatiser le message
#       options       Table d'options. Donc:
#                     :format   Le format de sortie de la simulation
#                         console   Pour la console
#                         html      Code HTML
#
def simuler_mailing(sujet, message, destinataires, options)
  # Pour prendre des propriétés particulières peut-être
  destinataire_femme = destinataires.first.dup || {pseudo:'Ernestine', mail:'ernestine@gmail.com', sexe:'F'}
  destinataire_homme = destinataire_femme.dup.merge!(pseudo:'Ernest', sexe:'H')
  # Pour voir les féminines (if any)
  destinataire_femme.merge!(pseudo:"Ernestine", sexe:'F')
  destinataire_femme = sexize_destinataire_properties(destinataire_femme)
  destinataire_homme = sexize_destinataire_properties(destinataire_homme)

  retour = case options[:format]
  when 'html'
    <<-HTML
<div class="simulation">
<p class="bold">Envoi du mail :<br> “#{sujet}”</p>
<div class="bold">Version féminine</div>
#{Tag.div(class:'border', text:(message % destinataire_femme))}
<div class="bold">Version masculine</div>
#{Tag.div(class:'border', text:(message % destinataire_homme))}
<p>Envoyer ce mail à : </p>
<ul>#{destinataires.collect { |dd| "<li>#{dd[:pseudo]} (#{dd[:mail]})</li>" }.join}</ul>
</div>
    HTML
  else
    <<-TEXT
#{"SIMULATION de l'envoi par mailing du mail : #{mail_subject}".bleu}
Version féminine
----------------
#{message % destinataire_femme}
Version masculine
-----------------
#{message % destinataire_homme}
Destinataires
-------------
#{destinataires.collect { |dd| "\t#{dd[:pseudo]} (#{dd[:mail]})" }.join("\n")}
    TEXT
  end
  maillog(retour)
end #/ simuler

def bind; binding() end

private

  # On implémente les méthode 'subject(...)' et 'mail_subject' à l'objet bindé
  # s'il ne connait pas ces méthodes.
  def implemente_subject_to(bindee)
    eval("def subject(sujet);@mail_subject = sujet end\n", bindee.bind)
    eval("def mail_subject;return nil if @mail_subject.nil?;suj=@mail_subject.dup;@mail_subject=nil;return suj;end\n", bindee.bind)
  end #/ implemente_subject_to

  def implemente_helpers_methods(bindee)
    eval("self.class.include StringHelpersMethods", bindee.bind)
  end #/ implemente_helpers_methods



end # /<< self
end #/MailSender
