"use strict";

$(document).ready(()=>{
  if ($("div#fiches-lecture").length) {
    // <= Affichage de la liste des fiches de lecture
    // => On place les observeurs
    FicheLecture.prepare();
  } else {
    CheckList.prepare();
    const syno = new Synopsis(synid);
    syno.prepare();
    syno.checklist.open();


  }
})
