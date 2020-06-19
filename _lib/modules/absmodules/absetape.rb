class AbsEtape < ContainerClass

# Pour trouver les travaux type
# Note : maintenant, ça ne sert plus qu'à récupérer les objectifs
REG_TRAVAIL_TYPE = /travail_type\((.*?)\)/
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  def table
    @table ||= 'absetapes'
  end #/ table

end # /<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

def absmodule
  @absmodule ||= AbsModule.get(absmodule_id)
end #/ absmodule

# Retourne la liste des travaux types, c'est-à-dire un Array d'instances
# {TravailType}
def travaux_type
  @travaux_type ||= begin
    data[:travail].scan(REG_TRAVAIL_TYPE).to_a.collect do |match|
      match = match.first
      rubrique, fichier = match.strip.gsub(/[ ']/,'').split(',')
      TravailType.get_by_name(rubrique, fichier)
    end
  end
end #/ travaux_type

def objectifs
  @objectifs ||= ([objectif]+travaux_type.collect{|wt|wt.objectif}).compact.uniq
end #/ objectifs

end #/IcEtape
