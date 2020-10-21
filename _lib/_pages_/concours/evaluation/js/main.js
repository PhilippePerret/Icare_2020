"use strict";

$(document).ready(()=>{
  // $('#checklist').draggable();
  $('#checklist').addClass('hidden');
  // On instancie tous les synopsis sur la table et on les prépare
  Synopsis.instanciateAll();
  // On prépare la checklist physique
  CheckList.prepare();
})
