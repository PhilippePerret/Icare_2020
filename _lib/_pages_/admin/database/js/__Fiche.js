"use strict";
/**

  <fiche>.sectionOwnData
      Section contenant les données propres de l'objet
  <fiche>.sectionListing
      Section contenant les éléments de l'objet (par exemple les documents
      pour une étape)
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
  // documents de l'étape.
  this.sectionListing = document.createElement('DIV')
  this.sectionListing.className = "listing"
  this.obj.appendChild(this.sectionListing)

  // La partie en bas de fiche pour envoyer une requête
  const divreq = document.createElement('DIV')
  divreq.className = "div-request"
  const reqfield = document.createElement('INPUT')
  reqfield.setAttribute('placeholder', "Pseudo-code Mysql")
  reqfield.type = "text"
  divreq.appendChild(reqfield)
  this.obj.appendChild(divreq)

  // On ajoute la fiche au body et on la surveille
  document.querySelector("section#body").appendChild(this.obj)
  $(this.obj).draggable({})
  $(this.obj).css({top:'20px', right:'20px'})
  // Pour activer la fiche
  this.obj.addEventListener('click', Fiche.select.bind(Fiche, this))

  this.build_all_own_data()
  this.extra_build()

  this.built = true
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
  label.innerHTML = libelle
  label.setAttribute("title", `Pseudo-sql proprety: ${prop_name}`)
  line.appendChild(label)
  label.addEventListener('click', this.giveValue.bind(this, "Le nom de la propriété est", prop_name))

  // Valeur
  let value ;
  let real_value = null;
  if ( valeur && "object" == typeof(valeur) ) {
    value = valeur;
  } else {
    value = document.createElement('SPAN')
    value.className = 'own-data-value linked'
    if ( !valeur ) {
      valeur = "n/d"
    } else {
      switch (type) {
        case 'date':
          real_value = valeur
          var d = new Date()
          d.setTime(Number(valeur) * 1000)
          valeur = d.toLocaleDateString('fr-FR', {day:'numeric', month:'short', year:'numeric', hour:'numeric', minute:'numeric'})
          break;
        default:
          // rien à faire
      }
    }
    value.innerHTML = valeur
  }
  line.appendChild(value)
  if ( real_value ) {
    value.addEventListener('click', this.giveValue.bind(this, "La valeur réelle est", real_value))
  }

  this.sectionOwnData.appendChild(line)
}

} // class Fiche
