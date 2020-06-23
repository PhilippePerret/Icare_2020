# encoding: UTF-8
=begin
  Messages et textes pour les préférences
=end
MESSAGES.merge!({
  confirm_titre_projet_saved: 'Le titre de votre projet courant a été enregistré.'.freeze,
  confirm_options_saved: 'Vos nouvelles options ont été enregistrées.'.freeze,
  # --- les textes d'explication ---
  # Note : les clés doivent être composées à l'aide de :expli_<clé dans DATA_PREFERENCES>
  #
  expli_after_login: "Choisissez ci-dessus la section à rejoindre immédiatement après vous être identifié%{e} sur le site.".freeze,
  expli_freqs_actualites: "L’atelier vous informe régulièrement de l’activité des icariennes et icariens (ce qui peut être motivant). Choisissez ci-dessus à quelle fréquence vous voulez être contacté%{e}.".freeze,
  expli_contact_admin: 'Choisissez ci-dessus comment l’administration de l’atelier peut vous contacter.'. freeze,
  expli_contact_icarien: 'Choisissez ci-dessus comment les autres icariens peuvent vous contacter.'.freeze,
  expli_contact_world: 'Choisissez ci-dessus comment les visiteurs quelconques peuvent vous contacter (par exemple par le biais de la <a href="overview/icariens">salle des Icarien·ne·s</a>).'.freeze,
  expli_project_name: "Vous pouvez définir ci-dessus le titre du projet que vous développez en module de suivi de projet.".freeze,

})

ERRORS.merge!({
  no_module_no_titre_projet: 'Vous n’avez pas de module courant, vous ne pouvez pas définir de titre.'.freeze
})
