'use strict';

function onReady() {
  return new Promise(function(ok,ko){
    let timer = setInterval(function(){
      if('complete'===document.readyState){clearInterval(timer);ok()}
    },10)
  })
}

onReady().then(()=>{
})
.catch(err => {
  console.error(err)
  // TODO Il faudra aussi la signaler à l'interface
})
