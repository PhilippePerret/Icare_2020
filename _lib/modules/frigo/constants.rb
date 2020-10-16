# encoding: UTF-8
# frozen_string_literal: true
require './_lib/required/__first/ContainerClass'

UI_TEXTS.merge!({
  inviter_users_button: 'Inviter des icarien·ne·s',
  quit_discuss_button:  'Quitter cette discussion',
  download_discuss_btn: 'Télécharger la discussion'
})

ERRORS.merge!({
  titre_discussion_required: 'Le titre de la discussion est requis',
  message_discussion_required:  'Le message de la discussion est requis, voyons ! 🤨',
  message_frigo_too_long: 'Ce message est trop long (limite de 12 000 signes)',
  message_frigo_too_short: 'Ce message est vraiment trop court…',
  discussion_required: 'Une discussion est requise, pour exécuter cette opération…',
  not_a_participant: "Vous ne participez pas à cette discussion, vous ne pouvez pas la télécharger.",
  destroy_requires_owner: 'La destruction d’une discussion ne peut se faire que par son instigateur/instigatrice.',
  inviter_requires_owner: 'L’invitation à une discussion n’est possible que pour son instigateur/trice',
  invites_required: "Il faut choisir les icarien·ne·s à inviter !",
  no_participants_found: 'Aucun participant·e n’a été trouvé·e'
})

MESSAGES.merge!({
  followers_warned_for_new_message: "Nouveau message enregistré. Les interlocutrices et interlocuteurs ont été averti·e·s.",
  bouton_tout_marquer_lu: '<span class="small ml2"><a class="mark-lu-btn" href="bureau/frigo?disid=%s&op=marquer_lus">Tout marquer lu</a></span>',
  discussion_marquee_lue: 'La discussion a été marquée lue.',
  confirmation_quit_discussion: 'Vous avez bien quitté la discussion “%s”.',
  subject_depart_discussion: 'Départ d’une de vos discussions',
  confirm_discussion_destroyed: 'La discussion a été correctement détruite.',
  cancel_destroying_discussion: "On abandonne la destruction de cette discussion.",
  message_depart_discussion:<<-HTML
<p>%{owner},</p>
<p>Je vous informe que %{pseudo} vient de quitter votre discussion “%{titre}”.</p>
<p>Bien à vous,</p>
<p>🤖 Le Bot de l'atelier Icare 🦋</p>
  HTML

})

class FrigoDiscussion < ContainerClass
  TABLE_USERS       = 'frigo_users'
  TABLE_DISCUSSIONS = 'frigo_discussions'
  TABLE_MESSAGES    = 'frigo_messages'

  TITRE_MAIL_DESTRUCTION = "Une discussion à laquelle vous participiez a été supprimée"
  MAIL_DESTRUCTION = <<-HTML.strip
<p>%{pseudo},</p>
<p>Je vous informe que %{owner_pseudo} vient de détruire la discussion “%{titre}” à laquelle vous participiez. Il n'est plus possible, à présent, de la télécharger.</p>
<p>Bien à vous,</p>
<p>🤖 Le Bot de l'Atelier Icare 🦋</p>
  HTML

# Requête pour récupérer les auteurs de tous les messages
REQUEST_AUTEURS_MESSAGES = <<-SQL
SELECT DISTINCT u.id
  FROM frigo_messages AS fm
  INNER JOIN users AS u ON fm.user_id = u.id
  WHERE discussion_id = %i
SQL

end #/FrigoDiscussion
