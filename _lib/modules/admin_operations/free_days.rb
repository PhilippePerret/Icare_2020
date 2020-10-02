# encoding: UTF-8
# frozen_string_literal: true
class Admin::Operation
attr_reader :next_paiement, :nombre_jours
def free_days
  require_module('user/modules')
  data_temp = {pseudo: owner.pseudo}
  # L'owner doit être en module de suivi de projet
  owner.icmodule.suivi? || raise(ERRORS[:module_suivi_required])
  # Le nombre de jours à donner
  @nombre_jours = short_value.to_i
  @nombre_jours > 0 || raise(ERRORS[:nombre_jours_required])
  # Calcul de la date de prochain paiement

  watcher_paiement = owner.icmodule.watcher_paiement
  current_paiement = watcher_paiement[:triggered_at].to_i
  current_paiement > 0 || raise(ERRORS[:bad_paiement_trigger])
  @next_paiement = current_paiement + nombre_jours.days
  # On modifie dans les données
  db_compose_update('watchers', watcher_paiement[:id], {triggered_at: @next_paiement})

  msg = ["#{nombre_jours} jours gratuits ont été attribués à #{owner.pseudo}."]
  msg << " Sa prochaine date de paiement est le #{next_paiement_formated}."

  # S'il faut envoyer un message
  if cb_checked
    owner.send_mail(subject:"Ajout de jours gratuits", message:deserb('mails/free_days', self))
    msg << "#{RC}Un mail d’annonce lui a été envoyé."
  else
    msg << "#{RC}Aucun mail d’annonce ne lui a été envoyé."
  end

  msg = msg.join('')
  Ajax << {message: msg}
rescue Exception => e
  log(e)
  Ajax << {error: (e.message % data_temp)}
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
