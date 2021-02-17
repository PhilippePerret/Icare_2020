# encoding: UTF-8
# frozen_string_literal: true
class HTML

def rapport_general
  lignes_infos = []

  conformes = Dossier.conformes

  lignes_infos << case sans_dossiers.count
  when 0 then "Tous les candidats ont bien envoyé leur dossier"
  when 1 then "Un seul candidat n’a pas envoyé son dossier"
  else  "#{sans_dossiers.count} candidats n'ont pas envoyé leur dossier"
  end
  lignes_infos << case non_conformes.count
  when 0 then 'Aucun candidat n’a envoyé un dossier non conforme'
  when 1 then 'Un seul candidat a envoyé un dossier non conforme'
  else "#{non_conformes.count} candidats ont envoyé un dossier non conforme"
  end

  lignes_infos << "#{conformes.count} concurrent#{pl[:s]} #{pl[:ont]} donc effectivement participé au concours"
  plf = pluriels(nombre_femmes) ; plg = pluriels(nombre_hommes)
  lignes_infos << "(dont #{nombre_femmes} femme#{plf[:s]} et #{nombre_hommes} homme#{plg[:s]})"

end

end #/HTML
