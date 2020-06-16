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
  }
}
function afterReady(){
  AbsModule.observe()
}

function replBalMot(format, tout, mot_id, mot_mot){
  var r = format == 'erb' ? '<%= ' : '#{' ;
  r += `mot(${mot_id},"${mot_mot}")`
  r += format == 'erb' ? ' %>' : '}';
  return r
}
const REG_BALISE_MOT = /MOT\[([0-9]+)\|([^\]]+)\]/g;
function remplaceBaliseMot(format/*'erb' ou 'md'*/){
  const textarea = document.querySelector("textarea[name=\"etape_travail\"]");
  const SEL = getSelectionOf(textarea);
  if ( SEL != '' ) {
    // Il faut corriger seulement la sélection
    let remp = SEL.replace(REG_BALISE_MOT, window.replBalMot.bind(window,format))
    setSelectionTo(textarea, remp)
  } else {
    // Il faut corriger tout le texte
    textarea.value = textarea.value.replace(REG_BALISE_MOT,window.replBalMot.bind(window,format))
  }
}

const REG_BALISE_ERB = /<%=?([^%]+)%>/g
function replBalErb(tout, code){
  return `#{${code.trim()}}`
}
function balisesErbToMarkdown(){
  const textarea = document.querySelector("textarea[name=\"etape_travail\"]");
  if ( !confirm("Je vais remplacer '<%= ... %>' par '#{...}' dans tout le texte.") ) return
  textarea.value = textarea.value.replace(REG_BALISE_ERB, window.replBalErb.bind(window))
}
