/** ---------------------------------------------------------------------
  *   Méthodes pour la gestion des évènements
  *
*** --------------------------------------------------------------------- */

/**
  * Pour stopper la propagation et le comportement par défaut d'un évènement
  * de façon asynchrone.
  * Usage
  * stopEventAsync(ev).then(fais ça)
***/
function stopEventAsync(ev){
  return new Promise((ok,ko) => {
    ev.stopPropagation()
    ev.preventDefault()
    ok()
  })
}

// Pour stopper la propagation et le comportement par défaut d'un évènement
function stopEvent(ev) {
  if (!ev) return false;
  ev.stopPropagation()
  ev.preventDefault()
  return false
}
