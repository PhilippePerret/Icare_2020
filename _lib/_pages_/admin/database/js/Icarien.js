"use strict";
class Icarien extends Objet {

static get ficheListe(){
  return this._ficheliste || (this._ficheliste = this.buildFicheListe())
}

static get table(){return 'users'}
/**
 * Méthode principale qui construit la fiche contenant la liste des icariens
 * Cette méthode renseigne la variable de classe Icarien.ficheListe
 */
static buildFicheListe(){
  const f = new Fiche({data: {titre:"Icariens"}, loaden:true, not_closable:true})
  f.build()
  DB.exec("SELECT * FROM users WHERE id > 9 AND SUBSTRING(options,4,1) <> \"1\" ORDER BY pseudo")
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

static get color(){return 'darkred'}

constructor(data, owner) {
  super(data, owner)
}
get ref(){
  return this._ref || (this._ref = `<span class="ref"><span class="nature">${this.data.sexe == 'F' ? '👩🏻‍🎓' : '👨🏻‍🎓'}</span><span class="name">${this.data.pseudo}</span><span class="id">#${this.data.id}</span><span class="date">${formate_jjmmaa(this.data.created_at)}</span></span>`)
}

get human_state(){
  const bit16 = this.data.options.substring(16,17);
  return {
    "2": "Actif", "3": "Candidat", "4": "Inactif (ancien)", "6":"Reçu"
  }[bit16] || "- inconnu -"
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
  this.build_own_data("Pseudo/pseudo",            this.data.pseudo)
  this.build_own_data("Sexe/sexe", this.data.sexe == "F" ? "Femme" : "Homme")
  this.build_own_data("Statut", this.objet.human_state)
  this.build_own_data("Options/options", this.data.options)
  this.build_own_data("Inscription/created_at",   this.data.created_at, 'date-time')
  this.build_own_data("Arrêt/date_sortie",           this.data.date_sortie, 'date-time')
  // Noter que le module courant sera affecté après que les modules de l'icarien
  // ont été relevés et instanciés.
  this.build_own_data("Mail/mail", `<a href="mailto:${this.data.mail}?subject=🦋">${this.data.mail}</a>`)
  this.build_own_data("Année naissance/naissance", this.data.naissance)
}

link_to_current_module(){
  if (!this.data.icmodule_id) return "- aucun -" ;
  return IModule.get(this.data.icmodule_id, this.objet).as_link
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

  // On peut ajouter le module courant aux données propres
  this.build_own_data("Module courant/icmodule_id", this.link_to_current_module())

}

get data_children(){return{
  name: "Modules d'apprentissage",
  color: IModule.color
}}

} // Class << Fiche
