# encoding: UTF-8
SPAN_ACTU_FEMME = '<span><strong>%s</strong> devient une <em>vraie</em> icarienne !</span>'.freeze
SPAN_ACTU = '<span><strong>%s</strong> devient un <em>vrai</em> icarien !</span>'.freeze

class Watcher < ContainerClass
  def paiement
    # Normalement, on ne doit jamais passer par là, car le paiement sera
    # traiter dans la section module et le watcher sera détruit à ce moment-là.
  end # / paiement


  # Méthode appelée quand le paiement est effectuée
  def on_paiement_ok

    # Une actualité pour l'annoncer. Noter qu'il n'est pas absolument nécessaire
    # que ça soit placé avant le changement d'option, puisque la valeur restera
    # sur toute cette session.
    unless owner.real?
      Actualite.add('FIRSTPAIE', owner, (owner.femme? ? SPAN_ACTU_FEMME : SPAN_ACTU) % [owner.pseudo] )
    end

    # L'icarien devient un vrai icarien
    owner.set_option(24, 1)

  end #/ on_paiement_ok
end # /Watcher < ContainerClass
