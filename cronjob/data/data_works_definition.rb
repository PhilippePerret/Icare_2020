# encoding: UTF-8
DATA_WORKS_FIRST_DEFINITION = [
  {id: 'nettoie_signups_folder', every: 10.days, at:1, exec:'CJFolders.nettoie("tmp/signups")', required:'folders'},
  {id: 'mail_actu_quotidien', every: 1.day, at:2, exec:'CJActualites.traite_mail_quotidien', required:'actualites'},
  {id: 'mail_actu_hebdo', day:6, at:2, exec:'CJActualites.traite_mail_hebdomadaire', required:'actualites'}
]

# Pour ajouter des travaux lorsque les travaux ont déjà été lancés
DATA_ADDED_WORKS = []
