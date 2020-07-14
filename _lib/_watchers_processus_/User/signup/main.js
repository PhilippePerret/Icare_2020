'use strict';

function afterReady(){
  document.querySelectorAll('.btn-notify-refus').forEach(link => {
    const wid = Number(link.getAttribute('data-wid'));
    console.log("wid:", wid)
    link.addEventListener('click', showButtonDestroySignup.bind(null, wid, link))
  })
}

/*
  Méthode qui va cacher le bouton "Notifier le refus" et afficher le
  bouton "Détruire la candidature".
*/
function showButtonDestroySignup(wid, link) {
  console.log("watcher:", wid)
  const watcher   = document.querySelector(`div#watcher-${wid}`);
  const btn_unrun = document.querySelector(`#unrun-button-${wid}`);
  // const btn_notif = watcher.querySelector(`a.btn-notify-refus`);
  btn_unrun.classList.remove('nodisplay')
  link.classList.add('nodisplay')
}
