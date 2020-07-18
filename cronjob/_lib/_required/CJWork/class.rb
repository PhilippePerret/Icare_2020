# encoding: UTF-8
=begin
  Méthodes de classe de CJWork

=end
class CJWork
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

# Méthode principale qui joue chaque job défini
def run_each_work
  works.each do |wid, work| # wid est un string
    begin
      work.run if work.time_has_come?
    rescue Exception => e
      puts "PROBLÈME AVEC : #{wid} : #{e.message}"
    end
  end
end #/ run_each_work

# Chargement des travaux (définition de DATA_WORKS et self.works)
def load
  if File.exists?(DATA_WORKS_PATH)
    File.open(DATA_WORKS_PATH,'rb') do |f|
      DATA_WORKS.merge!(Marshal.load(f.read))
    end
  else
    DATA_WORKS.merge!(define_init_works)
  end
  # On ajoute les travaux ajoutés
  DATA_WORKS.merge!(added_works) unless added_works.empty?
end #/ load

# Sauvegarde de l'état actuel des travaux
def save
  File.open(DATA_WORKS_PATH,'wb'){|f|Marshal.dump(works,f)}
end #/ save

# Tous les travaux
# Note : c'est cette propriété qui est enregistrée dans DATA_WORKS_PATH
def works
  @works ||= DATA_WORKS
end #/ works

private
  # Définit les jobs et les renvoie
  # Pour la définition des travaux, voir le mode d'emploi
  def define_init_works
    hworks = {}
    [
      {id: 'nettoie_signups_folder', every: 10.days, at: 1}
    ].each do |dwork|
      cj = CJWork.new(dwork)
      hworks.merge!(cj.id => cj)
    end
    return hworks
  end #/ define_init_works

  # Permet d'ajouter des jobs
  def added_works
    {}
  end #/ added_works

end # /<< self
end #/CJWork
