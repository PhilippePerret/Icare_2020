# encoding: UTF-8
=begin
  Messages et textes pour les préférences
=end
# Pour réquérir les flags
require './_lib/required/__first/constants/flags'

MESSAGES.merge!({
  confirm_titre_projet_saved: 'Le titre de votre projet courant a été enregistré.'.freeze,
  confirm_options_saved: 'Vos nouvelles options ont été enregistrées.'.freeze,
  # --- les textes d'explication ---
  # Note : les clés doivent être composées à l'aide de :expli_<clé dans DATA_PREFERENCES>
  #
  expli_after_login:      "Choisissez ci-dessus la section à rejoindre immédiatement après vous être identifié%{e} sur le site.".freeze,
  expli_freqs_actualites: "L’atelier vous informe régulièrement de l’activité des icariennes et icariens (ce qui peut être motivant). Choisissez ci-dessus à quelle fréquence vous voulez être contacté%{e}.".freeze,
  expli_contact_admin:    'Choisissez ci-dessus comment l’administration de l’atelier peut vous contacter.'. freeze,
  expli_contact_icarien:  'Choisissez ci-dessus comment les autres icariens peuvent vous contacter.'.freeze,
  expli_contact_world:    'Choisissez ci-dessus comment les visiteurs quelconques peuvent vous contacter (par exemple par le biais de la <a href="overview/icariens">salle des Icarien·ne·s</a>).'.freeze,
  expli_share_histo:      'Choisissez ci-dessus qui peut consulter votre historique de travail (votre section “Historique” — et seulement celle-ci)'.freeze,
  expli_project_name:     "Vous pouvez définir ci-dessus le titre du projet que vous développez en module de suivi de projet.".freeze,

})

ERRORS.merge!({
  no_module_no_titre_projet: 'Vous n’avez pas de module courant, vous ne pouvez pas définir de titre.'.freeze
})

DATA_FREQ_MAIL = {
  0 => {name: 'Mail quotidien (si actualité)'},
  1 => {name: 'Résumé hebdomadaire'},
  9 => {name: 'Jamais'}
}

DATA_CONTACTS = {
  FLAG_MAIL|FLAG_FRIGO  => {name:'par mail et sur le frigo'},
  FLAG_MAIL             => {name:'par mail seulement'},
  FLAG_FRIGO            => {name:'sur le frigo seulement'},
  0                     => {name:'Aucun contact'}
}

DATA_SHARINGS = {
  FLAG_ICARIENS => {name:'Avec les icariens'},
  FLAG_WORLD    => {name:'Avec tout le monde'},
  0             => {name:'Avec personne'}
}
