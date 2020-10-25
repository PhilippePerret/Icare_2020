# encoding: UTF-8
# frozen_string_literal: true
class MailSender
class << self
  attr_reader :mail_subject

  # Pour définir le titre à l'intérieur du mail
  def subject(titre)
    @mail_subject = titre
  end #/ title

  # = main =
  #
  # Envoi des messages
  # ------------------
  # IN    destinataires   Array des tables des destinataires
  #       mail            Nom du mail (fichier)
  #       options         Table d'options.
  # OUT   void
  # DO    Envoi le mail +mail+ à tous les +destinataires+
  #
  def send(destinataires, mail, options)
    require_module('mail')
    # On construit le texte avant pour définir le titre
    @mail_subject = nil # pour ne pas hériter de l'envoi précédant si subject oublié
    message = deserb(mail_path(mail), self)
    if options[:noop]
      simuler(message, destinataires, options)
    else # On procède vraiment à l'opération
      destinataires.each do |dd|
        # Si le sexe est défini dans les données, on renseigne des propriétés
        # de base à commencer par le "e" pour les filles. Cf. ci-dessous la
        # méthode :sexize_destinataire_properties
        dd = sexize_destinataire_properties(dd) if dd.key?(:sexe)
        Mail.send(to: dd[:mail], subject:mail_subject, message:(message % dd))
      end
      html.res << "= #{destinataires.count} messages envoyés. ="
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

    html.res << <<-HTML
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
