'use strict';

/**
  Reçoit une définition des propriétés, par exemple :
  [
      {name:'id', hname: "#", type:'hidden'}
    , {name:'prenom', hname, 'Prénom'}
    , ...
  ]
  … et retourne un +container+ avec les champs de formulaires désirés
  +container+ peut être créé simplement par DCreate('DIV')
**/

function DGet(selector, container){
  container = container || document
  return container.querySelector(selector)
}

/**
  Retourne une ligne div contenant un libellé et une valeur
**/
function DCreateDivLV(libelle, valeur, attrs){
  attrs = attrs || {}
  var dataLibelle = {class:'libelle', text:libelle}
  var dataValue   = {class:'value', text:valeur}
  if (attrs.libelleSize){
    libsize = attrs.libelleSize
    delete attrs.libelleSize
    Object.assign(dataLibelle, {style:`width:${libsize};`})
  }
  let div = DCreate('DIV', attrs)
  div.appendChild(DCreate('SPAN',dataLibelle))
  div.appendChild(DCreate('SPAN',dataValue))
  return div
}

function DCreate(tagName,attrs){
  attrs = attrs || {}
  var o = document.createElement(tagName);
  for(var attr in attrs){
    var value = attrs[attr]
    switch (attr) {
      case 'text': o.innerHTML = value; break;
      case 'inner': o.appendChild(value); break;
      case 'css': case 'class': o.className = value ; break;
      default: o.setAttribute(attr, value)
    }
  }
  return o;
}

/** ---------------------------------------------------------------------
  *   Classe DSelect
  *   --------------
  * Pour la gestion des menus "flottant", c'est-à-dire des menus qui
  * peuvent se déplacer et apparaitre où l'on veut.
  *
  * Utilisation
  * -----------
  *   const m = new DSelect(data) // cf. ci-dessous pour +data+
  *   m.open({:x, :y, :value})
  *
  * Requis
  * ------
  * (note : 'data', ci-dessous, est la table envoyée à l'instanciation du
  *  menu)
  *   * Un identifiant défini dans data[:id]
  *   * Pour fonctionner, le menu a besoin d'une table de valeurs qui
  *     contient en clé la valeur proprement dites et en valeur une table
  *     définissant au moins le texte apparant à utiliser.
  *     table = {val1 => {text:texte1}, val2 => {text:texte2}, etc.}
  *     Cette table est transmise à l'instanciation, dans la propriété
  *     :values (les valeurs) => data[:values]
  *     On peut indiquer une valeur par défaut par data[:default_value]
  *   * Une méthode à appeler lorsque la valeur est changée dans le menu.
  *     data[:onchange]
  * Optionnel
  * ---------
  *   * data[:default_value] peut définir la valeur par défaut dans le
  *     menu.
  *   * {String} data[:css] peut définir la ou les classes CSS à appliquer
  *     au menu.
  *   * {Bool} data[:hidden] À true pour indiquer que le menu doit être
  *     masquer. <dselect>.show() le rendra visible.
*** --------------------------------------------------------------------- */
class DSelect {
constructor(data) {
  this.data   = data
  this.id     = data.id
  this.values = data.values
  this.hidden = data.hidden || false
  this.default_value = data.default_value || null

  this.values || console.error(`Il faut définir les valeurs du menu #${this.id} !`)

  this.built = false
}

/**
  * Méthodes publiques
***/
open(options){
  this.built || this.build()
  this.positionne(options)
  if(options.value) this.setValue(options.value)
}

/**
  * Méthode appelée quand on change une valeur. Si la méthode data.onchange
  * est définie, on l'appelle avec la valeur.
***/
onChange(ev){
  if (this.data.onchange) this.data.onchange.call(null, this.menu.value)
}


close(){
  this.menu.classList.add('hidden')
}

/**
  * Pour définir la valeur sélectionnée
***/
setValue(value){
  this.menu.value = value
}
/**
  * Pour positionner le menu à l'endroit voulu
  * +options+ doit définir :x et :y
***/
positionne(options){
  if (options.y) this.menu.style.top = options.y
  if (options.x) this.menu.style.left = options.x
}

get menu(){
  return this._menu || this.build()
}
/**
  * Construction du menu
***/
build(){
  const menu = DCreate('SELECT', {id: this.id, css:this.cssClasses})
  for(var v in this.values){
    var opt = DCreate('OPTION',{value:v, text:this.values[v].text})
    if ( v == this.default_value ) opt.setAttribute('selected', "SELECTED")
    menu.appendChild(opt)
  }
  document.querySelector('body').appendChild(menu)
  // On le met dans la variable
  this._menu = menu
  // On observe ce menu
  this.observe()
  this.built = true
  // On le retourne
  return menu
}
observe(){
  this.menu.addEventListener('change', this.onChange.bind(this))
}

get cssClasses(){
  var c = []
  c.push('dselect')
  if(this.data.hidden) c.push('hidden')
  if(this.data.css||this.data.class) c.push.apply(c, this.data.css||this.data.class)
  return c.join(' ')
}
}
