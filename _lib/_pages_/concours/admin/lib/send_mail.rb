# encoding: UTF-8
# frozen_string_literal: true
class MailSend
class << self
  attr_reader :mail_subject
  def send(destinataires, mail, options)
    require_module('mail')
    # On construit le texte avant pour essayer de définir le titre
    message = deserb(mail_path(mail), self)
    if false # options[:noop]
      html.res << "*** Liste des destinataires visés par le mail “#{mail_subject}” ***"
      destinataires.each do |dd|
        html.res << "- #{dd[:pseudo]} (#{dd[:mail]})"
      end
    else # On procède vraiment à l'opération
      destinataires.each do |dd|
        Mail.send(
          to: dd[:mail],
          subject:mail_subject,
          message:(message % dd)
        )
      end
      message("Messages envoyés.")
    end
  end #/ send

  # Pour définir le titre
  def subject(titre)
    @mail_subject = titre
  end #/ title

  def bind; binding() end

  # IN    Nom ou chemin relatif du mail
  # OUT   Chemin absolu, pour le déserbage
  def mail_path(mailp)
    File.join(XMODULES_FOLDER,'mails', mailp)
  end #/ mail_path
end # /<< self
end #/MailSend
