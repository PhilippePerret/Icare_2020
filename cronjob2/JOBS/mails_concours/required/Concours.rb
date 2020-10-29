# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension classe Concours pour le cronjob
=end
require_site('./_lib/_pages_/concours/xrequired/Concours')
class Concours
class << self
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# OUT   {Integer} Nombre de jours avant l'échéance
def nombre_jours_echeance
  @nombre_jours_echeance ||= begin
    n = Cronjob.current_time
    n = Time.new(n.year, n.month, n.day,0,0,0)
    ((date_echeance.to_i - n.to_i).to_f / 1.day).to_i
  end
end #/ nombre_jours_echeance

# OUT   {String} Message de conseil en fonction de l'échéance restante
def conseil_per_nombre_jours_echeance
  case nombre_jours_echeance
  when (0..2)   then "c'est-à-dire qu'il faut absolument conclure !"
  when (3...7)  then "vous devriez être en train de boucler définitivement votre dossier !"
  when 7        then "il vous reste encore cette semaine pour boucler votre dossier !"
  when (7..15)  then "vous devriez commencer à penser à la finalisation de votre fichier de candidature (le fichier lui-même, avec la note d'intention, la courte biographie, etc. et le synopsis bien sûr)."
  when (15..30) then "vous devriez être en train de parachever votre synopsis."
  when (30..60) then "votre histoire est prête, vous devriez être en train de rédiger le synopsis lui-même."
  when (60..90) then "vous devriez être en train de concevoir l'histoire, sa forme, ses personnages, etc. autour du thème imposé pour cette session #{Concours.current.annee}, #{Concours.current.theme.downcase}."
  else "vous avez encore tout le temps de chercher la bonne histoire, autour du thème “#{Concours.current.theme.downcase}” proposé cette année."
  end
end #/ conseil_per_nombre_jours_echeance

end #/Concours
