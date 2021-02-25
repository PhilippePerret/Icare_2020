# encoding: UTF-8
# frozen_string_literal: true

# Notamment pour le cronjob
require './_lib/required/__first/ContainerClass_definition'

require_module('absmodules')
class IcModule < ContainerClass
class << self

  def table
    @table ||= 'icmodules'
  end #/ table

  # Méthode qui crée un module pour l'icarien data[:user]
  # +data+
  #     :user           {User|Integer} L'icarien du module ou son identifiant
  #     :absmodule_id   {Integer} Identifiant du module
  #
  # Retourne l'icmodule créé.
  #
  def create_new_for(data)
    require_module('watchers') unless defined?(Watcher)
    owner = data.delete(:user)
    data[:user_id] ||= owner.id
    # On crée l'enregistrement dans la table
    icmodule_id = create_in_db(data)
    # Quel que soit le module, un watcher de démarrage
    owner.watchers.add(:start_module, {objet_id: icmodule_id})
    # Et un watcher de paiement
    # Note : non, c'est seulement lorsqu'elle le démarrera

    return icmodule_id
  end #/ create

  def create_in_db(data)
    now = Time.now.to_i
    data.merge!(
      options:    '0'*16,
      created_at: now.to_s,
      updated_at: now.to_s
    )
    new_id = db_compose_insert('icmodules', data)
    return new_id
  end #/ create_in_db

end # /<< self

# ---------------------------------------------------------------------
#
#     INSTANCE
#
# ---------------------------------------------------------------------
def ref
  @ref ||= "module “#{name}”#{f_id}"
end

def suivi?
  absmodule.suivi?
end

def absmodule
  @absmodule ||= AbsModule.get(data[:absmodule_id])
end

def name
  @name ||= absmodule.name
end

# Étape courante
def icetape
  @icetape ||= IcEtape.get(icetape_id)
end

def montant_humain
  @montant_humain ||= "#{absmodule.tarif}#{ISPACE}€"
end

# Retourne la date de prochain paiement
# Noter qu'elle existe dans deux cas :
# 1) c'est un module à durée déterminée et il n'a pas encore été payé
# 2) c'est un module de suivi de projet
def paiement_time
  watcher_paiement && watcher_paiement[:triggered_at].to_i
end

def watcher_paiement
  @watcher_paiement ||= db_get('watchers', {objet_id:id, wtype:'paiement_module'})
end

# Retourne la valeur corrigées des pauses. Certaines, pour une raison inconnue,
# sont enregistrées comme "[{". On passe donc  par ici pour corriger cette
# erreur si elle est détectée.
def pauses
  @pauses ||= begin
    if data[:pauses] == '[{'
      db_compose_update('icmodules', id, {pauses: nil})
      nil
    else
      data[:pauses]
    end
  end
end #/ pauses

end #/IcModule
