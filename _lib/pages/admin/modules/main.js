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
