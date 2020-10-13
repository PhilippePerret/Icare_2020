"use strict";

const DATA_ICARIEN_STATUTS_LIST = [
  {value:"2", text:"Actif (2)"}
, {value:"4", text:"Inactif (ancien) (4)"}
, {value:"6", text:"Reçu (6)"}
, {value:"3", text:"Candidat (3)"}
]
const DATA_ICARIEN_STATUTS = {}
DATA_ICARIEN_STATUTS_LIST.forEach(d => Object.assign(DATA_ICARIEN_STATUTS, {[d.value]: d}))

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
    message("La liste des icariens est prête. Tu peux commencer par choisir un·e icarien·ne (en la filtrant peut-être avec une partie du pseudo ou une recherche par étiquette comme `statut:actif`).")
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
get state(){
  return this.data.options.substring(16,17)
}
/**
  * Méthode pour changer le statut de l'icarien
***/
changeIcarienStatut(newstate){
  var opts = this.data.options.split('')
  opts[16] = newstate
  opts = opts.join('')
  this.data.options = opts
  DGet(`#${this.fid}-options`).innerHTML = this.data.options
  this.fiche.execCodeUpdate('users',`SET options = "${opts}"`, {no_confirmation:true})
  return true
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
  this.build_own_data("Patronyme/patronyme",      this.data.patronyme)
  this.build_own_data("Sexe/sexe", this.data.sexe == "F" ? "Femme" : "Homme")
  this.build_own_data("Statut", this.human_statut)
  this.build_own_data("Options/options", DCreate('SPAN',{id:`${this.fid}-options`,text:this.data.options}))
  this.build_own_data("Inscription/created_at",   this.data.created_at, 'date-time')
  this.build_own_data("Sortie/date_sortie",           this.data.date_sortie, 'date-time')
  // Noter que le module courant sera affecté après que les modules de l'icarien
  // ont été relevés et instanciés.
  this.build_own_data("Mail/mail", `<a href="mailto:${this.data.mail}?subject=🦋">${this.data.mail}</a>`)
  this.build_own_data("Naissance & âge/naissance", this.f_naissance)
}

/**
  * Pour gérer le statut de l'icarien.
  * C'est un menu qui affiche le statut de l'icarien et permet de le modifier.
***/
get human_statut(){
  const dselect = new DSelect({
      id: `${this.fid}-icarien-state`
    , values: DATA_ICARIEN_STATUTS_LIST
    , default_value: this.objet.state
    , onchange: this.onChangeStatus.bind(this)
  })
  return dselect.menu
}
onChangeStatus(newState, ev){
  const h_state = DATA_ICARIEN_STATUTS[newState].text
  const pseudo      = this.objet.data.pseudo
  const question    = `Dois-je mettre le statut de\n\n\t${pseudo}\nà :\n\t${h_state} ?`
  if (confirm(question)) {
    if (this.objet.changeIcarienStatut(newState)){
      message(`Le statut de ${pseudo} a été mis à ${h_state}`)
    }
  }
}

get f_naissance(){
  return this._fnaissance || ( this._fnaissance = this.build_naissance() )
}
build_naissance(){
  const age = (new Date().getFullYear() - new Date(`1/1/${this.data.naissance}`).getFullYear())
  return `${this.data.naissance} (${age} ans)`
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
