# encoding: UTF-8
=begin
  Extension de Cronjob pour faire le rapport complet

  Le rapport complet consiste à faire un point quotidien de l'atelier
  - erreurs du traceur (même celles déjà vues)
  - raccourcissement du traceur
=end
class Cronjob
class << self

  # Divers jobs à effectuer
  def divers_jobs
    Report.add('Réduction du traceur', type: :operation)
    CJTraceur.reduce
  end #/ rapport_complet

end # /<< self
end #/Cronjob
