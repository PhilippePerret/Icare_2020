# encoding: UTF-8
DATA_WORKS_FIRST_DEFINITION = [
  {id: 'nettoie_signups_folder', every: 10.days, at:1, exec:'puts "Je dois nettoyer le dossier signup"', require:'folders'},
  {id: 'mail_actu_quotidien', every: 1.day, at:2, exec:'CJActualites.mail_quotidien', require:'actualites'},
  {id: 'mail_actu_hebdo', every: 7.days, at:2, exec:'CJActualites.mail_hebdomadaire', require:'actualites'}
]
