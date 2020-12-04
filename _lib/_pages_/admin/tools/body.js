'use strict';
/*
  Module très important pour la partie administration.
*/
const OPES_KEYS = ['long_value', 'medium_value','short_value', 'select_value', 'cb_value'];

// Appelé pour exécuter l'opération
function executeOperation(){
  const data = {}
  // User choisi
  data.icarien = Number(document.querySelector('#icariens').value);
  if (data.icarien == 0) {// pas d'icarien choisi
    delete data.icarien
  }
  // Opération choisie
  data.operation = document.querySelector('#operations').value

  // Valeurs transmises
  OPES_KEYS.forEach(key => {
    if ( key == 'cb_value' ) {
      data[key] = document.querySelector(`#${key}`).checked
    } else {
      data[key] = document.querySelector(`#${key}`).value
    }
  })

  // Est-ce une simulation
  data.simulation = document.querySelector('#simulation').checked

  // Données absolues pour cette opération
  const dataOperation = DATA_OPERATIONS[data.operation]
  // Vérification des données
  if ( dataOperation.required && dataOperation.required.length) {
    var missing_values = []
    dataOperation.required.forEach(key => {
      if ( data[key] == "" ) {
        missing_values.push(key)
      }
    })
    if ( missing_values.length ) {
      // Il manque des valeurs
      erreur('Les champs entourés en rouge sont requis.');
      missing_values.forEach(key => {
        let selecteur ;
        switch (key) {
          case 'icarien':
            selecteur = 'select#icariens'
            break;
          default:
            selecteur = `#${key}-div`
        }
        document.querySelector(selecteur).classList.add('error')
      })//Fin de boucle sur toutes les clés manquantes
      return;
    }
  }
  // console.log("data:", data)
  // Appel de la méthode (ajax) et attente du retour
  Ajax.send('operation_icarien.rb', data)
  .then(afterOperationExecution.bind(null))
  .catch(erreur.bind(null))
}

/*
  Méthode appelée quand on revient de la requête Ajax qui a exécuté l'opération icarien.
*/
function afterOperationExecution(reta) {
  console.log("Retour d'ajax:", reta)
  if (reta.error){
    erreur(reta.error);
    console.error(reta.error, reta.backtrace)
    return
  }
  if (reta.message) message(reta.message) ;
}

// Appelé quand la page est prête
function afterReady(){
  document.querySelectorAll('.cb-statut').forEach( cb => {
    cb.addEventListener('click', onToggleCbStatut.bind(null, cb))
  })
  const menu_operations = document.querySelector('select#operations')
  menu_operations.addEventListener('change', onChooseOperation.bind(null,menu_operations))
  // Quand on clique sur le menu icariens, ou sur un des trois champs, on
  // enlève sa marque 'error' qui a pu être placée
  document.querySelectorAll('.errorizable').forEach(field => {
    field.addEventListener('click', function(){this.classList.remove('error')})
  })
}

// Quand on choisit un statut d'icarien, tous les icariens de ce statut
// s'affichent (et inversement).
// Et il faut mettre dans les opérations les opérations qui correspondent
// au choix.
function onToggleCbStatut(cb, ev) {
  const cbid = `#${cb.id}`
  const statut = cb.name
  const liste_src = cb.checked ? 'icariens-out' : 'icariens'
  const liste_dst = document.querySelector(`select#${cb.checked ? 'icariens' : 'icariens-out'}`)
  document.querySelectorAll(`select#${liste_src} option.${statut}`).forEach(opt => liste_dst.appendChild(opt))
  const liste_opes_src = cb.checked ? 'operations-out' : 'operations'
  const liste_opes_dst = document.querySelector(`select#${cb.checked ? 'operations' : 'operations-out'}`)
  document.querySelectorAll(`select#${liste_opes_src} option.${statut}`).forEach(opt => liste_opes_dst.appendChild(opt))
  // On met toujours dans la liste des opérations in les opérations qui sont valables
  // tout le temps
  const liste_operations_in = document.querySelector('select#operations')
  document.querySelectorAll(`select#operations-out option.all`).forEach(opt => liste_operations_in.appendChild(opt))
  // On masque toujours le div qui contient tous les champs et le bouton
  // pour soumettre l'opération
  document.querySelector('#div-fields').classList.add('hidden');
}

/*
  Méthode appelée quand on choisit une opération
*/
function onChooseOperation(menu_operations){
  const opid    = menu_operations.value
  const opdata  = DATA_OPERATIONS[opid]
  document.querySelector('#div-fields').classList.remove('hidden');
  OPES_KEYS.forEach(key => {
    // console.log("Traitement clé '%s'", key)
    const div = document.querySelector(`#${key}-div`) ;
    const txt = document.querySelector(`#${key}-txt`) ;
    const fld = document.querySelector(`#${key}`) ;
    fld.value = "";
    if ( opdata[key] ) {
      div.classList.remove('hidden')
      if (key == 'cb_value') {
        txt.innerHTML = opdata[key].message;
        fld.checked = opdata[key].checked;
        fld.value = "ON";
      } else if (key == 'select_value'){
        // Traitement spécial d'un menu de valeurs (sa donnée contient :values,
        // :default et :message)
        txt.innerHTML = opdata[key].message;
        fld.innerHTML = '';
        opdata[key].values.forEach( paire => {
          var option = document.createElement('OPTION')
          option.innerHTML = paire[1];
          option.value = paire[0];
          fld.appendChild(option)
        })
      } else {
        // Traitement des champs textes (short, medium, long)
        txt.innerHTML = opdata[key]
      }
    } else {
      div.classList.add('hidden')
    }
  })
}

// Simplement pour essayer si ajax fonctionne
function EssaiAjax(){
  Ajax
  .send('_essai_.rb', {message:"Le message transmis."})
  .then(console.log)
  .catch(console.error)
}
