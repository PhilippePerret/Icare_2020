'use strict';

/** ---------------------------------------------------------------------
  *   Contrôle du formulaire d'inscription
  *
*** --------------------------------------------------------------------- */
class MyForm {
  constructor(form_id) {
    this.id = form_id;
    this.obj = document.querySelector(`form#${form_id}`);
  }

  // Méthode appelée à la soumission du formulaire d'inscription
  isOK(){
    try {
      this.fields['patronyme'].isOK || raise();
      this.fields['mail'].isOK || raise();
      this.fields['mail_confirmation'].isOK || raise();
      this.obj.querySelector('#p_reglement').checked || raise("Il faut approuver le règlement en cochant la case.") // constant ruby
      return true ;
    } catch (err) {
      if (err == "Error") err = null ;
      err = err || "Le formulaire est invalide, merci de le remplir avec soin.";
      erreur(err);
      return false ;
    }
  }
  // Observation du formulaire
  observe(){
    this.fields = {}
    Object.assign(this.fields, {'patronyme': new FormField(this, 'patronyme')});
    Object.assign(this.fields, {'mail': new FormField(this, 'mail')});
    Object.assign(this.fields, {'mail_confirmation': new FormField(this, 'mail_confirmation')});
  }
}

class FormField {
constructor(form, id /* p.e. 'mail' */) {
  this.form = form ;
  this.id = id ;
  this.obj_id = `p_${id}`;
  this.obj = this.form.obj.querySelector(`#${this.obj_id}`);
  this.error_obj = this.form.obj.querySelector(`#${this.obj_id}-errorfield`);
  this.init();
}
init(){
  this.isOK = false ; // il faudra au moins le vérifier une fois
  this.isChecked = false ; // pour savoir s'il a été vérifié au moins une fois
  this.observe();
}
get isOK(){
  if (undefined == this._isok || !this.isChecked){
    this.check();
  }
  return this._isok;
}
set isOK(value){
  this._isok = value ;
  this.isChecked = true ;
}

observe(){
  this.obj.addEventListener('blur', this.check.bind(this));
}
get value() { return this.obj.value }
onError(err){
  this.error_obj.innerHTML = err;
  this.error_obj.classList.remove('hidden');
  this.obj.classList.remove('ok');
  this.obj.classList.add('error');
  this.isOK = false ; // pour indiquer qu'il est checké
  // this.obj.focus(); // ça bloque sur le champ
}
onOK(){
  this.obj.classList.remove('error');  // au cas où
  this.error_obj.classList.add('hidden');   // id.
  this.error_obj.innerHTML = ''; // id.
  this.obj.classList.add('ok');
  this.isOK = true
}

check(){
  switch (this.id) {
    case 'patronyme': return this.checkPatronyme();
    case 'mail': return this.checkMail();
    case 'mail_confirmation': return this.checkConfirmationMail();
  }
}

/**
  * Les méthodes de check
***/
checkPatronyme(){
  const val = this.value.trim();
  try {
    val != "" || raise("Le patronyme est absolument requis");// cf. constants ruby
    val.length <= 200 || raise("Votre patronyme ne doit pas excéder 200 caractères.");// cf. constants ruby
    this.onOK();
  } catch (err) {
    this.onError(err);
  }
}
checkMail(){
  const value = this.value.trim();
  try {
    value != "" || raise("Le mail est absolument requis"); // cf. constants ruby
    value.length < 256 || raise("Ce mail est trop long…"); // cf. constants ruby
    value.search(/(.*)@(.*)\.(.*){1,7}/i) > -1 || raise("Le mail est invalide…");// cf. constants ruby
    // Tout est OK avec le mail
    this.onOK();
  } catch (e) {
    this.onError(e);
  }
}
checkConfirmationMail(){
  const mailValue = this.form.obj.querySelector('#p_mail').value.trim();
  let confValue = this.value.trim();
  try {
    mailValue != "" || raise("Il faut définir le mail");
    mailValue == confValue || raise("La confirmation ne correspond pas.");
    this.onOK()
  } catch (err) {
    this.onError(err)
  }
}

} // FormField

// Méthode appelée à la soumission du formulaire d'inscription
function validateForm(){
  return window.signupForm.isOK.call(window.signupForm);
}

if ( document.querySelector("form#concours-signup-form")){
  // Note : le formulaire n'existe pas si c'est un icarien
  // identifié qui visite cette partie
  $(document).ready(()=>{
      window.signupForm = new MyForm("concours-signup-form");
      window.signupForm.observe();
      window.signupForm.obj.setAttribute("onsubmit", "return validateForm();")
  })
}
