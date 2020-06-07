'use strict';
const MAIN_BUTTON = 'btn-send-work'

class RowDocument {
  constructor(obj){
    this.obj  = obj
    this.idoc = Number(obj.getAttribute('data-document-id')) ;
  }
  // Appelé quand on clique sur le bouton pour choisir le document
  onClick(ev) {
    document.querySelector(`#document${this.idoc}`).click() ;
  }
  // Appelé quand on clique sur la croix pour annuler le document
  onRemove(ev){
    this.show(this.bouton)
    this.hide(this.docNameSpan)
    this.fileField.value = '';
    this.hideNoteSpan()
  }
  // Méthode appelée quand on a choisi le fichier
  onChooseFile(){
    this.hide(this.bouton)
    this.show(this.docNameSpan)
    // console.log("this.fileField:", this.fileField);
    var docpath = this.fileField.value ;
    docpath = docpath.split('\\');
    docpath = docpath[docpath.length - 1];
    this.nameSpan.innerHTML = docpath ;
    this.showNoteSpan()
    this.show(this.mainButton)
  }
  observe(){
    this.bouton.addEventListener('click', this.onClick.bind(this));
    this.fileField.addEventListener('change', this.onChooseFile.bind(this));
    this.removeButton.addEventListener('click', this.onRemove.bind(this));
  }

  // Pour afficher le menu pour choisir la note
  showNoteSpan(){this.show(this.spanNote)}
  hideNoteSpan(){this.hide(this.spanNote)}

  show(obj){this.toggle(obj,true)}
  hide(obj){this.toggle(obj,false)}
  toggle(obj, show){ obj.classList[show?'remove':'add']('hidden')}

  get bouton(){
    return this._button || (this._button = this.obj.querySelector('.btn-choose'))
  }
  get removeButton(){
    return this._rembutton || (this._rembutton = this.obj.querySelector('.btn-remove'))
  }
  get fileField(){
    return this._filefield || (this._filefield = this.obj.querySelector(`#document${this.idoc}`))
  }
  get docNameSpan(){
    return this._docnamespan || (this._docnamespan = this.obj.querySelector('.doc-name-span'))
  }
  get nameSpan(){
    return this._namespan || (this._namespan = this.obj.querySelector('.doc-name'))
  }
  get spanNote(){
    return this._spannote || (this._spannote = this.obj.querySelector('.span-note'))
  }
  get mainButton(){
    return this._mainbutton || (this._mainbutton = document.querySelector(`.${MAIN_BUTTON}`))
  }
}

function observeDocuments(){
  document.querySelectorAll('.doc-field').forEach(row => {
    const rowDoc = new RowDocument(row)
    rowDoc.observe()
  })
}

onReady().then(()=>{
  observeDocuments()
})
