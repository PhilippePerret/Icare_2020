"use strict";
class IModule extends Objet {
constructor(data, owner) {
  super(data, owner)
}
get ref(){
  return this._ref || (this._ref = `“${this.data.module_name}” (#${this.data.id}) ${format_jjmmaa(this.data.started_at)}`)
}

}// class IModule


class FicheIModule extends Fiche {
constructor(objet){
  super(objet)
}


build_all_own_data(){
  this.build_own_data("Propriétaire", this.objet.owner.as_link)
  this.build_own_data("Démarré le/started_at", this.data.started_at, 'date')
  this.build_own_data("Finie le/ended_at", this.data.ended_at, 'date')
  this.build_own_data("Options/options", this.data.options)
}
/**
 * Construit les données supplémentaires
 *
 * Pour les modules, ça correspond à la liste des étapes
 */
extra_build(){
  this.objet.extra_data.etapes.forEach(de => {
    const eta = new IEtape(de)
    eta.addLinkTo(this.sectionListing)
  })
}

} // class FicheIModule
