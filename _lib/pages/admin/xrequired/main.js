'use strict';
/*
Méthodes communes pour l'administration
*/

function setSelectionTo(container, remplacement){
  const start = container.selectionStart;
  const end   = container.selectionEnd;
  const before = container.value.slice(0, start);
  const after  = container.value.slice(end)
  container.value = before + remplacement + after;
}
function getSelectionOf(container){
  const start = container.selectionStart;
  const end   = container.selectionEnd;
  const selection = container.value.slice(start, end);
  return selection;
}
