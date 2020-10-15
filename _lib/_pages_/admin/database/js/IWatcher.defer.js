"use strict";
class IWatcher extends Objet {
/**
 * CLASSE
**/
static get OWN_DATA(){
  return [
      {suffix:'owner',        method:'f_owner',         field_method:'innerHTML'}
    , {suffix:'created_at',   method:'f_created',       field_method:'innerHTML'}
    , {suffix:'updated_at',   method:'f_updated',       field_method:'innerHTML'}
  ]
}
static get color(){return 'mediumaquamarine'}
static get table(){return 'watchers'}

/**
 * INSTANCE
**/
constructor(data, owner) {
  super(data, owner)
}
get ref(){
  return this._ref || (this._ref = `<span class="ref"><span class="nature">watcher</span><span class="name">${this.data.absdata.titre}</span><span class="id">#${this.data.objet_id}</span></span>`)
}

} // class IWatcher

class FicheIWatcher extends Fiche {
constructor(data) {
  super(data)
}

/**
 * Construction des données propres au watcher
**/
build_all_own_data(){
  this.build_own_data("Propriétaire", this.spanProperty('owner', this.f_owner))
  this.build_own_data("WType/wtype", this.spanProperty('wtype', this.data.wtype))
  this.build_own_data("Objet", this.f_objet)
  this.build_own_data("Propriétaire/user_id", this.objet.user.as_link)
  this.build_own_data("Créé le/created_at", this.spanProperty('created_at', this.f_created_at))
  this.build_own_data("Modifié le/updated_at", this.spanProperty('updated_at', this.f_updated_at))
  this.build_own_data("Déclenchement/triggered_at", this.data.triggered_at, 'date-time')
  this.build_own_data("Paramètres/params", this.data.params)
}

get f_objet(){
  // On doit trouver l'objet en fonction du wtype (est-il chargé en javascript)
  return "[TODO à définir - lien]"
}

/**
 * Construction des outils propres aux watchers TODO
**/
build_own_tools(){}

/**
 * Construit les données supplémentaires
 *
 * Pour les document, ça ne correspond à rien (ou alors on pourrait faire
 * document original et commentaires)
 */
extra_build(){
}
} // class FicheIWatcher
