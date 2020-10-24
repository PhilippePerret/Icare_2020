# encoding: UTF-8
# frozen_string_literal: true

ERRORS.merge!({
  concours_patronyme_exists: "Ce patronyme est déjà utilisé…",
  concours_patronyme_too_long: "Patronyme trop long (255 max.).",
  concours_mail_exists: "Désolé mais ce mail est déjà utilisé par une inscription…",
  mail_invalide: "Le mail est invalide…",
  mail_too_long: "Ce mail est trop long…",
})

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
