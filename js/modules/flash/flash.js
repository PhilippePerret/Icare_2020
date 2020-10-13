/** ---------------------------------------------------------------------
  *   GESTION DES MESSAGES À L'UTILISATEUR
  *
  *   message("<msg>")    Écrit le message <msg> à l'écran puis le fait
  *                       disparaitre.
  *   erreur("<msg>")     Écrit le message d'erreur <msg> à l'écran puis
  *                       le fait disparaitre.
  *
  * Chargement du module
  * --------------------
  * Appeler `html.load_module_js('flash')` dans le fichier ruby principal
  * de la partie qui doit l'utiliser.
  *
*** --------------------------------------------------------------------- */

function message(msg){
  console.info(msg)
  new IMessage(msg, "message").show()
  return true
}
function erreur(msg){
  console.error(msg)
  new IMessage(msg, "error").show()
  return false
}

class IMessage {
/**
  * CLASSE
***/
static remove(imessage){
  imessage = null
}
static get container(){
  return this._container || (this._container = document.querySelector("#flash"))
}
/**
  * INSTANCE
***/
constructor(msg, type) {
  this.message = msg
  this.type    = type // aka class CSS
}
show(){
  this.build()
  this.observe()
}
close(){
  this.obj.remove()
  clearTimeout(this.timer)
  this.timer = null
  this.constructor.remove(this)
}
build(){
  const div = document.createElement('DIV')
  div.className = this.type
  div.innerHTML = this.message
  this.constructor.container.appendChild(div)
  this.obj = div
}
observe(){
  this.obj.setAttribute("onclick","this.remove()")
  this.timer = setTimeout(this.close.bind(this), this.duree)
}
get duree(){
  const nombre_mots = this.message.split(" ").length
  return nombre_mots * 1 * 1000
}
}
