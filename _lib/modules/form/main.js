'use strict';

class RowDocument {
  constructor(obj, name){
    this.obj  = obj
    this.name = name
    this.idoc = Number(obj.getAttribute('data-document-id')) ;
  }
  // Appelé quand on clique sur le fakeButton pour choisir le document
  onClick(ev) {
    this.realFileButton.click()
  }
  // Appelé quand on clique sur la croix pour annuler le document
  onRemove(ev){
    this.show(this.fakeButton)
    this.hide(this.nameSpan)
    this.hide(this.resetButton)
    this.realFileButton.value = '';
  }
  // Méthode appelée quand on a choisi le fichier
  onChooseFile(){
    this.hide(this.fakeButton)
    this.show(this.nameSpan)
    this.show(this.resetButton)
    // console.log("this.realFileButton:", this.realFileButton);
    var docpath = this.realFileButton.value ;
    docpath = docpath.split('\\');
    docpath = docpath[docpath.length - 1];
    this.nameSpan.innerHTML = docpath ;
  }
  observe(){
    this.fakeButton.addEventListener('click', this.onClick.bind(this));
    this.realFileButton.addEventListener('change', this.onChooseFile.bind(this));
    this.resetButton.addEventListener('click', this.onRemove.bind(this));
  }

  show(obj){this.toggle(obj,true)}
  hide(obj){this.toggle(obj,false)}
  toggle(obj, show){ obj.classList[show?'remove':'add']('hidden')}

  get realFileButton(){
    return this._realfilebtn || (this._realfilebtn = this.obj.querySelector(`#document-${this.name}`))
  }
  get fakeButton(){
    return this._fakebutton || (this._fakebutton = this.obj.querySelector('.file-choose'))
  }
  get resetButton(){
    return this._resetbtn || (this._resetbtn = this.obj.querySelector('.file-reset'))
  }
  get nameSpan(){
    return this._namespan || (this._namespan = this.obj.querySelector('.file-name'))
  }
}

function observeDocuments(){
  document.querySelectorAll('span.file-field').forEach(row => {
    const name = row.getAttribute('data-name')
    const rowDoc = new RowDocument(row, name)
    rowDoc.observe()
    console.log("Document observé :", rowDoc)
  })
}

onReady().then(()=>{
  observeDocuments()
})
