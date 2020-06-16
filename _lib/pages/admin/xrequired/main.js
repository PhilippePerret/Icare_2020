'use strict';
/*
Méthodes communes pour l'administration
*/
class CurrentField {
static setCurrent(obj){
  this.current = new CurrentField(obj) ;
}
static unsetCurrent(obj){
  this.current = null ;
}
constructor(obj) {
  this.obj = obj
}
insert(text){return this.setSelectionTo(text)}
setSelectionTo(remplacement) {
  const start = this.obj.selectionStart;
  const end   = this.obj.selectionEnd;
  const before = this.obj.value.slice(0, start);
  const after  = this.obj.value.slice(end)
  this.obj.value = before + remplacement + after;
}
getSelection(){
  const start = this.obj.selectionStart;
  const end   = this.obj.selectionEnd;
  return this.obj.value.slice(start, end);
}
}//Class CurrentField
