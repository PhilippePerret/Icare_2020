class IcEtape < ContainerClass
  class << self
    def table
      @table ||= 'icetapes'
    end #/ table

    # Création d'une étape pour un IcModule
    # +params+
    #   :numero (le numéro de l'étape) ou :absetape_id (l'id absolu)
    #
    # +return+ ID de la nouvelle icetape
    def create_for(icmodule, params)
      if params.key?(:numero)
        absetape = icmodule.absmodule.get_absetape_by_numero(params[:numero])
      elsif params.key?(:absetape_id)
        absetape = AbsEtape.get(params[:absetape_id])
      else
        raise "Il faut indiquer l'étape absolue à prendre.".freeze
      end
      now = Time.now.to_i
      return create_in_db({
        icmodule_id:  icmodule.id,
        absetape_id:  absetape.id,
        user_id:  icmodule.owner.id,
        numero:  absetape.numero,
        started_at:   now,
        expected_end: now + (absetape.duree).days,
        status: 1
      })
    end #/ create_for

    # Crée l'icetape et retourne le nouvel identifiant
    def create_in_db(data)
      return db_compose_insert('icetapes'.freeze, data)
    end #/ create_in_db

  end # /<< self


# ---------------------------------------------------------------------
#
#     INSTANCE
#
# ---------------------------------------------------------------------

def ref
  @ref ||= "étape “#{numero}. #{titre}”#{f_id}</span> du #{icmodule.ref}".freeze
end #/ ref

# Retourne la liste des instances IcDocuments de l'étape
def documents
  @documents ||= begin
    request = "SELECT * FROM icdocuments WHERE icetape_id = #{id}".freeze
    db_exec(request).collect { |ddoc| IcDocument.instantiate(ddoc) }
  end
end #/ documents

# Raccourcis (d'absetape)
def titre
  @titre ||= absetape.titre
end #/ titre

def absetape
  @absetape ||= AbsEtape.get(data[:absetape_id])
end #/ absmodule

def icmodule
  @icmodule ||= IcModule.get(data[:icmodule_id])
end #/ icmodule

# Cf. le mode d'emploi pour le détail
def status
  @status ||= data[:status]
end #/ status

end #/IcEtape
