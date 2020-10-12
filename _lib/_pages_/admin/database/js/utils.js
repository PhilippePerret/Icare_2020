"use strict";

function stopEventAsync(ev){
  return new Promise((ok,ko) => {
    ev.stopPropagation()
    ev.preventDefault()
    ok()
  })
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
