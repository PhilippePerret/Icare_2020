# encoding: UTF-8

ERRORS.merge!({
  titre_discussion_required: 'Le titre de la discussion est requis'.freeze,
  message_discussion_required:  'Le message de la discussion est requis, voyons ! 🤨'.freeze,
  message_frigo_too_long: 'Ce message est trop long (limite de 12 000 signes)'.freeze,
  message_frigo_too_short: 'Ce message est vraiment trop court…'.freeze,
  discussion_required: 'Une discussion est requise, pour exécuter cette opération…'.freeze,
  not_a_participant: "Vous ne participez pas à cette discussion, vous ne pouvez pas la télécharger.".freeze,
  destroy_require_owner: 'La destruction d’une discussion ne peut se faire que par son instigateur/instigatrice.'.freeze,
})

MESSAGES.merge!({
  follower_warned_for_new_message: "J'ai averti %s de ce nouveau message.".freeze,
  nombre_messages_non_lus: "Nombre de nouveaux messages : %i".freeze,
  bouton_tout_marquer_lu: '<span class="small ml2"><a href="bureau/frigo?disid=%s&op=marquer_lus">Tout marquer lu</a></span>'.freeze,
  discussion_marquee_lue: 'La discussion a été marquée lue.'.freeze,
  confirmation_quit_discussion: 'Vous avez bien quitté la discussion “%s”.'.freeze,
  subject_depart_discussion: 'Départ d’une de vos discussions'.freeze,
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
end #/FrigoDiscussion
