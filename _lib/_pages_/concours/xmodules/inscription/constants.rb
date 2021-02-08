# encoding: UTF-8
# frozen_string_literal: true
=begin
  Constantes pour l'inscription
=end

ERRORS.merge!({
  concours:{
    signup:{
      errors:{
        patronyme_required: "Le patronyme est absolument requis",# par javascript
        is_icarien: "Il semblerait que vous soyez icarien… Identifiez-vous pour vous inscrire d’un clic au concours.",
        already_concurrent: "Vous êtes déjà concurrent du concours.",
        patronyme_too_long: "Votre patronyme ne doit pas excéder 200 caractères.",# par javascript
        patronyme_exists: "Ce patronyme est déjà utilisé…",
        mail_required: "Le mail est absolument requis", # par javascript
        mail_too_long: "Ce mail est trop long…", # par javascript
        invalid_mail: "Le mail est invalide…", # par javascript
        mail_exists: "Désolé mais ce mail est déjà utilisé par une inscription…",
        confirmation_mail_doesnt_match: "",
        approbation_rules_required: "Il faut approuver le règlement en cochant la case.",# par javascript
      }
    }
  }
})

# Pour savoir où le concurrent a entendu parler de l'atelier
CONCOURS_KNOWLEDGE_VALUES = [
  ["none", "Vous avez entendu parler de ce concours par…"],
  ["google", "une recherche google"],
  ["forum", "un forum d'écriture"],
  ["icare", "l'atelier Icare"],
  ["facebook", "un groupe Facebook"],
  ["someone", "bouche à oreille"],
  ["medias", "les médias"],
  ["autre", "un autre moyen"]
]
