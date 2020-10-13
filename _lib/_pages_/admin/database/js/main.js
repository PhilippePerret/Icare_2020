/*

 */

function CalculeTimeOperation(){
  const timeField = document.querySelector('input#time_operation')
  let code = timeField.value
  code = code
    .replace(/ ([0-9]+)minutes?/g, ' $1*60')
    .replace(/ ([0-9]+)(heures?|hours?)/g, ' $1*3600')
    .replace(/ ([0-9]+)(jours?|days?)/g, ' $1*3600*24')
    .replace(/ ([0-9]+)(semaines?|weeks?)/g, ' $1*7*3600*24')
    .replace(/ ([0-9]+)(mois|months?)/g, ' $1*31*3600*24')
  var result = 0
  const codeSegs = code.split(' ')
  var next_operation ;
  codeSegs.forEach(seg => {
    console.log("seg : '%s'", seg)
    if ( seg == '+' || seg == '-') { next_operation = seg }
    else {
      if ( next_operation == '+' ) {
        result += eval(seg)
      } else if ( next_operation == '-' ) {
        result -= eval(seg)
      }
    }
  })

  const respField = document.querySelector('input#time_operation_resultat')
  respField.value = result
  document.querySelector('#time_operation_resultat_human').innerHTML = formate_date(result)
}

$(document).ready(() => {
  // On affiche dans une fiche la liste des icariens (hors administrateurs
  // et hors détruits)
  Icarien.ficheListe.show()
})
