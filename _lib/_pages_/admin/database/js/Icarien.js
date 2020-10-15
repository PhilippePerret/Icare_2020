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
  * @async
***/

getLastDateOfUser(){
  return Ajax.send("last_date_of_user.rb", {user_id: this.data.id})
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

static get OWN_DATA(){
  return [
      {suffix: 'pseudo',      method:'data.pseudo',     field_method: 'innerHTML'}
    , {suffix: 'patronyme',   method:'data.patronyme',  field_method: 'innerHTML'}
    , {suffix: 'sexe',        method:'f_sexe',          field_method: 'innerHTML'}
    , {suffix: 'options',     method:'data.options',    field_method: 'innerHTML'}
    , {suffix: 'mail',        method:'f_mail',          field_method: 'innerHTML'}
    , {suffix: 'naissance',   method:'f_naissance',     field_method: 'innerHTML'}
    , {suffix: 'created_at',  method:'f_created_at',    field_method: 'innerHTML'}
  ]
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
  this.build_own_data("Pseudo/pseudo", this.spanProperty('pseudo'))
  this.build_own_data("Patronyme/patronyme", this.spanProperty('patronyme'))
  this.build_own_data("Sexe/sexe", this.spanProperty('sexe', this.f_sexe))
  this.build_own_data("Statut", this.human_statut)
  this.build_own_data("Options/options", this.spanProperty('options'))
  this.build_own_data("Inscription/created_at", this.spanProperty('created_at', this.f_created_at))
  this.build_own_data("Sortie/date_sortie", this.spanProperty('date_sortie', this.f_date_sortie))
  // Noter que le module courant sera affecté après que les modules de l'icarien
  // ont été relevés et instanciés. TODO Mettre plutôt un champ ici qui sera remplacé plus tard
  // comme pour les icmodules je crois.
  this.build_own_data("Mail/mail", this.spanProperty('mail', this.f_mail))
  this.build_own_data("Naissance & âge/naissance", this.spanProperty('naissance', this.f_naissance))
}

get f_mail(){
  return `<a href="mailto:${this.data.mail}?subject=🦋">${this.data.mail}</a>`
}
get f_sexe(){
  return this.data.sexe == "F" ? "Femme" : "Homme"
}
get f_naissance(){
  return this._fnaissance || ( this._fnaissance = this.build_naissance() )
}

get f_date_sortie(){
  if ( ! this.data.date_sortie ) {
    // Quand aucune date de sortie n'est définie, il faut l'indiquer
    return "- en d'activité -"
  } else {
    // Quand une date de sortie est définie,il faut la checker
    this.objet.getLastDateOfUser()
    .then(ret => {
      setTimeout(this.fixLastTimeAndSortie.bind(this, ret), 1 * 1000)
    })
    return `${formate_date(this.data.date_sortie)} <span id="${this.fid}-checked-date"><img src="./img/gif/spirale.gif" width="20" style="vertical-align:sub;" /></span><div id="${this.fid}-last-time" class="hidden"></div>`
  }
}

fixLastTimeAndSortie(ret){
  // console.log("Dernière dates trouvées : ", ret)
  const markok = ret.date_sortie_ok ? '√' : `<span title="${ret.raison}">🆘</span>` ;
  const date_sortie_check_span = document.querySelector(`span#${this.fid}-checked-date`)
  const last_time_span = document.querySelector(`div#${this.fid}-last-time`)
  date_sortie_check_span.innerHTML = markok
  if (!ret.date_sortie_ok) {
    // Si la date de sortie n'est pas bonne, il faut proposer des nouvelles
    // date
    const last_time_data = ret.time_list[0]
    let last_time = Number(last_time_data.time)
    let from_item = `${last_time_data.table} #${last_time_data.id}`
    if ( last_time_data.property != 'ended_at' ) {
      // Si ce n'est pas une propriété de fin, on ajoute 10 jours
      last_time += 10*24*3600
      from_item += " + 10 jours"
    }
    const idprov = `time-${new Date().getTime()}`
    last_time_span.classList.remove('hidden')
    last_time_span.innerHTML = `Pourrait être <span id="${idprov}"></span> (de ${from_item})`
    document.querySelector(`span#${idprov}`).replaceWith(this.makeSpanDate(last_time, formate_date(last_time)))
  }
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
