"use strict";

const DATA_ETAPES_STATUS = {
  1: "L’icarien travaille dessus",
  2: "L’icarien vient de transmettre son travail",
  3: "Je commente le travail de L’icarien",
  4: "Je viens de transmettre mes commentaires",
  5: "L’icarien a chargé les commentaires",
  6: "Les documents ont été déposé sur le QdD",
  7: "L’icarien a défini le partage de ses documents",
  8: "Étape complètement achevée"
}

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
constructor(objet) {
  super(objet)
}

build_all_own_data(){
  this.build_own_data("Icarien", this.objet.user.as_link)
  this.build_own_data("Propriétaire", this.objet.owner.as_link)
  this.build_own_data("ID", `#${this.data.id}`)
  this.build_own_data("Statut/status", this.human_status)
  this.build_own_data("Num. titre", `${this.data.numero}. ${this.data.titre}`)
  this.build_own_data("Démarrée le/started_at", this.data.started_at, 'date-time')
  this.build_own_data("Finie le/ended_at", this.data.ended_at, 'date-time')
  this.build_own_data("Options/options", this.data.options)
}

/**
  * Retourne le statut de l'étape, au format humain
  * Le statut correspond
***/
get human_status(){
  this.constructor.menuStatuts // pour forcer sa construction
  const vh = DATA_ETAPES_STATUS[this.data.status]
  const text = `${this.data.status} ${vh}`
  const span = DCreate('SPAN', {text:text, class:"linked"})
  const Classe = this.constructor
  span.addEventListener('click', Classe.openMenuStatutsAndChoose.bind(Classe, this.objet))
  return span
}
static openMenuStatutsAndChoose(ietape, ev){
  this.onChangeStatut.ietape = ietape
  const menu = this.menuStatuts
  menu.classList.remove('hidden')
  menu.style.top = `${ev.y - 10}px`
  menu.style.left = `${ev.x - 40}px`
}
static onChangeStatut(ev){
  const ietape = this.onChangeStatut.ietape
  const newStatus = DGet('#status').value
  const human_etape = `${ietape.data.numero}. ${ietape.data.titre}`
  const human_status = `${newStatus} (${DATA_ETAPES_STATUS[newStatus]})`
  if (confirm(`Dois-je mettre le statut de :\n\n\tl'étape ${human_etape}\nà :\n\t${human_status} ?`)){
    ietape.fiche.execCodeUpdate('icetapes',`SET status = ${newStatus}`,{no_confirmation:true})
    message(`J'ai mis le statut de l'étape ${human_etape} à ${human_status}.`)
  }
  this.closeMenuStatuts()
}
static closeMenuStatuts(){
  const menu = this.menuStatuts
  menu.classList.add('hidden')
}
static get menuStatuts(){
  return this._menustatuts||(this._menustatuts = this.buildMenuStatuts())
}
static buildMenuStatuts(){
  const menu = DCreate('SELECT', {
    id:'status',
    class:'hidden',
    style:'position:absolute;z-index:200;background-color:white;'
  })
  for (var s in DATA_ETAPES_STATUS){
    var h = DATA_ETAPES_STATUS[s]
    menu.appendChild(DCreate('OPTION',{value:s, text:`${s}: ${h}`}))
  }
  document.querySelector('body').appendChild(menu)
  menu.addEventListener('change', this.onChangeStatut.bind(this))
  return menu
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
