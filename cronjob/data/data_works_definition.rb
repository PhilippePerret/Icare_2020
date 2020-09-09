# encoding: UTF-8
DATA_WORKS_FIRST_DEFINITION = [
  {id:'mail_actu_quotidien', every: 1.day, at:2, exec:'CJActualites.traite_mail_quotidien', required:'actualites'},
  {id:'mail_actu_hebdo', day:6, at:2, exec:'CJActualites.traite_mail_hebdomadaire', required:'actualites'},
  {id:'divers_jobs', every: 1.day, at:3, exec:'Cronjob.nettoyage_quotidien', required:'jobs'},
  {id:'nettoyage_hebdo', every:7.days, at:1, exec:'Cronjob.nettoyage_hebdomadaire', require:'jobs'},
  {id:'rapport_complet', every: 1.day, at:4, exec:'Report.send'}
]

# Pour ajouter des travaux lorsque les travaux ont déjà été lancés
DATA_ADDED_WORKS = []
