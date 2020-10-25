# encoding: UTF-8
# frozen_string_literal: true
class Concours
STEPS_DATA = {
  0 => {name: "En attente", name_current:"En attente", name_done: "Préparé"},
  1 => {name: "Lancer et annoncer le concours", name_current:"Lancement du concours en cours", name_done: "Concours lancé et annoncé"},
  2 => {name: "Statuer l'échéance des rendus", name_current: "Première sélection en cours", name_done: "Première sélection effectuée"},
  3 => {name: "Annoncer première sélection", name_current: "Seconde sélection en cours", name_done: "Sélection finale effectuée"},
  5 => {name: "Annoncer le palmarès", name_current:"Annonce du palmarès en cours", name_done: "Palmarès annoncé"},
  8 => {name: "Annoncer fin officielle du concours", name_current:"Annonce de la fin du concours", name_done: "Fin officielle du concours"},
  9 => {name: "Nettoyer le concours", name_current:"Nettoyage du concours en cours", name_done:"Concours nettoyé"}
}
STEPS_DATA[0].merge!(operations:[
  {name:"Le concours ne peut s'atteindre que depuis le plan", info:true},
  {name:"Un panneau minimal permet de s'inscrire à la prochaine session et de lire le règlement", info:true}
])
STEPS_DATA[1].merge!(operations: [
  {name:"Présence de la “pub” en bas à gauche des premières pages", info:true},
  {name:"Accueil : affichage du panneau avec le nombre d'inscrits, le thème et l'échéance etc.", info:true},
  {name:"Espace personnel : possibilité d'envoyer son fichier", info:true},
  {name:"📤 Envoi du mail d'annonce de lancement à tous les icariens", method: :send_mail_icariens_annonce_start},
  {name:"📤 Envoi du mail d'annonce de lancement à tous les concurrents", method: :send_mail_concurrents_annonce_start},
  {name:"📤 Envoi du mail d'annonce de lancement à tous les membres du jury", method: :send_mail_jury_annonce_start}
])
STEPS_DATA[2].merge!(operations:[
  {name:"📤 Envoi du mail aux concurrents annonçant l'échéance finale"},
  {name:"📤 Envoi du mail aux jurés annonçant la fin de l'échéance"},
  {name:"Retrait du formulaire pour envoyer son dossier"},
])
STEPS_DATA[3].merge!(operations:[
  {name:"📤 Envoi du mail aux concurrents annonçant les résultats de la première sélection"},
  {name:"Construction du panneau pour voir le résultat des premières sélections"}
])
STEPS_DATA[5].merge!(operations:[
  {name:"📤 Envoi du mail aux concurrent annonçant le palmarès final"},
  {name:"Construction du panneau pour voir les résultats finaux"},
  {name:"Construction des fiches de lecture de chaque concurrent"},
  {name:"Affichage de la fiche de lecture sur l'espace personnel"}
])
STEPS_DATA[8].merge!(operations:[
  {name:"📤 Envoi du mail de remerciement (et félicitations) à tous concurrents"},
  {name:"📤 Envoi du mail de remerciement aux jurés"},
  {name:"Le concours n'est plus annoncé sur l'atelier"}
])
STEPS_DATA[9].merge!(operations:[
  {name:"Mise des dossiers de côté (zippés)"}
])

end #/Concours
