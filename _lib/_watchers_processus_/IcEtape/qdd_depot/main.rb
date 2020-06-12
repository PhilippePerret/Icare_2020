# encoding: UTF-8
require_module('icmodules')
class Watcher < ContainerClass
  def qdd_depot
    proceder_au_depot_des_documents
  end # / qdd_depot
  def contre_qdd_depot
    message "Je dois jouer le contre processus IcEtape/contre_qdd_depot"
  end # / contre_qdd_depot

  def proceder_au_depot_des_documents
    # Déposer les documents bien nommés sur le QDD
    # TODO

    # Finir le cycle de l'étape
    # TODO

    # Les tickets qui doivent servir à l'user, dans son mail,
    # pour valider ses documents
    # TODO
    #
  end #/ proceder_au_depot_des_documents
end # /Watcher < ContainerClass
