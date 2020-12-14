# encoding: UTF-8
# frozen_string_literal: true
=begin
  Constantes pour les outils icariens.
=end
TYPES_ACTUS = Actualite::DATA_ACTU.collect do |typ, dactu|
  [typ, dactu[:name]]
end
DATA_OPERATIONS_ICARIENS = {
  # Dans 'required', il ne faut mettre que les champs absolument requis.
  # Pour les autres, la simple définition du texte du champ l'ajoutera
  'add_actualite'   => {id:'add_actualite',   name:'Ajouter actualité',         for: :all,      required: [:long_value], short_value:"Date JJ/MM (si différente d’aujourd’hui)", select_value: {values: TYPES_ACTUS, default:"SIMPLEMESS", message:"Type de l’actualité"}, long_value: "Message d'actualité à attribuer à l'icarien sélectionné (ou à Phil si aucun). Le message sera évalué, donc on peut utiliser des `\#{icarien.pseudo}` à l'intérieur (code ruby évalué comme dans un String normal)."},
  'arret_module'    => {id:'arret_module',    name:'Arrêt module',              for: :actif,    required: [:icarien], long_value: 'Si un texte (en HTML) est écrit ci-dessous, il sera considéré comme le supplément d’un mail à envoyer à l’icarien du module l’informant de l’arrêt/la fin de son module. Dans le cas contraire, le module sera simplement arrêté.'},
  'change_module'   => {id:'change_module',   name:'Changement module',         for: :actif,    required: [:short_value, :icarien, :medium], short_value: 'ID du nouveau module absolu d’apprentissage (on peut le trouver avec l’outils Bureau > Édition des étapes, c’est le nombre entre parenthèses après le nom du module)', medium_value: 'Numéro de la nouvelle étape dans le nouveau module (on peut l’obtenir avec l’outil Burea > Édition des étapes)'},
  'code_sur_table'  => {id:'code_sur_table',  name:'Exec code on data',         for: :all,      required: [:long_value], short_value: nil, medium_value: nil, long_value: "Code à exécuter <strong>sur chaque icarien de la table</strong>, sur la table #{ONLINE ? 'ONLINE' : 'OFFLINE'} puisse que vous êtes #{ONLINE ? 'ONLINE' : 'OFFLINE'}.<br><br><code>User.each do |cu|<br>&nbsp;&nbsp;cu.&lt;what&gt;</code>"},
  'destroy_user'    => {id:'destroy_user',    name:'Destruction totale',        for: :all,      required: [:short_value, :icarien], short_value: 'ID de l’icarien choisi (pour confirmation)', medium_value: nil, long_value: nil},
  'docqdd_name'     => {id:'docqdd_name',     name:'Nom document QDD',          for: :all,      required: [:short_value], short_value: 'ID du document dont il faut voir le nom', cb_value: {checked:false, message:"Réparer en cas de problème"}, description: 'Cet outil permet d’obtenir le nom d’un document sur le quai des docs (par exemple pour le déposer à la main lorsqu’un problème est survenu)'},
  'etape_change'    => {id:'etape_change',    name:'Changement d’étape',        for: :actif,    required: [:short_value, :icarien], short_value: 'Numéro de l’étape', long_value: nil},
  'free_days'       => {id:'free_days',       name:'Jours gratuits',            for: :actif,    required: [:short_value, :icarien], short_value: "Nombre de jours gratuits", long_value: "Raison éventuelle du don de jours gratuits (format ERB).", cb_value:{checked:true, message:"Informer l’icarien·ne par mail (avec le message ci-dessus s'il est défini)."}},
  'inject_document' => {id:'inject_document', name:'Document par mail',         for: :actif,    required: [:medium_value, :icarien], medium_value: 'Nom des fichiers, séparés par des ";"'},
  'marquer_detruit' => {id:'marquer_detruit', name:'Marquer détruit',           for: :all,      required: [:short_value], short_value: 'ID de l’icarien, pour confirmation', description:'Cet outil permet de marquer un icarien comme détruit, mais sans le détruire. Toutes ses productions seront simplement marquées comme “anonyme”.'},
  'move_document'   => {id:'move_document',   name:'Déplacement document',      for: [:actif,:inactif,:pause], required: [:short_value, :medium_value, :icarien],     short_value: "ID du document", medium_value: 'ID de l’icetape de destination'},
  'nettoyage_site'  => {id:'nettoyage_site',  name:'Nettoyage du site',         for: :all,      required:[],  long_value:nil, medium_value:nil, short_value:nil},
  'pause_module'    => {id:'pause_module',    name:'Mise en pause module',      for: :actif,    required: [:icarien], short_value: "X pour ne pas envoyer l'email"},
  'restart_module'  => {id:'restart_module',  name:'Reprise après pause',       for: :pause,    required: [:icarien]},
  'temoignage'      => {id:'temoignage',      name:'Nouveau témoignage',        for: :all,      required: [:long_value, :icarien], short_value: 'ID du témoignage si c’est une modification', medium_value: nil, long_value: "Code HTML du témoignage à ajouter"},
  'titre_projet'    => {id:'titre_projet',    name:'Définir titre projet',      for: [:actif, :inactif, :pause], required: [:icarien], short_value: 'ID du IcModule si ça n’est pas le courant', medium_value: 'Titre du projet (ou rien pour le supprimer)'},
  'travail_propre'  => {id:'travail_propre',  name:'Travail propre',            for: :actif,    required: [:icarien], short_value: nil, long_value: "Description du travail propre (format ERB).<br>Laisser vide et cliquez sur “Exécuter” pour charger le travail qui peut déjà exister."},
}
