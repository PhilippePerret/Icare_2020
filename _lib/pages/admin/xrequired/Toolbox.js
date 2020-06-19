'use strict';

class ToolBox {
  static observe(){
    const ObsData= [
      // [buttonId, classe, method]
      ['#toolbox-btn-save', ToolBox, 'submitForm'],
      ['#toolbox-btn-insert-variable', CurrentField, 'insertBaliseVariable'],
      ['#toolbox-btn-edit-wtype', ToolBox, 'editTravailType']
    ]
    ObsData.forEach(tierce => {
      const [buttonId, classe, method] = tierce ;
      const btn = this.obj.querySelector(buttonId)
      btn.addEventListener('click', classe[method].bind(classe))
    })
  }

  // Méthode qui permet de soumettre le formulaire
  static submitForm(){
    document.querySelector('form.edit-form').submit()
  }

  // Méthode qui permet d'éditer le travail type
  static editTravailType(){
    var container = CurrentField.current
    container || raise("Il faut sélectionner le travail type à éditer")
    var wtype = container.getSelection()
    wtype.includes('travail_type') || raise("Il faut sélectionner le code du travail-type (depuis '<%=' jusqu'à '%>')")
    var res = wtype.match(/travail_type\(? ?'(.+)', ?'(.+)' ?\)?/);
    var [tout, dossier, travail]  = res
    travail || raise("Ce que vous avez sélectionné ne ressemble pas à un travail type…");
    window.open(`admin/modules?op=edit-twork&twdos=${dossier}&tw=${travail}`,"_blank")
  }

  static get obj(){
    return this._obj || (this._obj = document.querySelector('#edit-toolbox'))
  }
}
