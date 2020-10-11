"use strict";

function format_jjmmaaaa(timestamp) {
  return formate_date(timestamp, {day:'numeric', month:'numeric', year:'numeric'})
}
function format_jjmmaa(timestamp) {
  return formate_date(timestamp, {day:'numeric', month:'numeric', year:'2-digit'})
}
function formate_date(timestamp, options){
  const d = new Date()
  d.setTime(Number(timestamp) * 1000)
  return d.toLocaleDateString('fr-FR', options)
}
