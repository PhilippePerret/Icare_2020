# encoding: UTF-8
=begin

Données pour la table des matières

=end
class Aide

  DATA_TDM = {
    # ---------------------------------------------------------------------
    'primo' => {hname: 'Premiers arrivants'.freeze, titre:true},
    '200.primo' => {hname: 'Liste et tarif des modules d’apprentissage et d’accompagnement'.freeze, id:200},
    '20.primo'  => {hname:'Poser sa candidature'.freeze, id:20},
    '12.primo'  => {hname:'Navigation sur le site'.freeze, id:12},
    '81.primo'  => {hname: 'Conditions Générales d’Utilisation', id:81},
    '82.primo'  => {hname:'Politique de confidentialité', id:82},

    # ---------------------------------------------------------------------
    'site' => { hname:'Le Site de l’atelier', titre:true},
    1       => { hname: 'Où aller après l’identification'},
    4       => { hname: 'Fréquence des mails d’activité'},
    # ---------------------------------------------------------------------

    'inscription' => {hname: 'L’inscription', titre: true},
    20      => {hname: 'Poser sa candidature'},
    100     => {hname: 'Documents de présentation'},

    # ---------------------------------------------------------------------
    # Tout ce qui concerne l'interactivité
    'interactivite' => {hname:'L’Interactivité', titre:true},
    500 => {hname: 'Les discussions du frigo'},
    5   => {hname: 'Comment peut vous contacter un·e icarien·ne ?'},
    52  => {hname: 'Comment peut vous contacter le reste du monde ?'},
    50  => {hname: 'Contacter un·e icarien·ne par son Frigo'},
    51  => {hname: 'Contacter un·e icarien·ne en tant que simple visiteur'},

    # ---------------------------------------------------------------------


    'interface' => { hname:"L'Interface", titre:true},
    '11.bis'    => {hname: 'Constitution du bureau de travail', id: 11},
    12          => {hname:'Navigation sur le site'.freeze},

    # ---------------------------------------------------------------------
    # Tout ce qui concerne le travail sur un module
    'module_apprentissage' => {hname: 'Les modules d’accompagnement et d’apprentissage', titre: true},
    200 => {hname: 'Liste et tarif des modules d’accompagnement et d’apprentissage'},
    201 => {hname: 'Durée réelle des modules'},
    80  => {hname: 'Paiement du module ou de l’échéance'},
    # ---------------------------------------------------------------------

    # ---------------------------------------------------------------------
    'travail' => {hname: 'Le travail au sein de l’atelier', titre: true},
    11  => {hname: 'Constitution du bureau de travail'},
    410 => {hname: 'Échéance du travail'},
    35  => {hname: 'Transmission des documents de travail'},
    36  => {hname: 'Comment recharger ses commentaires ?'},
    710 => {hname: 'Les outils d’écriture'},

    # ---------------------------------------------------------------------
    'documents'     => {hname: 'Les documents de travail', titre: true},
    31  => {hname: 'Code couleur pour les commentaires'},
    37  => {hname: 'Abréviations dans les commentaires'},
    38  => {hname: 'Comment numéroter ses versions ?'},
    32  => {hname: 'Nommage de ses documents de travail'},
    33  => {hname: 'Rédaction des documents de travail'},
    '35.bis'  => {hname: 'Ajout de documents', id:35},
    30  => {hname: 'Pourquoi partager ses documents ?'},
    10  => {hname: 'Auto-estimation de ses documents'},
    34  => {hname: 'Types de documents'},
    # ---------------------------------------------------------------------

    # ---------------------------------------------------------------------
    'quaidesdocs'   => {hname: 'le Quai des docs', titre: true},
    600 => {hname: 'Qu’est-ce que le Quai des docs ?'},
    605 => {hname: 'Cotage des documents'.freeze},
    602 => {hname: 'Déposer ses documents'.freeze},
    # ---------------------------------------------------------------------


    # ---------------------------------------------------------------------
    'divers'  => {hname: 'Divers', titre: true},
    701 => {hname: 'Le Grand Livre des Lois de la Narration'},
    81  => {hname: 'Conditions Générales d’Utilisation'},
    82  => {hname:'Politique de confidentialité'}
  }

end #/Aide
