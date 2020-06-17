'use strict';


class AbsModule {
  static toggleView(etapeId){
    const divEtape = document.querySelector(`#content-etape-${etapeId}`)
    const method = divEtape.classList.contains('hidden') ? 'remove' : 'add' ;
    divEtape.classList[method]('hidden')
  }
  static observe(){
    document.querySelectorAll('.titre-etape').forEach(ptitre => {
      const etapeId = ptitre.getAttribute('data-id');
      ptitre.addEventListener('click', AbsModule.toggleView.bind(AbsModule, etapeId))
    })
    // On surveille les champs pour savoir dans lequel on
    // se trouve
    document.querySelectorAll('textarea, input[type="text"]').forEach(obj => {
      obj.addEventListener('focus', CurrentField.setCurrent.bind(CurrentField, obj))
      // Note : il ne faut pas défaire le champ courant au blur, sinon le
      // champ courant serait remis à null en allant cliquer un bouton
    })
  }
}
function afterReady(){
  AbsModule.observe()
}

function editTravailType(){
  var container = CurrentField.current
  container || raise("Il faut sélectionner le travail type à éditer")
  var wtype = container.getSelection()
  wtype.includes('travail_type') || raise("Il faut sélectionner le code du travail-type (depuis '<%=' jusqu'à '%>')")
  var res = wtype.match(/travail_type\(? ?'(.+)', ?'(.+)' ?\)?/);
  console.log("res, type", res, typeof(res))
  var [tout, dossier, travail]  = res
  console.log("dossier=%s, travail=%s", dossier, travail)
  window.open(`admin/modules?op=edit-twork&twdos=${dossier}&tw=${travail}`,"_blank")
}

function replBalMot(format, tout, mot_id, mot_mot){
  var r = format == 'erb' ? '<%= ' : '#{' ;
  r += `mot(${mot_id},"${mot_mot}")`
  r += format == 'erb' ? ' %>' : '}';
  return r
}
function replBalFilm(format, tout, film_id, film_titre){
  var r = format == 'erb' ? '<%= ' : '#{' ;
  r += `film(${film_id},"${film_titre}")`
  r += format == 'erb' ? ' %>' : '}';
  return r
}

const REG_BALISE_MOT  = /MOT\[([0-9]+)\|([^\]]+)\]/g;
const REG_BALISE_FILM = /FILM\[([0-9]+)\|([^\]]+)\]/g;

function remplaceBaliseMot(format/*'erb' ou 'md'*/){
  if (undefined === CurrentField.current) { return alert("Il faut mettre le curseur dans le champ concerné !")}
  const textarea = CurrentField.current.obj;
  // Il faut corriger tout le texte
  textarea.value = textarea.value
    .replace(REG_BALISE_MOT,window.replBalMot.bind(window,format))
    .replace(REG_BALISE_FILM,window.replBalFilm.bind(window,format))
}

const REG_BALISE_ERB = /<%=?([^%]+)%>/g
function replBalErb(tout, code){
  return `#{${code.trim()}}`
}
function balisesErbToMarkdown(container){
  container = container || CurrentField.current
  if (undefined === container) { return alert("Il faut mettre le curseur dans le champ concerné !")}
  const textarea = container.obj;
  textarea.value = textarea.value.replace(REG_BALISE_ERB, window.replBalErb.bind(window))
}
