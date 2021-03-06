# encoding: UTF-8
# frozen_string_literal: true

UI_TEXTS.merge!({
  proceed_envoi: "Procéder à l’envoi"
})

MESSAGES.smart_merge!({
  contact:{
    confirme_envoi: "Votre message a bien été transmis."
  }
})

ERRORS.merge!({
  groupe_destinataires_required: "Il est impératif de choisir les destinataires.",
  no_saved_mailing: 'Il n’existe aucun mailing enregistré…',
  mailing_uuid_invalid: 'L’identifiant unique du mailing est invalide. Je ne peux pas procéder à l’opération demandée.',
})
