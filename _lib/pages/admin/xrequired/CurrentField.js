'use strict';
/*
Méthodes communes pour l'administration
*/
class CurrentField {
  static insertBaliseVariable(){
    this.current || raise("Il faut sélectionner le champ !")
    this.current.insertBaliseVariable()
  }
  static setCurrent(obj){
    this.current = new CurrentField(obj) ;
  }
  static unsetCurrent(obj){
    this.current = null ;
  }

constructor(obj) {
  this.obj = obj
}

// Return true si le code courant est du code ERB
get isErb(){return this.value.indexOf('<%') > -1}

insertBaliseVariable(variable){
  variable = variable || 'VARIABLE'
  this.insert(this.isErb ? `<%= ${variable} %>` : `#{${variable}}`)
}

// Pour insérer un texte au curseur (alias de setSelectionTo)
insert(text){return this.setSelectionTo(text)}

// Pour régler la sélction
setSelectionTo(remplacement) {
  const start = this.obj.selectionStart;
  const end   = this.obj.selectionEnd;
  const before = this.value.slice(0, start);
  const after  = this.value.slice(end)
  this.value = before + remplacement + after;
}
getSelection(){
  const start = this.obj.selectionStart;
  const end   = this.obj.selectionEnd;
  return this.value.slice(start, end);
}

// ---------------------------------------------------------------------

observe(){

}

// ---------------------------------------------------------------------

get value(){return this.obj.value}
set value(v){this.obj.value = v}
}//Class CurrentField
