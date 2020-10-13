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
static deselect(ifiche){
  if (ifiche.obj.id == this.current.obj.id) {
    this.deselectCurrent()
  } else {
    ifiche.obj.classList.remove('selected')
  }
}
/**
  * Retourne les positions à appliquer pour la prochaine fiche en fonction
  * de la position de la fiche courante si elle est définie. Sinon, renvoie
  * des valeurs par défaut.
  * @return un objet {:x, :y}
***/
static getNextCoordonnates(){
  if (this.current){
    return { x : `calc(${this.current.left} + 40px)`, y : `calc(${this.current.top} + 40px)` }
  } else {
    return { x : '50%', y : '20px' }
  }
}
/** ---------------------------------------------------------------------
 * INSTANCE
 --------------------------------------------------------------------- */
constructor(objet) {
  this.objet  = objet
  this.data   = objet.data
}
get fid(){return this.objet.fid}
open(){return this.show()}
show(){
  if (!this.objet.loaden) return this.objet.load(this.show.bind(this))
  if (!this.built) this.build()
  this.obj.classList.remove('hidden')
  Fiche.select(this)
}
close(ev){
  this.hide()
  // Faut-il fermer les parents ?
  if ( ev && ev.shiftKey && this.objet.owner && this.objet.owner.fiche) this.objet.owner.fiche.close(ev)
  if (ev) stopEvent(ev) ;
}
hide(){
  this.obj.classList.add('hidden')
  Fiche.deselect(this)
}

/**
  * Reconstruction de la fiche
  * Par exemple après un changement de données.
***/

rebuild(){
  const top   = this.obj.style.top
      , left  = this.obj.style.left;
  this.obj.remove()
  delete this.obj
  delete this.sectionOwnData
  delete this.sectionListing
  delete this.sectionWatchers
  this.built = false
  this.build()
  this.obj.classList.remove('hidden')
  // Replacer la fiche au même endroit
  this.obj.style.top = top
  this.obj.style.left = left
}

/**
  * Construction de la fiche
***/
build(){
  this.obj = DCreate('DIV', {id: this.objet.id, css:"fiche hidden"})

  // Pour connaitre l'identifiant de l'objet
  this.obj.setAttribute("data-id", this.objet.data.id)

  // Titre
  const titre = DCreate('DIV', {css:'titre', text: this.objet.ref || this.data.titre})
  titre.style.backgroundColor = this.objet.constructor.color || 'black'
  this.obj.appendChild(titre)
  if ( !this.objet.not_closable ) {
    // Dans le titre : la case de fermeture de la fiche
    const xclose = DCreate('SPAN', {text:"&nbsp;", css:"close-cross" })
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
  reqfield.type = "text"
  reqfield.addEventListener('keypress', this.onReturnInCodeField.bind(this))
  if (this.constructor.name == 'Fiche'){
    // Pour filtrer la liste, quand ce sont les icariens
    reqfield.addEventListener('keyup', this.onKeyUp.bind(this))
    reqfield.setAttribute('placeholder', "Filtrer")
  } else {
  }
  divreq.appendChild(reqfield)
  this.obj.appendChild(divreq)

  // On ajoute la fiche au body et on la surveille
  document.querySelector("section#body").appendChild(this.obj)
  $(this.obj).draggable({})
  this.positionne()

  // Pour activer la fiche
  this.obj.addEventListener('click', Fiche.select.bind(Fiche, this))

  // On lance la construction du reste
  this.build_all_own_data()
  if ( has_watchers ) this.build_watchers() // s'il y en a
  this.extra_build() // les éléments propres

  this.built = true
}

/**
  * Méthode pour positionner la fiche
  * Si x et y ne sont pas définis, on prend les positions de la fiche
  * courante si elle existe, sinon des valeurs par défaut
***/

positionne(x,y){
  const nextCoor = Fiche.getNextCoordonnates()
  console.log("nextCoor:", nextCoor)
  this.obj.style.top  = y || nextCoor.y ;
  this.obj.style.left = x || nextCoor.x ;
}


get top(){ return this.obj.style.top }
get left(){ return this.obj.style.left }

/**
 * Méthode appelée quand on clique sur une touche dans le champ de code
**/
onReturnInCodeField(ev){
  if (ev.code == "Enter"){
    if ( this.constructor.name != 'Fiche' ) {
      stopEventAsync(ev).then(this.execCode.bind(this))
    } else {
      this.filtreListing()
    }
    return false
  }
  return true
}
onKeyUp(ev){
  // this.filtreListing()
}

/**
 * Méthode qui permet de filtrer la liste des icariens à l'aide du champ
 * de texte en bas de fiche.
**/
filtreListing(){
  const searched = this.codeField.value.trim().toLowerCase()
  if ( searched == "" ) {
    this.sectionListing.querySelectorAll("div.grid-child").forEach(div => div.classList.remove('hidden'))
    return
  }
  let filterMethod ;
  if ( searched.includes(':') ) {
    let [etiquette, val] = searched.split(':')
    if ( etiquette == 'after' || etiquette == 'before'){
      const [jour, mois, annee] = val.split('/')
      val = new Date([mois,jour,annee].join("/"))
      val = Number(val.getTime() / 1000)
    }
    switch (etiquette) {
      case 'before':
        filterMethod = this.hasSignupBefore.bind(this, val)
        break
      case 'after':
        filterMethod = this.hasSignupAfter.bind(this, val)
        break
      case 'statut':
        filterMethod = this.isStatutEquals.bind(this, val)
        break
      case 'data':
        const hval = {}
        val.split(',').forEach(paire => {
          let [key, value] = paire.split("=")
          key   = key.trim()
          value = eval(value.trim())
          Object.assign(hval, {[key]: value})
        })
        console.log("hval:", hval)
        filterMethod = this.hasData.bind(this, hval)
        break
      default:
        return erreur(`Étiquette inconnue (${etiquette})… Utiliser 'statut:', 'before:' ou 'after:'`)
    }
  } else {
    filterMethod = this.isNameContaining.bind(this, searched)
  }
  this.sectionListing.querySelectorAll("div.grid-child").forEach(div => {
    const is_valide = filterMethod.call(this, div, searched)
    div.classList[is_valide ? 'remove' : 'add']('hidden')
  })
}
// Filtrage par le nom (name)
isNameContaining(expected, div){
  const txt = div.querySelector("span.name").innerHTML.toLowerCase()
  return txt.includes(expected)
}

/**
 * Méthode qui exécute le code du champ de texte de bas de page après
 * confirmation par l'utilisateur.
**/
execCode(){
  const sqlTable = this.objet.constructor.table
  const fieldcode = this.codeField.value // par exemple "SET date_sortie = '1356786537'"
  const firstWord = fieldcode.split(' ')[0]
  if (firstWord == 'SET') {
    this.execCodeUpdate(sqlTable, fieldcode)
  } else if ( firstWord == 'DESTROY') {
    this.execCodeDestroy(sqlTable, fieldcode)
  }
}
execCodeUpdate(sqlTable, fieldcode, options){
  const fullcode = `UPDATE ${sqlTable} ${fieldcode} WHERE id = ${this.objet.data.id}`
  if ( !(options && options.no_confirmation)) {
    if (!confirm("Dois-je vraiment exécuter le code :\n"+fullcode)) return
  }
  const realcode  = `UPDATE ${sqlTable} ${fieldcode} WHERE id = ?`
  const values    = [this.objet.data.id]
  Ajax.send("db_exec.rb", {request: realcode, values: values, sql_table: sqlTable, sql_id: this.objet.data.id})
  .then(ret => {
    if (ret.error){
      erreur(ret.error)
    } else {
      if (ret.message) message(ret.message)
      // Updater la fiche avec les nouvelles valeurs envoyées
      // console.log("ret", ret)
      this.objet.data = ret.new_data
      this.rebuild()
    }
  })
}

execCodeDestroy(sqlTable, fieldcode){
  if (!confirm(`Veux-tu vraiment détruire l'élément ${this.objet.ref_brut}`)) return ;
  switch (this.objet.constructor.name) {
    case 'Icarien':
      var opts = this.objet.data.options.split('')
      opts[3] = "1"
      opts = opts.join('')
      this.execCodeUpdate(sqlTable, `SET options = "${opts}"`, {no_confirmation:true})
      message(`J'ai marqué l'icarien ${this.objet.pseudo} détruit.`)
      break;
    default:
      erreur(`Je ne sais pas encore détruire ce type d'élément.`)
  }
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
 * Cette méthode doit être surclassée par la classe héritante
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



/**
  * Ci-dessous, les méthodes de FILTRAGE de la liste des icariens (cf. le
  * mode d'emploi)
***/

// Filtrage par le statut
isStatutEquals(expected, div){
  const user_id = Number(div.getAttribute('data-id'))
  const user = Icarien.get(user_id)
  const bit16 = user.data.options.substring(16,17);
  switch (expected) {
    case 'actif':     return bit16 == "2"
    case 'inactif':   return bit16 == "4"
    case 'candidat':  return bit16 == "3"
    case 'recu':      return bit16 == "6"
    default: return false
  }
}
hasSignupAfter(date, div){
  const user = this.getUserOfDiv(div)
  return Number(user.data.created_at) >= date
}
hasSignupBefore(date, div){
  const user = this.getUserOfDiv(div)
  return Number(user.data.created_at) <= date
}
hasData(hval, div){
  const user = this.getUserOfDiv(div)
  for(var k in hval){
    var v = hval[k]
    if ( user.data[k] !== v ) { return false }
  }
  return true
}
getUserOfDiv(div){
  const user_id = Number(div.getAttribute('data-id'))
  return Icarien.get(user_id)
}

} // class Fiche
