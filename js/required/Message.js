'use strict';
/**
  * class Message
  * -------------
  *
  * Classe permettant de gérer les messages en javascript
**/
// Raccouri pour pouvoir utiliser `erreur("<le message d'erreur>")`
function erreur(err_msg) {
  new Message(err_msg, 'error').display()
}
// Raccourci pour pouvoir utiliser `message("<le message normal>")`
function message(msg) {
  new Message(msg, 'notice').display()
}
class Message {
  // Affichage du message
  static display(imsg){
    this.timer && this.stopTimer()
    if ( ! this.sectionMessages ) this.buildSectionMessages() ;
    this.sectionMessages.appendChild(imsg.span)
    this.startTimer(imsg.duration)
  }

  static startTimer(duree_secondes){
    this.timer = setTimeout(this.delete.bind(this), duree_secondes * 1000)
  }
  static stopTimer(){
    clearTimeout(this.timer) ;
    this.timer = null ;
  }

  static delete(){
    this.sectionMessages.innerHTML = '' ;
  }

  // Insertion de la section des messages
  // Rappel : elle n'est insérée que si elle n'existe pas
  static buildSectionMessages(){
    const sec = document.createElement('SECTION');
    sec.id = 'messages' ;
    document.body.insertBefore(sec, document.querySelector('section#header').nextSibling);
  }
  static get sectionMessages(){
    return this._secmess || (this._secmess = document.querySelector('section#messages'))
  }
  // ---------------------------------------------------------------------
  constructor(msg, type) {
    this.content = msg ;
    this.type = type ;
  }
  display() {
    this.constructor.display(this)
  }
  get span(){
    const span = document.createElement('DIV');
    span.className = `${this.type}s`;
    span.innerHTML = this.content;
    return span ;
  }
  // Durée en seconde du message
  get duration(){
    return this.content.split(' ').length * 0.75 ;
  }
}
