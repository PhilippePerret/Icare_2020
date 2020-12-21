"use strict";

const DATA_ETAPES_STATUS = {
  1: {text:"1 : L’icarien travaille dessus"},
  2: {text:"2 : L’icarien vient de transmettre son travail"},
  3: {text:"3 : Je commente le travail de L’icarien"},
  4: {text:"4 : Je viens de transmettre mes commentaires"},
  5: {text:"5 : L’icarien a chargé les commentaires"},
  6: {text:"6 : Les documents ont été déposé sur le QdD"},
  7: {text:"7 : L’icarien a défini le partage de ses documents"},
  8: {text:"8 : Étape complètement achevée"}
}

class IEtape extends Objet {
/**
 * CLASSE
**/

static get OWN_DATA(){
  return [
    {suffix: 'icarien',     method:'f_icarien',     field_method:'innerHTML'}
  ]
}

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
constructor(objet) {
  super(objet)
}

build_all_own_data(){
  this.build_own_data("Icarien", this.spanProperty('icarien', this.f_icarien))
  this.build_own_data("Propriétaire", this.objet.owner.as_link)
  this.build_own_data("ID", `#${this.data.id}`)
  this.build_own_data("Statut/status", this.human_status)
  this.build_own_data("Num. titre", `${this.data.numero}. ${this.data.titre}`)
  this.build_own_data("Démarrée le/started_at", this.data.started_at, 'date-time')
  this.build_own_data("Finie le/ended_at", this.data.ended_at, 'date-time')
  this.build_own_data("Options/options", this.data.options)
}

get f_icarien(){return this.objet.user.as_link}

/**
  * Retourne le statut de l'étape, au format humain
  * Le statut correspond
***/
get human_status(){
  var m = new DSelect({
    id:'status',
    default_value:this.data.status,
    onchange: this.onChangeStatus.bind(this),
    values:   DATA_ETAPES_STATUS
  })
  return m.menu
}
onChangeStatus(newStatus, ev){
  newStatus = Number(newStatus)
  const human_status = DATA_ETAPES_STATUS[newStatus].text
  if (confirm(`Dois-je mettre le statut de :\n\n\tl'étape ${this.as_human}\nà :\n\t${human_status} ?`)){
    this.execCodeUpdate('icetapes',`SET status = ${newStatus}`,{no_confirmation:true})
    message(`J'ai mis le statut de l'étape ${this.as_human} à ${human_status}.`)
  }
}

get as_human(){
  return this._ashuman || (this._ashuman = `${this.data.numero}. ${this.data.titre}`)
}


/**
 * Construit les données supplémentaires
 *
 * Pour les étapes, ça correspond aux documents
 */
extra_build(){
  this.objet.extra_data.documents.forEach(dd => {
    const doc = new IDocument(dd, this.objet)
    doc.addLinkTo(this.sectionListing)
  })
}

get data_children(){return{
  name: "Documents",
  color: IDocument.color
}}


} // class FicheIEtape
