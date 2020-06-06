'use strict';
function AppliqueNom(field, idoc){
  var btn   = document.querySelector(`#buttondocument${idoc}`);
  var span  = document.querySelector(`#documentname${idoc}`);
  btn.classList.add('hidden')
  span.classList.remove('hidden')
  span.innerHTML = field.value
}
