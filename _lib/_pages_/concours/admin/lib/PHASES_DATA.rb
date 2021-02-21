# encoding: UTF-8
# frozen_string_literal: true
class Concours
PHASES_DATA = {
  0 => {name: "En attente", name_current:"En attente", name_done: "Préparé"},
  1 => {name: "Lancer et annoncer le concours", name_current:"Concours lancé et annoncé", name_done: "Concours en cours"},
  2 => {name: "Annoncer l'échéance des dépôts", name_current: "Première sélection en cours", name_done: "Première sélection effectuée"},
  3 => {name: "Annoncer fin de présélection", name_current: "Sélection finale en cours", name_done: "Sélection finale effectuée"},
  5 => {name: "Annoncer le palmarès", name_current:"Annonce du palmarès en cours", name_done: "Palmarès annoncé"},
  8 => {name: "Annoncer fin officielle du concours", name_current:"Annonce de la fin du concours", name_done: "Fin officielle du concours"},
  9 => {name: "Nettoyer le concours", name_current:"Nettoyage du concours en cours", name_done:"Concours nettoyé"}
}
PHASES_DATA[0].merge!(operations:[
  {name:"Le concours ne peut s'atteindre que depuis le plan", info:true},
  {name:"Un panneau minimal permet de s'inscrire à la prochaine session et de lire le règlement", info:true}
])
PHASES_DATA[1].merge!(operations: [
  {name:"Présence de la “pub” en bas à gauche des premières pages", info:true},
  {name:"Accueil : affichage du panneau avec le nombre d'inscrits, le thème et l'échéance etc.", info:true},
  {name:"Espace personnel : possibilité d'envoyer son fichier", info:true},
  {name:"📤 Envoi du mail d'annonce de lancement à tous les icariens", method: :send_mail_icariens_annonce_start},
  {name:"📤 Envoi du mail d'annonce de lancement à tous les concurrents", method: :send_mail_concurrents_annonce_start},
  {name:"📤 Envoi du mail d'annonce de lancement à tous les membres du jury", method: :send_mail_jury_annonce_start},
  {name:"📣 Actualité annonçant l'ouverture du concours", method: :add_actualite_concours_start}
])
PHASES_DATA[2].merge!(operations:[
  {name:"📤 Envoi du mail aux concurrents annonçant la fin de l’échéance", method: :send_mail_concurrents_echeance},
  {name:"📤 Envoi du mail aux jurés annonçant la fin de l'échéance", method: :send_mail_jury_echeance},
  {name:"Vérification du réglage de la conformité de tous les fichiers de candidature", method: :check_reglage_conformite, explication:"Avant de passer à cette étape, il convient de s'assurer que tous les fichiers soient marqués conformes (1) ou non conformes (2), mais en aucun cas 0."},
  {name:"Retrait du formulaire pour envoyer son dossier", info: true},
  {name:"📣 Actualité annonçant la fin de l'échéance du concours", method: :add_actualite_concours_echeance}
])
PHASES_DATA[3].merge!(operations:[
  {name:"📋 Production du fichier de données Palmarès contenant les résultats provisoires", method: :consigne_resultats_in_file_palmares},
  {name:"📊 Production du tableau des présélectionnés et non retenus", method: :build_tableau_preselections_palmares},
  {name:"📤 Envoi du mail aux concurrents annonçant les résultats de la pré-sélection", method: :send_mail_concurrents_preselection},
  {name:"📤 Envoi du mail aux membres des deux jurys", method: :send_mail_jury_preselection},
  {name:"📣 Actualité annonçant la fin des présélections", method: :add_actualite_concours_fin_preselection},
  {name:"Panneau dans la section “Résultats” pour voir les pré-sélections", info: true}
])
PHASES_DATA[5].merge!(operations:[
  {name:"📤 Envoi du mail aux concurrent annonçant le palmarès final", method: :none},
  {name:"📊 Production du tableau des lauréats finaux", method: :build_tableau_laureats_palmares},
  {name:"Construction des fiches de lecture de chaque concurrent", method: :none},
  {name:"Affichage de la fiche de lecture sur l'espace personnel", method: :none}
])
PHASES_DATA[8].merge!(operations:[
  {name:"📤 Envoi du mail de remerciement (et félicitations) à tous concurrents", method: :none},
  {name:"📤 Envoi du mail de remerciement aux jurés", method: :none},
  {name:"Le concours n'est plus annoncé sur l'atelier", method: :none}
])
PHASES_DATA[9].merge!(operations:[
  {name:"Mise des dossiers de côté (zippés)", method: :none}
])

end #/Concours
