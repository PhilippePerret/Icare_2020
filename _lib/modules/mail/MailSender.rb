# encoding: UTF-8
# frozen_string_literal: true
class MailSender
class << self
  attr_reader :mail_subject

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
  #
  def send(dmail)
    # S'assurer que l'objet bindé connait les méthodes pour le sujet du mail
    implemente_subject_to( dmail[:bind] ) if not(dmail[:bind].respond_to?(:subject))
    # Déserber le message et récupérer le sujet du mail
    mail_message = deserb(dmail[:file]||dmail[:path], dmail[:bind]) # => subject
    # Finaliser les données utiles pour le mail
    dmail.merge!(subject: dmail[:bind].mail_subject, message: mail_message)
    # log("Data mail final: #{dmail.inspect}")
    # Envoyer le mail
    Mail.send(dmail)
  end #/ send

  # On implémente les méthode 'subject(...)' et 'mail_subject' à l'objet bindé
  # s'il ne connait pas ces méthodes.
  def implemente_subject_to(bindee)
    eval("def subject(sujet);@mail_subject = sujet end\n", bindee.bind)
    eval("def mail_subject;suj=@mail_subject.dup;@mail_subject=nil;return suj;end\n", bindee.bind)
  end #/ implemente_subject_to

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
    destinataires = dmail[:to]
    # S'assurer que l'objet bindé connait les méthodes pour le sujet du mail
    implemente_subject_to( dmail[:bind] ) if not(dmail[:bind].respond_to?(:subject))
    # On construit le texte avant pour définir le titre
    message = deserb(dmail[:file], dmail[:bind])
    sujet_mail = dmail[:bind].mail_subject

    maillog("Sujet du message : #{sujet_mail.inspect}")
    maillog("Le message template final : #{message}")

    if options[:noop]
      simuler(message, destinataires, options)
    else # On procède vraiment à l'opération
      envois = destinataires.collect do |dd|
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
          Mail.send(to: dd[:mail], subject: sujet_mail, message: (message % dd))
          "<li>#{dd[:pseudo]} (#{dd[:mail]})</li>" # collect
        rescue Exception => e
          maillog "<div class='error'>PROBLÈME D'ENVOI DE MAIL : #{e.message} (avec dd = #{dd.inspect})</div>"
          "<li class='error'>#{dd[:pseudo]} (#{dd[:mail]})</li>" # collect
        end
      end
      if options[:verbose]
        maillog("<ul>#{envois.join}</ul><div>= #{destinataires.count} messages envoyés. =</div>")
      end
    end
  end #/ send

  # Ajouter quelques féminines communes aux propriétés du destinataire
  def sexize_destinataire_properties(props)
    is_femme = props[:sexe] == 'F'
    props.merge!({
      e:  is_femme  ? "e" : "",
      ve: is_femme  ? "ve" : "f", # active/actif
      })
  end #/ sexize_destinataire_properties

  # Simuler l'envoi du message +message+ aux +destinataires+
  def simuler(message, destinataires, options)
    # Pour prendre des propriétés particulières peut-être
    destinataire_femme = destinataires.first.dup || {pseudo:'Ernestine', mail:'ernestine@gmail.com', sexe:'F'}
    destinataire_homme = destinataire_femme.dup.merge!(pseudo:'Ernest', sexe:'H')
    # Pour voir les féminines (if any)
    destinataire_femme.merge!(pseudo:"Ernestine", sexe:'F')
    destinataire_femme = sexize_destinataire_properties(destinataire_femme)
    destinataire_homme = sexize_destinataire_properties(destinataire_homme)

    maillog <<-HTML
<div class="simulation">
<p class="bold">Envoi du mail :<br> “#{mail_subject}”</p>
<div class="bold">Version féminine</div>
#{Tag.div(class:'border', text:(message % destinataire_femme))}
<div class="bold">Version masculine</div>
#{Tag.div(class:'border', text:(message % destinataire_homme))}
<p>Envoyer ce mail à : </p>
<ul>#{destinataires.collect { |dd| "<li>#{dd[:pseudo]} (#{dd[:mail]})</li>" }.join}</ul>
</div>
    HTML
  end #/ simuler

  def bind; binding() end

  # IN    Nom ou chemin relatif du mail
  # OUT   Chemin absolu, pour le déserbage
  def mail_path(mailp)
    File.join(XMODULES_FOLDER,'mails', mailp)
  end #/ mail_path
end # /<< self
end #/MailSender
