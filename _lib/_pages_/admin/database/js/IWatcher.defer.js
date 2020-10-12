"use strict";
class IWatcher extends Objet {
/**
 * CLASSE
**/
static get color(){return 'mediumaquamarine'}
/**
 * INSTANCE
**/
constructor(data, owner) {
  super(data, owner)
}
get ref(){
  return this._ref || (this._ref = `<span class="ref"><span class="nature">watcher</span><span class="name">${this.data.wtype}</span><span class="id">#${this.data.objet_id}</span></span>`)
}

} // class IWatcher

class FicheIWatcher extends Fiche {
constructor(data) {
  super(data)
}

/**
 * Construit les données supplémentaires
 *
 * Pour les document, ça ne correspond à rien (ou alors on pourrait faire
 * document original et commentaires)
 */
extra_build(){
}
} // class FicheIWatcher
