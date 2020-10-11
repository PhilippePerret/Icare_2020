"use strict";
class IDocument extends Objet {
constructor(data, ietape) {
  super(data, ietape)
  this.ietape = ietape
}
get ref(){
  return this._ref || (this._ref = `${this.data.original_name} (#${this.data.id})`)
}

} // class IDocument

class FicheIDocument extends Fiche {
constructor(data) {
  super(data)
}

/**
 * Construit les données supplémentaires
 *
 * Pour les document, ça ne correspond à rien (ou alors on pourrait faire
 * document original et commentaires)
 */
build_extra(){
}
} // class FicheIDocument
