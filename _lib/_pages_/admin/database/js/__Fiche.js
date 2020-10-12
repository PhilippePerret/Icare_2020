"use strict";
/**

  <fiche>.sectionOwnData
      Section contenant les données propres de l'objet
  <fiche>.sectionListing
      Section contenant les éléments de l'objet (par exemple les documents
      pour une étape)
  <fiche>.sectionWatchers
      Section contenant les watchers de l'élément
**/
class Fiche {
/** ---------------------------------------------------------------------
 * CLASSE
--------------------------------------------------------------------- **/
static get current() { return this._current }
static set current(c) { this._current = c }
static select(ifiche) {
  this.deselectCurrent()
  this.current= ifiche;
  this.current.obj.classList.add('selected')
}
static deselectCurrent(){
  if (!this.current) return
  this.current.obj.classList.remove('selected')
}
/** ---------------------------------------------------------------------
 * INSTANCE
 --------------------------------------------------------------------- */
constructor(objet) {
  this.objet  = objet
  this.data   = objet.data
}
open(){return this.show()}
show(){
  if (!this.objet.loaden) return this.objet.load(this.show.bind(this))
  if (!this.built) this.build()
  this.obj.classList.remove('hidden')
  Fiche.select(this)
}
close(){return this.hide()}
hide(){
  this.obj.classList.add('hidden')
}
build(){
  this.obj = document.createElement("DIV")
  this.obj.className = "fiche hidden"

  // Titre
  const titre = document.createElement('DIV')
  titre.className = "titre"
  titre.innerHTML = this.objet.ref || this.data.titre
  titre.style.backgroundColor = this.objet.constructor.color || 'black'
  this.obj.appendChild(titre)
  if ( !this.objet.not_closable ) {
    // Dans le titre : la case de fermeture de la fiche
    const xclose = document.createElement('SPAN')
    xclose.innerHTML = "&nbsp;"
    xclose.className = "close-cross"
    xclose.addEventListener("click", this.close.bind(this))
    titre.appendChild(xclose)
  }

  // Partie des données propres à l'objet
  const owndata = document.createElement('DIV')
  owndata.className = "own-data"
  this.obj.appendChild(owndata)
  this.sectionOwnData = owndata

  // Partie listing que comprend toujours une fiche, par défaut
  // C'est la liste des éléments de l'objet. Par exemple la liste des
  // documents de l'étape ou la liste des étapes du modules.
  if ( this.objet.fiche && this.objet.fiche.data_children ) {
    const dchildren   = this.objet.fiche.data_children
    const titListing  = document.createElement('DIV')
    titListing.className = "sous-titre"
    titListing.innerHTML = dchildren.name
    titListing.style.backgroundColor = dchildren.color
    this.obj.appendChild(titListing)
  }
  this.sectionListing = document.createElement('DIV')
  this.sectionListing.className = "listing"
  this.obj.appendChild(this.sectionListing)

  // La section des watchers si l'objet en contient
  const has_watchers = this.objet.extra_data && this.objet.extra_data.watchers
  if ( has_watchers ) {
    const titwatchers = document.createElement('DIV')
    titwatchers.className = "sous-titre"
    titwatchers.innerHTML = "Watchers"
    titwatchers.style.backgroundColor = IWatcher.color
    this.obj.appendChild(titwatchers)
    this.sectionWatchers = document.createElement('DIV')
    this.sectionWatchers.className = "listing"
    this.obj.appendChild(this.sectionWatchers)
  }

  // La partie en bas de fiche pour envoyer une requête
  const divreq = document.createElement('DIV')
  divreq.className = "div-request"
  const reqfield = document.createElement('INPUT')
  reqfield.id = `field-code-${this.objet.fid}`
  reqfield.setAttribute('placeholder', "Pseudo-code Mysql")
  reqfield.type = "text"
  reqfield.addEventListener('keypress', this.onReturnInCodeField.bind(this))
  if (this.constructor.name == 'Fiche'){
    // Pour filtrer la liste, quand ce sont les icariens
    reqfield.addEventListener('keyup', this.onKeyUp.bind(this))
  }
  divreq.appendChild(reqfield)
  this.obj.appendChild(divreq)

  // On ajoute la fiche au body et on la surveille
  document.querySelector("section#body").appendChild(this.obj)
  $(this.obj).draggable({})
  $(this.obj).css({top:'20px', right:'20px'})
  // Pour activer la fiche
  this.obj.addEventListener('click', Fiche.select.bind(Fiche, this))

  // On lance la construction du reste
  this.build_all_own_data()
  if ( has_watchers ) this.build_watchers() // s'il y en a
  this.extra_build() // les éléments propres

  this.built = true
}

/**
 * Méthode appelée quand on clique sur une touche dans le champ de code
**/
onReturnInCodeField(ev){
  if (ev.code == "Enter" && this.constructor.name != 'Fiche'){
    stopEventAsync(ev).then(this.execCode.bind(this))
    return false
  }
  return true
}
onKeyUp(ev){
  this.filtreListing()
}

/**
 * Méthode qui permet de filtrer la liste des icariens à l'aide du champ
 * de texte en bas de fiche.
**/
filtreListing(){
  const searched = this.codeField.value.toLowerCase()
  if ( searched != "" ) {
    this.sectionListing.querySelectorAll("div.grid-child").forEach(div => {
      const txt = div.querySelector("span.name").innerHTML.toLowerCase()
      const contient = txt.includes(searched)
      div.classList[contient ? 'remove' : 'add']('hidden')
    })
  } else {
    this.sectionListing.querySelectorAll("div.grid-child").forEach(div => div.classList.remove('hidden'))
  }
}

/**
 * Méthode qui exécute le code du champ de texte de bas de page après
 * confirmation par l'utilisateur.
**/
execCode(){
  const fieldcode = this.codeField.value // par exemple "SET date_sortie = '1356786537'"
  const fullcode = `UPDATE ${this.objet.constructor.table} ${fieldcode} WHERE id = ${this.objet.data.id}`
  if (!confirm("Dois-je vraiment exécuter le code :\n"+fullcode)) return
  const realcode  = `UPDATE ${this.objet.constructor.table} ${fieldcode} WHERE id = ?`
  const values    = [this.objet.data.id]
  Ajax.send("db_exec.rb", {request: realcode, values: values})
}

get codeField(){
  return this._codefield || (this._codefield = document.querySelector(`input#field-code-${this.objet.fid}`))
}
/**
 * Méthode pour construire les "extra_data" de l'objet
 * Cette méthode doit être surclassée dans chaque classe concrète
 */
extra_build(){

}
/**
 * Méthode pour construire les données propres de l'objet
 * Cette méthode devrait être surclassée par la classe héritante
 */
build_all_own_data(){

}

giveValue(message, valueStr){
  prompt(message, valueStr)
}

/**
 * Pour construire une ligne de donnée propre
 */
build_own_data(libelle, valeur, type){
  const line = document.createElement('DIV')
  const label = document.createElement('SPAN')
  label.className = "own-data-label linked"
  var [libelle, prop_name] = libelle.split("/")
  if (prop_name && prop_name.trim() == "") prop_name = null ;
  label.innerHTML = libelle
  line.appendChild(label)
  if (prop_name){
    label.setAttribute("title", `Pseudo-sql proprety: ${prop_name}`)
    label.addEventListener('click', this.giveValue.bind(this, "Le nom de la propriété est", prop_name))
  }

  // Valeur
  let value ;
  let real_value = null;
  if ( valeur && "object" == typeof(valeur) ) {
    value = valeur;
  } else {
    value = document.createElement('SPAN')
    value.className = 'own-data-value'
    if ( !valeur ) {
      valeur = "n/d"
    } else {
      switch (type) {
        case 'date-time':
          real_value = valeur
          valeur = formate_date(valeur, 'date-time')
          break
        case 'date':
          real_value = valeur
          valeur = formate_date(valeur, 'date')
          break
      }
    }
    value.innerHTML = valeur
  }
  line.appendChild(value)
  if ( real_value ) {
    value.addEventListener('click', this.giveValue.bind(this, "La valeur réelle est", real_value))
    value.classList.add('linked')
  }

  this.sectionOwnData.appendChild(line)
}

/**
 * Construire la liste des watchers
**/
build_watchers(){
  this.objet.watchers.forEach(watcher => {
    watcher.addLinkTo(this.sectionWatchers)
  })
}

} // class Fiche
