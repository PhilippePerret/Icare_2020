# encoding: UTF-8
# frozen_string_literal: true
=begin
  Constantes pour les outils icariens.
=end
DATA_OPERATIONS_ICARIENS = {
  'add_actualite'   => {id:'add_actualite',   name:'Ajouter actualité',         for: :all,      required: [:long_value, :medium_value], medium_value:('Type de l’actualité, parmi %s.' % Actualite.types_explained), long_value: "Message d'actualité à attribuer à l'icarien sélectionné. Le message sera évalué, donc on peut utiliser des `\#{icarien.pseudo}` à l'intérieur (code ruby évalué comme dans un String normal)."},
  'arret_module'    => {id:'arret_module',    name:'Arrêt module',              for: :actif,    required: [:icarien], long_value: 'Si un texte (en HTML) est écrit ci-dessous, il sera considéré comme le supplément d’un mail à envoyer à l’icarien du module l’informant de l’arrêt/la fin de son module. Dans le cas contraire, le module sera simplement arrêté.'},
  'change_module'   => {id:'change_module',   name:'Changement module',         for: :actif,    required: [:short_value, :icarien, :medium], short_value: 'ID du nouveau module absolu d’apprentissage (on peut le trouver avec l’outils Bureau > Édition des étapes, c’est le nombre entre parenthèses après le nom du module)', medium_value: 'Numéro de la nouvelle étape dans le nouveau module (on peut l’obtenir avec l’outil Burea > Édition des étapes)'},
  'code_sur_table'  => {id:'code_sur_table',  name:'Exec code on data',         for: :all,      required: [:long_value], short_value: nil, medium_value: nil, long_value: "Code à exécuter <strong>sur chaque icarien de la table</strong>, sur la table #{ONLINE ? 'ONLINE' : 'OFFLINE'} puisse que vous êtes #{ONLINE ? 'ONLINE' : 'OFFLINE'}.<br><br><code>User.each do |cu|<br>&nbsp;&nbsp;cu.&lt;what&gt;</code>"},
  'destroy_user'    => {id:'destroy_user',    name:'Destruction totale',        for: :all,      required: [:short_value, :icarien], short_value: 'ID de l’icarien choisi (pour confirmation)', medium_value: nil, long_value: nil},
  'etape_change'    => {id:'etape_change',    name:'Changement d’étape',        for: :actif,    required: [:short_value, :icarien], short_value: 'Numéro de l’étape', long_value: nil},
  'free_days'       => {id:'free_days',       name:'Jours gratuits',            for: :actif,    required: [:short_value, :icarien], short_value: "Nombre de jours gratuits", long_value: "Raison éventuelle du don de jours gratuits (format ERB)."},
  'inject_document' => {id:'inject_document', name:'Document par mail',         for: :actif,    required: [:medium_value, :icarien], medium_value: 'Nom du fichier'},
  'marquer_detruit' => {id:'marquer_detruit', name:'Marquer détruit',           for: :all,      required: [:short_value], short_value: 'ID de l’icarien, pour confirmation', description:'Cet outil permet de marquer un icarien comme détruit, mais sans le détruire. Toutes ses productions seront simplement marquées comme “anonyme”.'},
  'move_document'   => {id:'move_document',   name:'Déplacement document',      for: [:actif,:inactif,:pause], required: [:short_value, :medium_value, :icarien],     short_value: "ID du document", medium_value: 'ID de l’icetape de destination'},
  'nettoyage_site'  => {id:'nettoyage_site',  name:'Nettoyage du site',         for: :all,      required:[],  long_value:nil, medium_value:nil, short_value:nil},
  'pause_module'    => {id:'pause_module',    name:'Mise en pause module',      for: :actif,    required: [:icarien], short_value: "X pour ne pas envoyer l'email"},
  'restart_module'  => {id:'restart_module',  name:'Reprise après pause',       for: :pause,    required: [:icarien]},
  'temoignage'      => {id:'temoignage',      name:'Nouveau témoignage',        for: :all,      required: [:long_value, :icarien], short_value: 'ID du témoignage si c’est une modification', medium_value: nil, long_value: "Code HTML du témoignage à ajouter"},
  'titre_projet'    => {id:'titre_projet',    name:'Définir titre projet',      for: [:actif, :inactif, :pause], required: [:icarien], short_value: 'ID du IcModule si ça n’est pas le courant', medium_value: 'Titre du projet (ou rien pour le supprimer)'},
  'travail_propre'  => {id:'travail_propre',  name:'Travail propre',            for: :actif,    required: [:long_value, :icarien], short_value: nil, long_value: "Description du travail propre (format ERB).<br>Laisser vide et cliquez sur “Exécuter” pour charger le travail qui peut déjà exister."},
}
