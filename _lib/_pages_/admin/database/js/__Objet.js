"use strict";
/**
 * Class Objet
 * -----------
 * La classe de n'importe quel élément, User, IcModule, AbsEtape etc.
 */
 class Objet {
/**
 * CLASSE
**/
static get items(){
  return this._items || (this._items = {})
}
static addItem(item){
  Object.assign(this.items, {[item.data.id]: item})
}
/**
 * Retourne l'instance d'objet d'identifiant +oid+ et de propriétaire +owner+
**/
static get(oid, owner) {
  if (undefined == this.items[oid]){
    console.log("this.items ne contient pas l'élément %i", oid, this.items)
    Object.assign(this.items, {[oid]: new this({id: oid}, owner)})
  }
  return this.items[oid];
}

/**
 * INSTANCE
**/
 constructor(data, owner) {
   this.data = data
   // Le propriétaire (qui N'EST PAS NÉCESSAIREMENT UN USER, c'est par exemple
   // l'icmodule d'une icetape ou l'icetape d'un document)
   this.owner = owner
   // Les données supplémentaires
   // Ce sont les données comme les données des modules d'un icarien, qui ne
   // sont donc pas enregistrées dans la table des users, mais sont récupérées
   // dans un second temps.
   // C'est la méthode this.load qui s'en charge.
   this.extra_data = null;
   // On ajoute cet objet à la liste des objets
   this.constructor.addItem(this)
 }
/**
  * L'ID formaté
  *
  * L'instance doit définir son id dans this.data.id
***/
get fid(){
 return this._fid || (this._fid = `${this.constructor.name}-${this.data.id}`.toLowerCase())
}

get ref_brut(){
  return this._ref_brut || (this._ref_brut = `${this.constructor.name} #${this.data.id}`)
}

get user(){
  return this._user || (this._user = Icarien.get(this.data.user_id))
}

get as_link(){
  return this._aslink || (this._aslink = this.buildlink())
}

get fiche(){
 return this._fiche || (this._fiche = this.instancieFiche())
}

load(thenMethod){
  Ajax.send("get_infos_for.rb", {type: this.constructor.name, objet_id: this.data.id})
  .then(ret => {
    console.log("Retour loading data:", ret)
    this.extra_data = ret.data
    this.loaden = true
    thenMethod.call()
  })
  .catch(err => {
    console.error(err)
    this.loaden = false
  })
}

get watchers(){
  return this._watchers || (this._watchers = this.instancieWatchers())
}

instancieFiche(){
  const classname = `Fiche${this.constructor.name}` // p.e. FicheIcarien
  const classe = eval(classname)
  return new classe(this)
}
/**
  * Méthode permettant d'ajouter un lien permettant d'ouvrir la fiche
  * de l'objet dans la section +container+
***/
addLinkTo(container){
  var l = document.createElement("DIV")
  l.innerHTML = this.ref
  l.id = this.fid // l'identifiant formaté
  l.className = "linked grid-child"
  l.setAttribute("data-id", this.data.id)
  container.appendChild(l)
  l.addEventListener('click', this.onClickLink.bind(this))
}

// Quand on clique sur l'objet lié (par exemple le nom de l'icarien), on
// ouvre sa fiche.
onClickLink(ev){
  this.fiche.open()
}


instancieWatchers(){
  let wlist = []
  if(!this.extra_data.watchers) return wlist
  this.extra_data.watchers.forEach(dw => {
    const w = new IWatcher(dw, this)
    wlist.push(w)
  })
  return wlist
}

buildlink(){
  const lien = document.createElement('SPAN')
  lien.innerHTML = this.ref
  lien.className = "linked"
  lien.addEventListener('click', this.fiche.open.bind(this.fiche))
  return lien
}

}// class Objet
