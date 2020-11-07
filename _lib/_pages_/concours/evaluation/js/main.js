"use strict";

$(document).ready(()=>{
  if ($("div#fiches-lecture").length) {
    // <= Affichage de la liste des fiches de lecture
    // => On place les observeurs
    FicheLecture.prepare();
  } else {
    // <= Affichage des fiches d'évaluation
    // => On préparer l'évaluation
    // $('#checklist').draggable();
    // $('#checklist').addClass('hidden');
    // On instancie tous les synopsis sur la table et on les prépare
    // Synopsis.instanciateAll();
    // On prépare la checklist physique
    CheckList.prepare();
    console.log("synid = ", synid);
    const syno = new Synopsis(synid);
    syno.prepare();
    syno.checklist.open();


  }
})
