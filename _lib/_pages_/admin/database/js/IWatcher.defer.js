"use strict";
class IWatcher extends Objet {
/**
 * CLASSE
**/
static get color(){return 'mediumaquamarine'}
static get table(){return 'watchers'}

/**
 * INSTANCE
**/
constructor(data, owner) {
  super(data, owner)
}
get ref(){
  return this._ref || (this._ref = `<span class="ref"><span class="nature">watcher</span><span class="name">${this.data.absdata.titre}</span><span class="id">#${this.data.objet_id}</span></span>`)
}

} // class IWatcher

class FicheIWatcher extends Fiche {
constructor(data) {
  super(data)
}

/**
 * Construction des données propres au watcher
**/
build_all_own_data(){
  this.build_own_data("WType/wtype", this.data.wtype)
  this.build_own_data("Propriétaire/user_id", this.objet.owner.as_link)
  this.build_own_data("Créé le/created_at", this.data.created_at, 'date-time')
  this.build_own_data("Modifié le/updated_at", this.data.updated_at, 'date-time')
  this.build_own_data("Déclenchement/triggered_at", this.data.triggered_at, 'date-time')
  this.build_own_data("Paramètres/params", this.data.params)
  // Les données absolues du watcher

  // Pour atteindre l'objet visé (note : pour avoir sa nature, on doit charger
  // la donnée qui définit l'objet en fonction du wtype)
  this.build_own_data("Objet", "[TODO à définir - lien]")
}

/**
 * Construction des outils propres aux watchers TODO
**/
build_own_tools(){}

/**
 * Construit les données supplémentaires
 *
 * Pour les document, ça ne correspond à rien (ou alors on pourrait faire
 * document original et commentaires)
 */
extra_build(){
}
} // class FicheIWatcher
