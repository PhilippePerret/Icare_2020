# encoding: UTF-8
# frozen_string_literal: true

ERRORS.merge!({
  mail_valide_required: "Cette adresse mail est inconnue du site…",
})
MESSAGES.merge!({
  mot_de_passe_sent: "Votre nouveau mot de passe a été envoyé à l’adresse mail %s.",
  sujet_mail_envoi_password: "Mot de passe oublié",
  message_mail_envoi_password: <<-EOT,
  <p>Bonjour %{pseudo},</p>
  <p>Votre mot de passe provisoire est : %{password}</p>
  <p>Utilisez-le pour vous reconnecter au site de l'atelier, puis modifiez-le depuis votre profil.</p>
  <p>Bien à vous,</p>
  <p>🤖 Le bot de l'atelier Icare</p>
  EOT
})

UI_TEXTS.merge!({
  btn_send_mail: "Envoyer"
})
