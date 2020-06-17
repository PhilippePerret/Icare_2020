'use strict';
/*
  Module de script provisoire qui prend le code ERB du champ courant
  et le transforme autant que possible en code MARKDOWN
*/
function erbToMarkdown(container){
  container = container || CurrentField.current ;
  container || raise("Il faut se placer dans le champ à transformer.")
  const demande = "Voulez-vous vraiment transformer ce texte ERB en texte MARKDOWN ?"
  if (!confirm(demande)) return
  var str = container.obj.value
  // --------

  // Des balises classiques
  const REMPS = {
    '<strong>': '**', '</strong>': '**', '<b>': '**', '</b>': '**',
    '<em>': '*', '</em>': '*', '<i>': '*', '</i>': '*',
    "</p>\n<p>": ''
  }
  for(var searched in REMPS){
    var reg = new RegExp(searched, 'g')
    str = str.replace(reg, REMPS[searched])
  }
  // Les titres
  // const REG_TITRE = new RegExp("<h([1-8])>(.+)<\/h\1>", 'ig')
  const REG_TITRE = /<h([1-8])>(.+)<\/h\1>/ig;
  str = str.replace(REG_TITRE, transformeTitre)
  // On efface les dernières balises "<p>" qui peuvent rester
  // Ça va laisser un retour charriot qu'on pourra retirer "à la main"
  str = str.replace(/<\/?p>/, '')
  // --------
  container.obj.value = str

  // On remplace les balises MOT et FILM (et peut-être autres ajoutés ensuite)
  remplaceBaliseMot('md')
  // On remplace les balises "<%= ... %>" par "#{...}"
  balisesErbToMarkdown(container)
}


function transformeTitre(tout, level, titre){
  level = Number(level) - 2 ; // 3 -> 1
  console.log("level = (typeof)", level, typeof level);
  var dieses = '#'.padStart(level,'#');
  return `${dieses} ${titre}`
}
