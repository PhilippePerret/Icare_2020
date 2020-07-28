'use strict';
/*
  Module très important pour la partie administration.
*/

// Appelé quand la page est prête
function afterReady(){
  document.querySelectorAll('.cb-statut').forEach( cb => {
    cb.addEventListener('click', onToggleCbStatut.bind(null, cb))
  })
}

// Quand on choisit un statut d'icarien, tous les icariens de ce statut
// s'affichent (et inversement).
function onToggleCbStatut(cb, ev) {
  const statut = cb.getAttribute('for').split('-')[2]
  const cbid = `#cb-statut-${statut}`
  const is_checked = !document.querySelector(cbid).checked
  const liste_src = is_checked ? 'icariens-out' : 'icariens'
  const liste_dst = document.querySelector(`select#${is_checked ? 'icariens' : 'icariens-out'}`)
  document.querySelectorAll(`select#${liste_src} option.${statut}`).forEach(opt => liste_dst.appendChild(opt))
}

// Simplement pour essayer si ajax fonctionne
function EssaiAjax(){
  Ajax
  .send('_essai_.rb', {message:"Le message transmis."})
  .then(console.log)
  .catch(console.error)
}
