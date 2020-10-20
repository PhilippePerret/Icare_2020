# encoding: UTF-8
# frozen_string_literal: true
=begin
  Données des questions/réponses concernant le concours.
=end
QUESTIONS_REPONSES = [
  {
    question: "Où trouver le formulaire d'inscription ?",
    reponse: "Le formulaire d'inscription se trouve à l'adresse #{CONCOURS_SIGNUP.with("https://www.atelier-icare.net/concours/inscription")}."
  },
  {
    question: "Où trouver le formulaire d'identification (une fois que l'on est inscrit) ?",
    reponse: "Le formulaire d'identification se trouve à l'adresse #{CONCOURS_LOGIN.with("https://www.atelier-icare.net/concours/identification")}."
  },
  {
    question: "À quoi doit ressembler le fichier à envoyer ?",
    reponse: "Vous trouverez une explication précise sur le page #{DOSSIER_LINK.with("https://www.atelier-icare.net/concours/dossier")} et même un modèle à télécharger."
  },
  {
    question: "Doit-on obligatoirement développer le projet qui a remporté le concours ?",
    reponse: "Non, il n'y a aucune obligation. Le concours permet de gagner un temps de développement à l'atelier avec le projet de son choix."
  },
  {
    question: "Peut-on cosigner le synopsis présenté au concours ?",
    reponse: "Tout à fait. Il suffit, dans le #{DOSSIER_LINK}, d'indiquer le patronyme des co-auteur·e·s."
  },
  {
    question: "Comment seront annoncés les résultats ?",
    reponse: "Comme l'indique le #{REGLEMENT_LINK}, ces résultats seront annoncés sur le site de l'atelier ainsi que par un mail transmis à toutes et tous les concurrents."
  },
  {
    question: "Peut-on participer quand on est icarienne ou icarien ?",
    reponse: "Bien entendu ! :-D L'inscription est même facilitée quand vous êtes icarienne ou icarien"
  },
  {
    question: "Faut-il être icarien pour participer ?",
    reponse: "Définitivement : non. Mais on peut bien entendu être icarien et participer. Se rapporter au #{REGLEMENT_LINK} pour les détails."
  },
  {
    question: "A-t-on plus de chance d'être sélectionné si l'on est icarien ?",
    reponse: "Nous aimerions vous dire “oui” mais la réponse honnête est “non”. Les synopsis seront vraiment estimés à leur plus juste valeur. Et puis les membres du jury, exception faite de Phil, ne connaissent pas ces icariennes ou icariens ne peuvent donc pas être influencés."
  },
  {
    question: "Quand sera remise la fiche de lecture ?",
    reponse: "Le délai dépendra de la participation au concours. Il sera donc fixé au moment des résultats (ou peu avant). Quoi qu'il en soit, les organistateurs feront tout pour que cette fiche soit remise dans les trois mois suivant la remise des prix."
  },
  {
    question: "J'ai perdu mon numéro d'inscription, comment le récupérer ?",
    reponse: "C'est très simple : rejoignez le #{CONCOURS_SIGNUP}, tapez votre adresse mail et cliquez le bouton “#{UI_TEXTS[:bouton_recup_numero]}”."
  },
  {
    question: "Je ne sais pas produire un fichier PDF… Comment faire ?",
    reponse: "Heureusement, il existe sur YouTube ou ailleurs de nombreux tutoriels expliquant cette démarche avec précision. Tapez par exemple sur google : “[Votre logiciel] exporter en PDF” (par exemple “LibreOffice exporter PDF”) et vous devriez trouver votre bonheur."
  },
  {
    question: "Comment détruire son inscription ?",
    reponse: "Pour détruire votre inscription, rejoignez votre espace après vous être identifié·e. En bas de la page, vous trouverez un bouton pour détruire complètement votre inscription."
  }

]
