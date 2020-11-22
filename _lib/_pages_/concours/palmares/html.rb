# encoding: UTF-8
# frozen_string_literal: true
=begin
  Partie qui affiche les résultats ou une page d'attente des
  résultats.
  En tant qu'administrateur, on peut toujours avoir la page des résultats
  affichés.
=end

class HTML
  def titre
    "#{bouton_retour}#{EMO_TITRE}Palmarès du concours de synopsis"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    if Concours.current.phase == 0
      message("Aucun concours en route. Le palmarès n'est pas consultable.")
      redirect_to("concours")
    end
    if Concours.current.phase < 5
      try_to_reconnect_visitor(required = true)
    else
      try_to_reconnect_visitor(required = false)
    end
    @concours = Concours.current
    require_xmodule('synopsis')
    transactions = ['START TRANSACTIONS;']
    # Il faut recalculer toutes les évaluations pour avoir des notes justes
    # dans la base de données (au niveau de pre_note et fin_note)
    # TODO Il faudrait quand même mettre en place un moyen de ne pas le faire chaque fois…
    # On renseigne la donnée :pre_note de chaque synopsis
    synos_max_to_min, a, b, c = Synopsis.evaluate_all_synopsis(phase:1, evaluator:phil) # pour pre_note
    synos_max_to_min.each do |syno|
      # syno.save(pre_note: syno.evaluation_totale.note)
      transactions << "UPDATE #{DBTBL_CONCURS_PER_CONCOURS} SET pre_note = #{syno.evaluation_totale.note} WHERE concurrent_id = '#{syno.concurrent_id}' AND annee = #{syno.annee};"
    end

    # On renseigne la donnée :fin_note de chaque synopsis
    synos_max_to_min, a, b, c = Synopsis.evaluate_all_synopsis(phase:5, evaluator:phil) # pour pre_note
    synos_max_to_min.each do |syno|
      # syno.save(fin_note: syno.evaluation_totale.note)
      transactions << "UPDATE #{DBTBL_CONCURS_PER_CONCOURS} SET fin_note = #{syno.evaluation_totale.note} WHERE concurrent_id = '#{syno.concurrent_id}' AND annee = #{syno.annee};"
    end

    transactions << 'COMMIT;'
    transactions = transactions.join("\n")
    log("transactions: #{transactions.inspect}")

  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

end #/HTML
