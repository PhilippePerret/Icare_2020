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
  return this._ref || (this._ref = `<span class="ref"><span class="nature">module</span><span class="name">${this.f_name}</span><span class="id">#${this.data.id}</span> <span class="date">${formate_jjmmaa(this.data.started_at)}</span></span>`)
}

// Retourne le nom formaté pour le module (contient le titre du projet
// s'il a été défini)
get f_name(){
  return this._fname || ( this._fname = this.build_fname())

}
build_fname(){
  var ps = [this.data.module_name]
  if ( this.data.project_name) {
    ps.push(`“${this.data.project_name}”`)
  }
  return ps.join(' ')
}

}// class IModule


class FicheIModule extends Fiche {
constructor(objet){
  super(objet)
}

build_all_own_data(){
  this.build_own_data("Propriétaire", this.objet.owner.as_link)
  this.build_own_data("Titre projet/project_name", this.data.project_name)
  this.build_own_data("Démarré le/started_at", this.data.started_at, 'date')
  this.build_own_data("Achevé le/ended_at", this.data.ended_at, 'date')
  this.build_own_data("Étape courante/icetape_id", `<span id="${this.fid}-icetape_id">…</span>`)
  this.build_own_data("Options/options", this.data.options)
}

defineLinkToCurrentEtape(){
  let cont ;
  if (!this.data.icetape_id){
    cont = DCreate('SPAN', {text:"- aucune -"})
  } else {
    cont = IEtape.get(this.data.icetape_id, this.objet).as_link
  }
  DGet(`#${this.fid}-icetape_id`).replaceWith(cont)
}

/**
 * Construit les données supplémentaires
 *
 * Pour les modules, ça correspond à la liste des étapes
 */
extra_build(){
  this.objet.extra_data.etapes.forEach(de => {
    const eta = new IEtape(de, this.objet)
    eta.addLinkTo(this.sectionListing)
  })
  // Pour mettre un lien vers l'étape courante si elle est définie ou
  // indiquer qu'il n'y a pas d'étape courante
  this.defineLinkToCurrentEtape()
}

get data_children(){return{
  name: "Étapes de travail",
  color: IEtape.color
}}


} // class FicheIModule
