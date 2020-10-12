"use strict";
class IDocument extends Objet {
constructor(data, ietape) {
  super(data, ietape)
  this.ietape = ietape
}
get ref(){
  return this._ref || (this._ref = `<span class="ref"><span class="nature">doc</span><span class="name">${this.data.original_name}</span><span class="id">#${this.data.id}</span><span class="date">${formate_jjmmaa(this.data.created_at)}</span></span>`)
}

static get color(){return 'mediumpurple'}

} // class IDocument

class FicheIDocument extends Fiche {
constructor(data) {
  super(data)
}

build_all_own_data(){
  this.build_own_data("Nom fichier/original_name", this.data.original_name)
  this.build_own_data("Créé le/time_original", this.data.time_original, 'date')
  this.build_own_data("Commenté le/time_comments", this.data.time_comments, 'date')
}

/**
 * Construit les données supplémentaires
 *
 * Pour les document, ça ne correspond à rien (ou alors on pourrait faire
 * document original et commentaires)
 */
extra_build(){
}
} // class FicheIDocument
