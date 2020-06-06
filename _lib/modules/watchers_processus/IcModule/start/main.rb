# encoding: UTF-8
=begin
  Watcher IcModule.start
=end
require_module('absmodules')
require_module('icmodules')
class Watcher < ContainerClass
  def start
    now = Time.now.to_i

    icmodule = objet

    modul_data = {started_at: now}
    owner_data = {icmodule_id: objet_id}

    # Watcher de paiement
    dwatcher  = {objet_id: objet_id}
    dwatcher.merge!(triggered_at: now+10.days) unless owner.real?
    watcher_id = owner.watchers.add('paiement_module', dwatcher)

    # Création de la première étape (avec watcher de dépôt de travail)
    icetape_id = IcEtape.create_for(objet, numero: 1)
    modul_data.merge!(icetape_id: icetape_id)

    # Watcher de remise des documents
    watcher_id = owner.watchers.add('send_work', objet_id: icetape_id)

    # On peut définir les nouvelles données de l'icmodule
    icmodule.set(modul_data)
    # On peut définir les nouvelles données de l'icarien
    owner.set(owner_data)

    message "Votre module a été démarré ! Vous pouvez voir le premier travail dans votre section « Travail courant » que vous trouverez à l'accueil de votre bureau.".freeze
  end #/ start
end #/IcModule


class User

end #/User
