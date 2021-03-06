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
  console.log("checklist dans CheckList::openWith: ", this.checklist)
  this.setValues(checklist.score)
}
static onSave(ev){
  this.checklist.onSave.call(this.checklist, this.getValues())
}
// Méthode qui récupère les données de la checklist et les renvoie
static getValues(){
  let results = {}
  this.obj.find('select').each((i, select) => {
    var value = select.value ;
    if ( value != '-' && value != 'x') value = parseInt(value,10);
    Object.assign(results, {[select.name]: value})
  })
  return results
}
// On remplit la checklist avec les valeurs de +score+
// Toutes les valeurs non fournies sont mises à "-"
static setValues(score){
  // console.log("-> setValues:", score)
  this.obj.find('select').each((i, select) => {
    const key = select.name
    select.value = score[key] || '-';
  })
  this.updateGaugeDone()
}
static close(){
}
/**
  * Prépare la check list.
  * Pour le moment, ça consiste simplement à mettre un observateur d'event
  * sur son bouton "Enregistrer"
***/
static prepare(){
  this.obj.find('button#btn-save').bind('click', this.onSave.bind(this));
  this.obj.find('button#btn-only-undone').bind('click', this.showOnlyUndonesQuestions.bind(this));
  this.obj.find('button#btn-ecarter-non-answered').bind('click',this.ecarteAllNonAnswered.bind(this));
  this.obj.find('button#btn-mark-non-answered-ecarted').bind('click', this.markNonAnsweredAllEcarted.bind(this));
  this.obj.find('button#btn-see-all').bind('click', this.showAllQuestions.bind(this));
  this.obj.find('div.line-note select').bind('change', this.onChangeValueQuestion.bind(this));
  // Pour faire apparaitre les aides/explications
  this.obj.find('form div.withex div.line-note span.prop-name').bind('click', this.showExplication.bind(this))
  // Pour fermer les explications
  this.obj.find('form div.withex div.expli').bind('click', this.hideExplication.bind(this))
}

static showExplication(ev){
  const el = $(ev.target);
  const div = $(el.parent());
  const exp = div.prev();
  exp.removeClass('hidden')
}
static hideExplication(ev){
  $(ev.target).addClass('hidden');
}

// Méthode d'évènement appelée quand on change la valeur de la question
// On en profite pour actualiser la jauge d'avancée
static onChangeValueQuestion(ev){
  const men = $(ev.target);
  const div = $(men.parent())
  if ( men.val() == '-' ) {
    // Si la question devient une question non faite
    // (note : mais normalement c'est impossible puisqu'elle est cachée)
    div.addClass('undone') ; // si elle a été marquée non faites
  } else {
    div.removeClass('undone') ; // si elle a été marquée non faites
  }
  this.updateGaugeDone()
}

// Pour actualiser la jauge qui montre l'avancée du travail sur le
// synopsis
static updateGaugeDone(){
  let questionsDone = 0;
  this.obj.find('form select').each((i,menu) => {
    if ( menu.value != '-' ) ++ questionsDone ;
  });
  const questionsUndone = window.NOMBRE_QUESTIONS - questionsDone;
  const pct = 100 / (window.NOMBRE_QUESTIONS/questionsDone);
  const pctStr = parseInt(pct * 10, 10) / 10 ;
  this.obj.find('#checklist-gauge').css('width',`${pct}%`);
  this.obj.find('#checklist-gauge span.value').text(`${pctStr} %`)
}

// La checklist physique
static get obj(){
  return this._obj || (this._obj = $('#checklist'))
}

// Pour écarter toutes les réponses non données
static ecarteAllNonAnswered(ev){
  this.obj.find('div.line-note').each((i,div) => {
    div = $(div);
    const menu = $(div.find('select'));
    if (menu.val() == "-") menu.val('x')
  })
  message("J'ai écarté toutes les questions sans réponse.")
}
static markNonAnsweredAllEcarted(ev){
  this.obj.find('div.line-note').each((i,div) => {
    div = $(div);
    const menu = $(div.find('select'));
    if (menu.val() == "x") menu.val('-')
  })
  message("J'ai marqué non répondues toutes les questions précédemment écartées.")
}
// Pour ne montrer que les questions non répondues
static showOnlyUndonesQuestions(){
  this.obj.find('div.line-note').each((i,div) => {
    div = $(div);
    const menu = $(div.find('select'));
    if (menu.val() == "-"){
      div.addClass('undone')
      menu.removeClass('hidden')
    }
    else {menu.addClass('hidden')}
  })
  this.obj.find('button#btn-see-all').removeClass('discret')
}
// Pour montrer toutes les questions
static showAllQuestions(){
  this.obj.find('div.line-note').removeClass('undone');
  this.obj.find('div.line-note select').removeClass('hidden');
  this.obj.find('button#btn-see-all').addClass('discret');
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
      console.log("Retour de getScore :", ret)
      window.NOMBRE_QUESTIONS = ret.data_score.nombre_questions;
      this.score = ret.data_score.score || {};
      this.constructor.openWith.call(this.constructor, ev, this)
    })
  }
}

onSave(results){
  this.score = results ;
  this.saveScore().then(ret => {
    console.log("Retour de la sauvegarde des résultats :", ret);
    if (ret.error) erreur(ret.error)
    else {
      message(`Le nouveau score est enregistré. Nouvelle note : <span id="nouvelle-note">${ret.note}</span>.`);
      this.synopsis.updateNote(ret.note);
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
