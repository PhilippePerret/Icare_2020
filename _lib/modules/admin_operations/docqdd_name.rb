# encoding: UTF-8
# frozen_string_literal: true
class Admin::Operation
attr_reader :next_paiement, :nombre_jours
def docqdd_name
  require_modules(['icmodules', 'qdd'])
  msg = []
  debug = []

  reparer = cb_value
  document_id = short_value
  msg << "Obtenir le name QDD du document ##{document_id}…"
  msg << "… et réparer en cas d'erreur" if reparer

  # On prend le document en question
  docqdd  = QddDoc.get(document_id)
  doc     = IcDocument.get(document_id)

  doc_folder = File.basename(File.dirname(docqdd.path(:original)))
  msg << "Le nom de l'original est #{docqdd.name(:original)}"
  debug << "Dossier/Nom original de #{doc.name.inspect} :"
  debug << "/#{doc_folder}/#{docqdd.name(:original)}"
  if docqdd.exists?(:original)
    alerte = File.exists?(docqdd.path(:original)) ? ' <span class="green">et il existe</span>' : ' <span class="red">mais il est introuvable… Dépose-le à la main avec le nom fourni.</span>'
    msg << "Il est marqué existant#{alerte}."
  else
    alerte = File.exists?(docqdd.path(:original)) ? ' <span class="red">pourtant il existe…</span>' : ""
    msg << "il est marqué inexistant #{alerte}."
    if reparer
      msg << "Puisque la case de réparation est cochée, je dois réparer la donnée."
    end
  end

  msg << "Le nom du commentaire est #{docqdd.name(:comments)}"
  debug << "Dossier/Nom commentaires de #{doc.name.inspect} :"
  debug << "/#{doc_folder}/#{docqdd.name(:comments)}"
  if docqdd.exists?(:comments)
    alerte = File.exists?(docqdd.path(:comments)) ? ' <span class="green">et il existe</span>' : ' <span class="red">mais il est introuvable… Dépose-le à la main avec le nom fourni.</span>'
    msg << "Il est marqué existant#{alerte}."
  else
    alerte = File.exists?(docqdd.path(:comments)) ? ' <span class="red">pourtant il existe…</span>' : ""
    msg << "il est marqué inexistant #{alerte}."
    if reparer
      msg << "Puisque la case de réparation est cochée, je dois réparer la donnée."
    end
  end

  msg = msg.join('<br>')
  Ajax << {message: msg}
  debug(debug)
rescue Exception => e
  log(e)
  Ajax << {error: (e.message)}
end #/ free_days

def next_paiement_formated
  @next_paiement_formated ||= formate_date(next_paiement)
end #/ next_paiement_formated
end #/Admin::Operation


ERRORS.merge!({
  module_suivi_required: "Impossible d’offrir des jours gratuits à %{pseudo}. Son module n’est pas un module de suivi de projet…",
  nombre_jours_required: "Le nombre de jours est requis !",
  bad_paiement_trigger: "Le déclencheur de paiement est mal réglé (pas de date définie)…"
})
