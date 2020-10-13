"use strict";

function stopEventAsync(ev){
  return new Promise((ok,ko) => {
    ev.stopPropagation()
    ev.preventDefault()
    ok()
  })
}

function titleize(str){
  str = str.toLowerCase().split('')
  str[0] = str[0].toUpperCase()
  return str.join('')
}
function camelize(str){
  str = str.split('_')
  var fin = []
  str.forEach(seg => fin.push( titleize(seg) ))
  return fin.join('')
}

function formate_jjmmaaaa(timestamp) {
  return formate_date(timestamp, {day:'numeric', month:'numeric', year:'numeric'})
}
function formate_jjmmaa(timestamp) {
  return formate_date(timestamp, {day:'numeric', month:'numeric', year:'2-digit'})
}

/**
  Méthode générique
**/
function formate_date(timestamp, options){

  switch (options) {
    case 'date':
      options = {day:'numeric', month:'short', year:'numeric'}
      break
    case 'date-time':
      options = {day:'numeric', month:'short', year:'numeric', hour:'numeric', minute:'numeric'}
      break
    default:
      // Laisser tel quel
  }

  const d = new Date()
  d.setTime(Number(timestamp) * 1000)
  return d.toLocaleDateString('fr-FR', options)
}


function message(msg){
  console.info(msg)
  new IMessage(msg, "message").show()
  return true
}
function erreur(msg){
  console.error(msg)
  new IMessage(msg, "error").show()
  return false
}

class IMessage {
/**
  * CLASSE
***/
static remove(imessage){
  imessage = null
}
static get container(){
  return this._container || (this._container = document.querySelector("#flash"))
}
/**
  * INSTANCE
***/
constructor(msg, type) {
  this.message = msg
  this.type    = type // aka class CSS
}
show(){
  this.build()
  this.observe()
}
close(){
  this.obj.remove()
  clearTimeout(this.timer)
  this.timer = null
  this.constructor.remove(this)
}
build(){
  const div = document.createElement('DIV')
  div.className = this.type
  div.innerHTML = this.message
  this.constructor.container.appendChild(div)
  this.obj = div
}
observe(){
  this.obj.setAttribute("onclick","this.remove()")
  this.timer = setTimeout(this.close.bind(this), this.duree)
}
get duree(){
  const nombre_mots = this.message.split(" ").length
  return nombre_mots * 1 * 1000
}
}
