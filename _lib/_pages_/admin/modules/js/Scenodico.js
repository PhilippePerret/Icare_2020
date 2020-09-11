'use strict';
class Scenodico {
  static observe(){
    document.querySelectorAll('select.scenodico').forEach(select => {
      select.addEventListener('change', this.onChooseMot.bind(this, select))
    })
  }

  static onChooseMot(select, ev){
    const mot_id = select.value
    const titre = select.options[select.selectedIndex].text
    const tag = `#{mot(${mot_id},"${titre}")}`;
    if (CurrentField.current){
      CurrentField.current.setSelectionTo(tag)
    } else {
      clip(tag)
      alert("J'ai mis la balise "+tag+" dans le presse-papier.")
    }
  }
}
