'use strict';
function DGet(selector, container){
  return (container||document).querySelector(selector)
}
/** ---------------------------------------------------------------------
  *   Pour la gestion des notes manuelles
  *
*** --------------------------------------------------------------------- */
class HandNotes {
/** ---------------------------------------------------------------------
*   CLASSE
*
*** --------------------------------------------------------------------- */
static init(){
  this.observe()
}
/**
* Méthode appelée quand on choisit une catégorie
Elle regarde si une note existe dans la catégorie choisie et la charge.
***/
static onChooseCategorie(ev){
  const cate = this.menuCategories.value
  Ajax
    .send('concours/load-note-manuelle.rb', {evaluator_id:EVALUATOR_ID, dossier_id: synid, categorie: cate})
    .then(ret => {
      console.log("Retour de load-note-manuelle", ret)
      this.noteField.value = ret.note
    })
}

/**
* Méthode appelée par le bouton "Enregistrer" pour enregistrer la note
***/
static onClickSaveBouton(){
  const cate = this.menuCategories.value
  const note = this.noteField.value
  Ajax.send('concours/save-note-manuelle.rb', {evaluator_id:EVALUATOR_ID, dossier_id: synid, categorie: cate, note: note})
  .then(ret => {
    message(`La note sur le projet, catégorie “${cate}”, a été enregistrée.`)
  })
}

static observe(){
  this.menuCategories.addEventListener('change', this.onChooseCategorie.bind(this))
  this.boutonSave.addEventListener('click', this.onClickSaveBouton.bind(this))
}
static get obj(){return this._obj || (this._obj = DGet('form#notes-manuelles'))}
static get menuCategories(){
  return this._menucates || (this._menucates = DGet('select#note-manuelle-categorie', this.obj))
}
static get noteField(){
  return this._notefield || (this._notefield = DGet('textarea#note-manuelle-content', this.obj))
}
static get boutonSave(){
  return this._btnsave || (this._btnsave = DGet('button#btn-save-note-manuelle', this.obj))
}
/** ---------------------------------------------------------------------
*
*   INSTANCE (pour une note ne particulier)
*
*** --------------------------------------------------------------------- */
constructor() {

}
}
