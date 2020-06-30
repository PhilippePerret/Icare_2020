# encoding: UTF-8

ERRORS.merge!({
  titre_discussion_required: 'Le titre de la discussion est requis'.freeze,
  message_discussion_required:  'Le message de la discussion est requis, voyons ! 🤨'.freeze,
  message_frigo_too_long: 'Ce message est trop long (limite de 12 000 signes)'.freeze,
  message_frigo_too_short: 'Ce message est vraiment trop court…'.freeze,
  discussion_required: 'Une discussion est requise, pour exécuter cette opération…'.freeze,
})

MESSAGES.merge!({
  follower_warned_for_new_message: "J'ai averti %s de ce nouveau message.".freeze,
  nombre_messages_non_lus: "Nombre de nouveaux messages : %i".freeze,
  bouton_tout_marquer_lu: '<span class="small ml2"><a href="bureau/frigo?disid=%s&op=marquer_lus">Tout marquer lu</a></span>'.freeze,
  discussion_marquee_lue: 'La discussion a été marquée lue.'.freeze
})
