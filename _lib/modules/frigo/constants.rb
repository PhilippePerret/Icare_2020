# encoding: UTF-8
require './_lib/required/__first/ContainerClass'

UI_TEXTS.merge!({
  inviter_users_button: 'Inviter des icarien·ne·s'.freeze,
  quit_discuss_button:  'Quitter cette discussion'.freeze,
  download_discuss_btn: 'Télécharger la discussion'.freeze
})

ERRORS.merge!({
  titre_discussion_required: 'Le titre de la discussion est requis'.freeze,
  message_discussion_required:  'Le message de la discussion est requis, voyons ! 🤨'.freeze,
  message_frigo_too_long: 'Ce message est trop long (limite de 12 000 signes)'.freeze,
  message_frigo_too_short: 'Ce message est vraiment trop court…'.freeze,
  discussion_required: 'Une discussion est requise, pour exécuter cette opération…'.freeze,
  not_a_participant: "Vous ne participez pas à cette discussion, vous ne pouvez pas la télécharger.".freeze,
  destroy_requires_owner: 'La destruction d’une discussion ne peut se faire que par son instigateur/instigatrice.'.freeze,
  inviter_requires_owner: 'L’invitation à une discussion n’est possible que pour son instigateur/trice'.freeze,
  invites_required: "Il faut choisir les icarien·ne·s à inviter !".freeze,
  no_participants_found: 'Aucun participant·e n’a été trouvé·e'.freeze
})

MESSAGES.merge!({
  follower_warned_for_new_message: "J'ai averti %s de ce nouveau message.".freeze,
  nombre_messages_non_lus: "Nouveaux messages : <span class='new-messages-count'>%i</span>".freeze,
  bouton_tout_marquer_lu: '<span class="small ml2"><a class="mark-lu-btn" href="bureau/frigo?disid=%s&op=marquer_lus">Tout marquer lu</a></span>'.freeze,
  discussion_marquee_lue: 'La discussion a été marquée lue.'.freeze,
  confirmation_quit_discussion: 'Vous avez bien quitté la discussion “%s”.'.freeze,
  subject_depart_discussion: 'Départ d’une de vos discussions'.freeze,
  confirm_discussion_destroyed: 'La discussion a été correctement détruite.'.freeze,
  cancel_destroying_discussion: "On abandonne la destruction de cette discussion.".freeze,
  message_depart_discussion:<<-HTML.freeze
<p>%{owner},</p>
<p>Je vous informe que %{pseudo} vient de quitter votre discussion “%{titre}”.</p>
<p>Bien à vous,</p>
<p>🤖 Le Bot de l'atelier Icare 🦋</p>
  HTML

})

class FrigoDiscussion < ContainerClass
  TABLE_USERS       = 'frigo_users'.freeze
  TABLE_DISCUSSIONS = 'frigo_discussions'.freeze
  TABLE_MESSAGES    = 'frigo_messages'.freeze

  TITRE_MAIL_DESTRUCTION = "Une discussion à laquelle vous participiez a été supprimée".freeze
  MAIL_DESTRUCTION = <<-HTML.strip.freeze
<p>%{pseudo},</p>
<p>Je vous informe que %{owner_pseudo} vient de détruire la discussion “%{titre}” à laquelle vous participiez. Il n'est plus possible, à présent, de la télécharger.</p>
<p>Bien à vous,</p>
<p>🤖 Le Bot de l'Atelier Icare 🦋</p>
  HTML
end #/FrigoDiscussion
