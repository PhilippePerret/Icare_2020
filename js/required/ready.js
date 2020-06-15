'use strict';

function onReady() {
  return new Promise(function(ok,ko){
    let timer = setInterval(function(){
      if('complete'===document.readyState){clearInterval(timer);ok()}
    },10)
  })
}

onReady().then(()=>{
  // Pour faire apparaitre le bouton "haut de page" quand on scroll
  window.onscroll = function(ev) {
   document.getElementById("to-top-button").className = (window.pageYOffset > 100) ? "visible" : "hidden";
  };
  // Pour surveiller le bouton haut de page
  document.querySelector('#to-top-button').addEventListener('click', window.scrollTo.bind(window,0,0))
  // Pour appeler une méthode d'initialisation
  if ('function' == typeof(afterReady)) { afterReady.call()}
})
.catch(err => {
  console.error(err)
  // TODO Il faudra aussi la signaler à l'interface
})
