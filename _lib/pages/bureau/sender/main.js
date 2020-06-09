'use strict';
const MAIN_BUTTON = 'btn-send-work'

RowDocument.prototype.afterChooseFile = function(){
  console.log("-> afterChooseFile")
  this.showNoteSpan()
  this.show(this.mainButton)
  this.show(this.docNameSpan)
}
RowDocument.prototype.showNoteSpan = function(){this.show(this.spanNote)}
RowDocument.prototype.hideNoteSpan = function(){this.hide(this.spanNote)}

Object.defineProperties(RowDocument.prototype, {
  'docNameSpan':{
    get:function(){
      return this._docnamespan || (this._docnamespan = this.obj.querySelector('.doc-name-span'))
    }
  }
  , 'spanNote':{
    get:function(){
      return this._spannote || (this._spannote = this.obj.querySelector('.span-note'))
    }
  }
  , 'mainButton':{
    get:function(){
      return this._mainbutton || (this._mainbutton = document.querySelector(`.${MAIN_BUTTON}`))
    }
  }
})
