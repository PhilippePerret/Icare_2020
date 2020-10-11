"use strict";
/**
 * Class Objet
 * -----------
 * La classe de n'importe quel élément, User, IcModule, AbsEtape etc.
 */
 class Objet {
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
 }
/**
  * L'ID formaté
  *
  * L'instance doit définir son id dans this.data.id
***/
get fid(){
 return this._fid || (this._fid = `${this.constructor.name}-${this.data.id}`.toLowerCase())
}

get fiche(){
 return this._fiche || (this._fiche = this.instancieFiche())
}

load(thenMethod){
  console.log("Chargement des données de " + this.ref)
  Ajax.send("get_infos_for.rb", {type: this.constructor.name, objet_id: this.data.id})
  .then(ret => {
    console.log("retour:", ret)
    this.extra_data = ret.data
    this.loaden = true
    thenMethod.call()
  })
  .catch(err => {
    console.error(err)
    this.loaden = false
  })
}

instancieFiche(){
  const classname = `Fiche${this.constructor.name}` // p.e. FicheIcarien
  const classe = eval(classname)
  return new classe(this)
}
 /**
  * Méthode permettant d'ajouter un lien permettant d'ouvrir la fiche
  * de l'objet dans la section +container+
  */
addLinkTo(container){
  var l = document.createElement("DIV")
  l.innerHTML = this.ref
  l.id = this.fid // l'identifiant formaté
  l.className = "linked"
  container.appendChild(l)
  l.addEventListener('click', this.onClickLink.bind(this))
}

// Quand on clique sur l'objet lié (par exemple le nom de l'icarien), on
// ouvre sa fiche.
onClickLink(ev){
  this.fiche.open()
}

}// class Objet
