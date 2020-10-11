"use strict";

class IEtape extends Objet {
constructor(data, imodule) {
  super(data, imodule)
  this.imodule = imodule
}
get ref(){
  return this._ref || (this._ref = `${this.data.numero}. ${this.data.titre} (#${this.data.id})`)
}

} // class IEtape

class FicheIEtape extends Fiche {
constructor(data) {
  super(data)
}

build_all_own_data(){
  this.build_own_data("Numéro/", this.data.numero)
  this.build_own_data("Titre/", this.data.titre)
  this.build_own_data("Démarrée le/started_at", this.data.started_at, 'date')
  this.build_own_data("Finie le/ended_at", this.data.ended_at, 'date')
  this.build_own_data("Options/options", this.data.options)
}
/**
 * Construit les données supplémentaires
 *
 * Pour les étapes, ça correspond aux documents
 */
build_extra(){
  this.objet.extra_data.documents.forEach(dd => {
    const doc = new IDocument(dd, this)
    doc.addLinkTo(this.sectionListing)
  })
}
} // class FicheIEtape
