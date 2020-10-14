"use strict";
class IDocument extends Objet {
/**
 * CLASSE
**/

static get OWN_DATA(){
  return [
      {suffix: 'icarien',     method:'f_icarien',       field_method:'innerHTML'}
    , {suffix: 'original',    method:'f_original_name', field_method:'innerHTML'}
  ]
}

static get color(){return 'mediumpurple'}
static get table(){return 'icdocuments'}
/**
 * INSTANCE
**/
constructor(data, ietape) {
  super(data, ietape)
  this.ietape = ietape
}
get ref(){
  return this._ref || (this._ref = `<span class="ref"><span class="nature">doc</span><span class="name">${this.data.original_name}</span><span class="id">#${this.data.id}</span><span class="date">${formate_jjmmaa(this.data.created_at)}</span></span>`)
}

} // class IDocument

class FicheIDocument extends Fiche {
constructor(objet) {
  super(objet)
}

build_all_own_data(){
  this.build_own_data("Icarien", this.spanProperty('icarien', this.f_icarien))
  this.build_own_data("Nom fichier/original_name", this.spanProperty('original', this.f_original))
  this.build_own_data("Créé le/time_original", this.data.time_original, 'date')
  this.build_own_data("Commenté le/time_comments", this.data.time_comments, 'date')
  this.build_own_data("Doc. original", `<span id="doc-lien-${this.data.id}-original">Recherche du document…</span>`)
  this.build_own_data("Doc. comments", `<span id="doc-lien-${this.data.id}-comments">Recherche du document…</span>`)

  this.checkExistenceFichiersOnQDD()
}

get f_icarien(){return this.objet.user.as_link}
get f_original(){return this.data.original_name}

/**
  * Méthode qui checke l'existence des fichiers PDF pour instruire correctement
  * les balises pour les charger
***/
checkExistenceFichiersOnQDD(){
  const pathToOriginal = this.path_to_document('original')
  const pathToComments = this.path_to_document('comments')
  Ajax.send("check_existence_qdd_doc.rb", {original:pathToOriginal})
  .then(ret => {
    console.log("Retour check existence : ", ret)
    var rempOriginal ;
    if (ret.original_exists) {rempOriginal = this.lien_original_pdf}
    else { rempOriginal = "- document inexistant -"}
    var rempComments ;
    if (ret.comments_exists) {rempComments = this.lien_comments_pdf}
    else { rempComments = "- document inexistant -"}
    document.querySelector(`#doc-lien-${this.data.id}-original`).innerHTML = rempOriginal
    document.querySelector(`#doc-lien-${this.data.id}-comments`).innerHTML = rempComments
  })

}

get lien_original_pdf(){
  return `<a href="${this.path_to_document('original')}" target="_blank">Ouvrir le fichier PDF</a>`
}
get lien_comments_pdf(){
  return `<a href="${this.path_to_document('comments')}" target="_blank">Ouvrir le fichier PDF</a>`
}
path_to_document(type){
  const docName = this[`name_of_${type}`]
  return `./_lib/data/qdd/${this.module_id}/${docName}`
}
get name_of_original(){
  return this._nameoforiginal || (this._nameoforiginal = this.name_of_document('original'))
}
get name_of_comments(){
  return this._nameofcomments || (this._nameofcomments = this.name_of_document('comments'))
}
name_of_document(type){
  var dn = []
  dn.push(this.module_name)
  dn.push('etape')
  dn.push(this.numero_etape)
  dn.push(this.pseudo_name)
  dn.push(this.data.id)
  dn.push(type)
  return dn.join('_') + ".pdf"
}
// Le pseudo, mais toujours en version minuscules et majuscule au début
get pseudo_name(){
  return titleize(this.objet.user.data.pseudo)
}
get numero_etape(){
  return this.ietape.data.numero
}
get module_id(){
  return this.imodule.data.abs_id
}
get module_name(){
  return camelize(this.imodule.data.module_short_name)
}
get ietape(){
  return this.objet.owner
}
get imodule(){
  return this.objet.owner.owner
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
