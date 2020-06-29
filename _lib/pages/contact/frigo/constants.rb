# encoding: UTF-8
=begin
  Constantes messages
=end
MESSAGES.merge!({
  mail_guest_subject: 'Quelqu’un vous a contacté par votre frigo'.freeze,
  guest_message: <<-HTML
<p>%{pseudo},</p>
<p>Un visiteur de l'atelier Icare vous contacte par votre frigo.</p>
<p>Son message :</p>
<div style="margin:1em; border:1px solid #CCCCCC;">%{message}</div>
<p>Pour lui répondre :</p>
<p><a href="mailto:%{mail}">Répondre à %{mail}</a></p>
<p>Bien à vous,</p>
<p>Le Bot de l’atelier Icare</p>
  HTML
})

ERRORS.merge!({
  icarien_not_contactable: "Cet icarien n’est pas contactable par ce biais, désolé.".freeze,
  mail_required_for_guest: 'Votre mail est absolument requis'.freeze,
  guest_mail_conf_not_match: 'La confirmation de votre mail ne correspond pas…'.freeze,
})
