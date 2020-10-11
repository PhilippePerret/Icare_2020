"use strict";
class Icarien extends Objet {

static get ficheListe(){
  return this._ficheliste || (this._ficheliste = this.buildFicheListe())
}
/**
 * Méthode principale qui construit la fiche contenant la liste des icariens
 * Cette méthode renseigne la variable de classe Icarien.ficheListe
 */
static buildFicheListe(){
  const f = new Fiche({data: {titre:"Icariens"}, loaden:true, not_closable:true})
  f.build()
  DB.exec("SELECT * FROM users WHERE id > 9 ORDER BY pseudo")
  .then(ret => {
    // ret.response contient la liste des icariens sélectionnés
    // On fait une ligne cliquable par icarien
    ret.response.forEach(du => {
      var u = new Icarien(du, this)
      u.addLinkTo(f.sectionListing)
    })
  })
  return f
}

constructor(data, owner) {
  super(data, owner)
}
get ref(){
  return this._ref || (this._ref = `${this.data.pseudo} (#${this.data.id})`)
}
get as_link(){
  return this._aslink || (this._aslink = this.buildlink())
}
buildlink(){
  const lien = document.createElement('SPAN')
  lien.innerHTML = this.ref
  lien.className = "linked"
  lien.addEventListener('click', this.fiche.open.bind(this.fiche))
  return lien
}
}//class Icarien


class FicheIcarien extends Fiche {
constructor(objet) {
  super(objet)
}
/**
 * Construction des données propres de l'icarien
 */
build_all_own_data() {
  this.build_own_data("Pseudo/pseudo",     this.data.pseudo)
  this.build_own_data("Depuis le/created_at",  this.data.created_at, 'date')
  this.build_own_data("Arrêt/ended_at",      this.data.ended_at, 'date')
  this.build_own_data("Module courant/icmodule_id", "[lien vers courant]")
}
/**
  Construction des éléments de la fiche

  Pour un icarien, c'est la liste de ses modules
**/
extra_build(){
  // Construction des modules d'apprentissage suivis
  this.objet.extra_data.modules.forEach(dm => {
    const mod = new IModule(dm, this.objet)
    mod.addLinkTo(this.sectionListing)
  })
}
}
