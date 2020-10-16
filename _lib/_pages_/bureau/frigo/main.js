'use strict';

/*
  Quand on charge la page de la discussion, on doit
  toujours scroller en bas.
*/
function afterReady(){
  if (window.location.search.indexOf('disid=') > -1){
    window.scrollTo(0, window.innerHeight+10000);
  }
}
