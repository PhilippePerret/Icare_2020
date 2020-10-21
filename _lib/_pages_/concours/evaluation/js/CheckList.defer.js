"use strict";
/** ---------------------------------------------------------------------
  *   La checklist d'un synopsis
  *
*** --------------------------------------------------------------------- */
class CheckList {
/** ---------------------------------------------------------------------
  *   CLASSE
  *
*** --------------------------------------------------------------------- */

// Ouvre la checklist pour la checklist du synopsis +checklist+
// +ev+ Evènement permettant de placer la fenêtre
static openWith(ev, checklist){
  this.checklist = checklist ; // utile pour onSave
  this.obj.removeClass('hidden')
  const pos = {top: ev.target.offsetTop+'px', left:ev.target.offsetLeft+'px'}
  this.obj.css(pos);
  this.obj.find('.titre').text(checklist.synopsis.titre)
}
static onSave(ev){
  this.checklist.onSave.call(this.checklist, this.getValues())
  this.close();
}
// Méthode qui récupère les données de la checklist et les renvoie
static getValues(){
  let results = {}
  this.obj.find('select').each((i, select) => {
    var value = select.value ;
    if ( value != "-" ) value = parseInt(value,10);
    Object.assign(results, {[select.name]: value})
  })
  return results
}
static setValues(values){

}
static close(){
  this.obj.addClass('hidden')
}
/**
  * Prépare la check list.
  * Pour le moment, ça consiste simplement à mettre un observateur d'event
  * sur son bouton "Enregistrer"
***/
static prepare(){
  this.obj.find('button#btn-save').bind('click', this.onSave.bind(this))
}
// La checklist physique
static get obj(){
  return this._obj || (this._obj = $('#checklist'))
}
/** ---------------------------------------------------------------------
  *   INSTANCE
  *
*** --------------------------------------------------------------------- */
constructor(synopsis/*Instance Synopsis*/) {
  this.synopsis = synopsis;
}
/**
  * Demande d'ouverture de la fiche d'évaluation du synopsis associé
***/
open(ev){
  if(this.score){this.constructor.openWith(ev, this)}
  else {
    this.getScore().then(ret => {
      this.score = ret.score;
      this.constructor.openWith.call(this.constructor, ev, this)
    })
  }
}

onSave(results){
  console.log("Je dois sauver les résultats :", results);
  this.score = results ;
  this.saveScore().then(ret => {
    if (ret.error) erreur(ret.error)
    else {
      message("Nouveau score enregistré.");
      this.synopsis.updateNote(ret.note_generale);
      this.synopsis.updatePourcentReponses(ret.pourcentage_reponses)
    }
  });
}
getScore(){
  return Ajax.send("concours/get_score.rb", {evaluator:EVALUATOR_ID, synopsis_id:this.synopsis.id})
}
saveScore(){
  return Ajax.send("concours/save_score.rb", {evaluator:EVALUATOR_ID, synopsis_id:this.synopsis.id, score: this.score})
}

}// /Checklist
