'use strict';
class Filmodico {
  static observe(){
    document.querySelectorAll('select.filmodico').forEach(select => {
      select.addEventListener('change', this.onChooseFilm.bind(this, select))
    })
  }

  static onChooseFilm(select, ev){
    const film_id = select.value
    const titre = select.options[select.selectedIndex].text
    const tag = `#{film(${film_id},"${titre}")}`;
    if (CurrentField.current){
      CurrentField.current.setSelectionTo(tag)
    } else {
      clip(tag)
      alert("J'ai mis la balise "+tag+" dans le presse-papier.")
    }
  }
}
