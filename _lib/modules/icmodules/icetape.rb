# encoding: UTF-8
# frozen_string_literal: true

# Notamment pour le cronjob
require './_lib/required/__first/ContainerClass_definition'

class IcEtape < ContainerClass
  class << self
    def table
      @table ||= 'icetapes'
    end #/ table

    # Création d'une étape pour un IcModule
    #
    # - Création de l'enregistrement dans la table icetapes
    # - Création d'un watcher permettant à l'icarien de remettre
    #   son travail.
    #
    # +params+
    #   :numero (le numéro de l'étape) ou :absetape_id (l'id absolu)
    #
    # +return+ L'instance IcEtape de la nouvelle icetape
    #
    def create_for(icmodule, params)
      if params.key?(:numero)
        absetape = icmodule.absmodule.get_absetape_by_numero(params[:numero])
      elsif params.key?(:absetape_id)
        absetape = AbsEtape.get(params[:absetape_id])
      else
        raise "Il faut indiquer l'étape absolue à prendre."
      end
      now = Time.now.to_i
      data_newetape = {
        icmodule_id:  icmodule.id,
        absetape_id:  absetape.id,
        user_id:      icmodule.owner.id,
        started_at:   now,
        expected_end: now + (absetape.duree).days,
        status: 1
      }
      icetape_id = db_compose_insert('icetapes', data_newetape)
      data_newetape.merge!(id: icetape_id)

      # Watcher pour dire à l'icarien de rejoindre sa partie travail et
      # d'utiliser le bouton "Remettre son travail" pour le remettre
      icmodule.owner.watchers.add(wtype:'send_work', objet_id:icetape_id)

      return IcEtape.instantiate(data_newetape)
    end #/ create_for

    # Crée l'icetape et retourne le nouvel identifiant
    def create_in_db(data)
      return
    end #/ create_in_db

  end # /<< self


# ---------------------------------------------------------------------
#
#     INSTANCE
#
# ---------------------------------------------------------------------

def ref
  # log("--- [dans ref] data:#{data.inspect}")
  @ref ||= "étape #{numero}. “#{titre}”#{f_id}</span> du #{icmodule.ref}"
end #/ ref

# Retourne la liste des instances IcDocuments de l'étape
def documents
  @documents ||= begin
    request = "SELECT * FROM icdocuments WHERE icetape_id = #{id}"
    db_exec(request).collect { |ddoc| IcDocument.instantiate(ddoc) }
  end
end #/ documents
alias :icdocuments :documents

# Raccourcis (d'absetape)
def titre   ; @titre  ||= absetape.titre    end
def numero  ; @numero ||= absetape.numero   end

def absetape
  @absetape ||= begin
    # log("[absetape] ID: #{id}")
    # log("[absetape] data : #{data.inspect}")
    if data.nil?
      err = <<-LOG

Problème avec l'icetape ##{id} qui n'a pas de data.

      LOG
      log(err)
    end
    ae = AbsEtape.get(data[:absetape_id])
    if ae.nil?
      err = <<-LOG

Problème avec l'icetape ##{data[:absetape_id]} qui est introuvable.

      LOG
      log(err)

    end
    ae
  end
end #/ absetape

def absmodule
  @absmodule ||= absetape.absmodule
end #/ absmodule

def icmodule
  @icmodule ||= IcModule.get(data[:icmodule_id])
end #/ icmodule

# # Cf. le mode d'emploi pour le détail
# def status
#   @status ||= data[:status]
# end #/ status

end #/IcEtape
