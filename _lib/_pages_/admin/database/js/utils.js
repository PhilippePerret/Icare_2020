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
  flash(msg, "message")
  return true
}
function erreur(msg){
  console.error(msg)
  flash(msg, "error")
  return false
}
function flash(msg, type){
  const div = document.createElement('DIV')
  div.className = type
  div.innerHTML = msg
  div.setAttribute("onclick","this.remove()")
  document.querySelector("#flash").appendChild(div)
}
