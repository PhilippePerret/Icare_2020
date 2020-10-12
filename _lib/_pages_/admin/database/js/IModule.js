"use strict";
class IModule extends Objet {
/**
 * CLASSE
**/
static get color(){return 'darkslategray'}

static get table(){return 'icmodules'}

/**
 * INSTANCE
**/
constructor(data, owner) {
  super(data, owner)
}
get ref(){
  return this._ref || (this._ref = `<span class="ref"><span class="nature">module</span><span class="name">“${this.data.module_name}”</span><span class="id">#${this.data.id}</span> <span class="date">${formate_jjmmaa(this.data.started_at)}</span></span>`)
}


}// class IModule


class FicheIModule extends Fiche {
constructor(objet){
  super(objet)
}


build_all_own_data(){
  this.build_own_data("Propriétaire", this.objet.owner.as_link)
  this.build_own_data("Démarré le/started_at", this.data.started_at, 'date')
  this.build_own_data("Achevé le/ended_at", this.data.ended_at, 'date')
  this.build_own_data("Titre projet/project_name", this.data.project_name)
  this.build_own_data("Options/options", this.data.options)
}
/**
 * Construit les données supplémentaires
 *
 * Pour les modules, ça correspond à la liste des étapes
 */
extra_build(){
  this.objet.extra_data.etapes.forEach(de => {
    const eta = new IEtape(de, this)
    eta.addLinkTo(this.sectionListing)
  })
}

get data_children(){return{
  name: "Étapes de travail",
  color: IEtape.color
}}


} // class FicheIModule
