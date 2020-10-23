"use strict";
class FicheLecture {
static prepare(){
  console.log("-> FicheLecture.prepare")
  // On observe toutes les fiches pour pouvoir les ouvrir et les fermer
  $('.fiche-lecture div.infos-projet').bind('click', this.toggleFiche.bind(this))
}
static toggleFiche(ev){
  const fiche = $(ev.currentTarget).parent();
  const header = fiche.find('div.header');
  const isHidden = header.hasClass('hidden');
  const method = isHidden ? 'removeClass' : 'addClass';
  header[method]('hidden');
  fiche.find('div.detail')[method]('hidden');
  fiche[isHidden?'addClass':'removeClass']('exergue')
}
constructor() {

}
}
