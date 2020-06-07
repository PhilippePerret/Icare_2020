'use strict';
function AppliqueNom(field, idoc){
  var btn  = document.querySelector(`#buttondocument${idoc}`);
  var span = document.querySelector(`#documentname${idoc}`);
  btn.classList.remove('inline-block')
  btn.classList.add('hidden')
  span.classList.remove('hidden')
  span.classList.add('inline-block')
  span.innerHTML = field.value
}
