# encoding: UTF-8
=begin
  Constantes pour les outils icariens.
=end
DATA_OPERATIONS_ICARIENS = {
  'add_actualite'   => {id:'add_actualite',   name:'Ajouter actualité'.freeze, long_value: "Message d'actualité à attribuer à l'icarien sélectionné. Le message sera évalué, donc on peut utiliser des `\#{icarien.pseudo}` à l'intérieur (code ruby évalué comme dans un String normal)."},
  'free_days'       => {id:'free_days',       name:'Jours gratuits',        short_value: "Nombre de jours gratuits", long_value: "Raison éventuelle du don de jours gratuits (format ERB)."},
  'travail_propre'  => {id:'travail_propre',  name:'Travail propre',        short_value: nil, long_value: "Description du travail propre (format ERB).<br>Laisser vide et cliquez sur “Exécuter” pour charger le travail qui peut déjà exister."},
  'inject_document' => {id:'inject_document', name:'Document par mail',     medium_value: 'Nom du fichier'},
  'move_document'   => {id:'move_document',   name:'Déplacement document',  short_value: "ID du document", medium_value: 'ID de l’icetape de destination'},
  'etape_change'    => {id:'etape_change',    name:'Changement d’étape',    short_value: 'Numéro de l’étape', long_value: nil},
  'code_sur_table'  => {id:'code_sur_table',  name:'Exec code on data',     short_value: nil, medium_value: nil, long_value: "Code à exécuter <strong>sur chaque icarien de la table</strong>, sur la table #{ONLINE ? 'ONLINE' : 'OFFLINE'} puis vous êtes #{ONLINE ? 'ONLINE' : 'OFFLINE'}.<br><br><code>dbtable_users.select.each do |huser|<br>&nbsp;&nbsp;uid = huser[:id]<br>&nbsp;&nbsp;u = User.new(uid)</code>"},
  'pause_module'    => {id:'pause_module',    name:'Mise en pause module',  short_value: "X pour ne pas envoyer l'email"},
  'restart_module'  => {id:'restart_module',  name:'Reprise après pause'},
  'arret_module'    => {id:'arret_module',    name:'Arrêt module',          long_value: 'Si un texte (en HTML) est écrit ci-dessous, il sera considéré comme le supplément d’un mail à envoyer à l’icarien du module l’informant de l’arrêt/la fin de son module. Dans le cas contraire, le module sera simplement arrêté.'},
  'change_module'   => {id:'change_module',   name:'Changement module',     short_value: 'ID du nouveau module absolu d’apprentissage (on peut le trouver avec l’outils Bureau > Édition des étapes, c’est le nombre entre parenthèses après le nom du module)', medium_value: 'Numéro de la nouvelle étape dans le nouveau module (on peut l’obtenir avec l’outil Burea > Édition des étapes)'},
  'temoignage'      => {id:'temoignage',      name:'Nouveau témoignage',    short_value: 'ID du témoignage si c’est une modification', medium_value: nil, long_value: "Code HTML du témoignage à ajouter"},
  'titre_projet'    => {id:'titre_projet',    name:'Définir titre projet',  short_value: 'ID du IcModule si ça n’est pas le courant', medium_value: 'Titre du projet (ou rien pour le supprimer)'},
  'destroy_user'    => {id:'destroy_user',    name:'Destruction totale',    short_value: 'ID de l’icarien si non choisi dans menu', medium_value: nil, long_value: nil}
}
