"use strict";
/** ---------------------------------------------------------------------
  *   Class Synopsis
  *   --------------
  *   Pour le traitement général d'un synopsis.
  *
*** --------------------------------------------------------------------- */
class Synopsis {
/** ---------------------------------------------------------------------
  *   CLASSE
  *
*** --------------------------------------------------------------------- */

// Instancie toutes les fiches de synopsis présentes sur la table pour
// en faire des instances Synopsis prêtes à fonctionner
static instanciateAll(){
  this.tableItems = {}
  $('div.synopsis').each((i, divsyn) => {
    const synid = $(divsyn).data('id');
    const syno = new Synopsis(synid);
    syno.prepare();
    Object.assign(this.tableItems, {[synid]: syno})
  })
}
/** ---------------------------------------------------------------------
  *   INSTANCE
  *
*** --------------------------------------------------------------------- */
/**
  * On instancie le synopsis avec son ID, c'est-à-dire "concurrent_id-annee"
***/

constructor(id) {
  this.id = id
}
prepare(){
  this.obj = $(`#synopsis-${this.id}`)
  this.observe();
}

onClickNote(ev){
  this.wantEvaluate(ev);
}
wantEvaluate(ev){
  this.checklist.open(ev);
}

// Pour actualiser la note (après remontée des résultats ou modification)
updateNote(note){
  this.obj.find('.note-generale').text(note)
}
updatePourcentReponses(value){
  this.obj.find('.pct-reponses').text(value);
  this.obj.find('.jauge-pct-reponses-done').css({width:`${value}%`})
}


get titre(){
  return this._titre || (this._titre = this.obj.find('.titre').text())
}
// La checklist du synopsis
get checklist(){
  return this._checklist || ( this._checklist = new CheckList(this) )
}

// Observation de la carte du synopsis
observe(){

  // Pour évaluer le synopsis, on peut soit cliquer sur le chiffre soit
  // cliquer sur le bouton "évaluer"
  this.obj.find('.note-generale').bind('click', this.onClickNote.bind(this))
  this.obj.find('.btn-evaluate').bind('click',this.wantEvaluate.bind(this))
}

}// Synopsis
