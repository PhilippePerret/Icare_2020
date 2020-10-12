"use strict";

class IEtape extends Objet {
/**
 * CLASSE
**/
static get color(){return 'chocolate'}

static get table(){return 'icetapes'}
/**
 * INSTANCE
**/
constructor(data, imodule) {
  super(data, imodule)
  this.imodule = imodule
}
get ref(){
  return this._ref || (this._ref = `<span class="ref"><span class="nature">étape</span><span class="name">${this.data.numero}. ${this.data.titre}</span><span class="id">#${this.data.id}</span><span class="date">${formate_jjmmaa(this.data.started_at)}</span></span>`)
}


} // class IEtape

class FicheIEtape extends Fiche {
constructor(data) {
  super(data)
}

build_all_own_data(){
  this.build_own_data("ID", `#${this.data.id}`)
  this.build_own_data("Numéro", this.data.numero)
  this.build_own_data("Titre", this.data.titre)
  this.build_own_data("Démarrée le/started_at", this.data.started_at, 'date-time')
  this.build_own_data("Finie le/ended_at", this.data.ended_at, 'date-time')
  this.build_own_data("Options/options", this.data.options)
}
/**
 * Construit les données supplémentaires
 *
 * Pour les étapes, ça correspond aux documents
 */
extra_build(){
  this.objet.extra_data.documents.forEach(dd => {
    const doc = new IDocument(dd, this)
    doc.addLinkTo(this.sectionListing)
  })
}

get data_children(){return{
  name: "Documents",
  color: IDocument.color
}}


} // class FicheIEtape
