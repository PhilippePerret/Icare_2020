'use strict';
/*
  Module très important pour la partie administration.
*/


function EssaiAjax(){
  Ajax
  .send('_essai_.rb', {message:"Le message transmis."})
  .then(res => {
    console.log("retour ajax", res)
  })
  .catch(console.error)
}
