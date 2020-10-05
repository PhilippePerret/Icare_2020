# encoding: UTF-8
# frozen_string_literal: true

UI_TEXTS.merge!({
  titre_section_documents: "Vos documents"
})

ERRORS.merge!({
  auteur_document_required: "L'auteur du document est absolument requis pour effectuer cette opération.",
  cant_find_qdd_document:'Désolé, mais je ne trouve pas ce document sur le Quai des docs… Il n’est peut-être pas encore déposé.',
})


MESSAGES.merge!({
  document_set_shared: 'Merci à vous ! Le document “%s” est maintenant partagé.',
  document_unset_shared: 'Dommage, le document “%s” n’est maintenant plus partagé…',
  # Pour le mail envoyé à l'administration
  msg_mailadmin_unshared_doc: <<-HTML,
  <p>Phil,</p>
  <p>Je t'informe que %{pseudo} (%{user_id}) vient de supprimer le partage de son document :</p>
  <p>“%{titre}” #%{id}</p>
  <p>Le bot</p>
  HTML
  subject_mailadmin_unshared_doc: 'Dé-partage de document'
})


EMO_DOCUMENTS = Emoji.new('objets/pile-livres')
