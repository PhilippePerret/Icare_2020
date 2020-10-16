# encoding: UTF-8
# frozen_string_literal: true
require_module('mail')
class HTML
  def traite_inscription(form)
    now = Time.now

    # IDENTIFIANT UNIQUE pour le concours
    user_id = "#{now.strftime("%Y%m%d%H%M%S")}"
    while db_count(DBTABLE_CONCURRENTS, {concurrent_id: user_id}) > 1
      now += 1
      user_id = "#{now.strftime("%Y%m%d%H%M%S")}"
    end

    # On enregistre le numéro de session avec l'enregistrement de l'user
    # C'est comme ça qu'on le retrouvera à chaque fois.
    data_conc = {
      mail:           param(:p_mail),
      patronyme:      param(:p_patronyme),
      sexe:           param(:p_sexe),
      session_id:     session.id,
      concurrent_id:  user_id
    }
    log("data_conc: #{data_conc}")
    new_id = db_compose_insert(DBTABLE_CONCURRENTS, data_conc)

    session['concours_user_id'] = user_id

    # Les données pour le concours courant
    data = {
      user_id:        user_id,
      annee:          ANNEE_CONCOURS_COURANTE,
      fiche_required: !!param(:p_fiche_lecture)
    }
    db_compose_insert(DBTBL_CONCURS_PER_CONCOURS, data)

    # On crée une instance de concurrent pour que ce soit plus facile,
    # et notamment pour les mails envoyés.
    @concurrent = Concurrent.new(concurrent_id: user_id, session_id: session.id)

    # Envoyer un mail pour confirmer l'inscription
    Mail.send({
      to:       data_conc[:mail],
      subject:  MESSAGES[:concours_signed_confirmation],
      message:  deserb('mail-signup-confirmation', self)
    })

    # Ajouter une actualité pour l'inscription
    Actualite.add('CONCOURS', nil, "#{data_conc[:patronyme]} s'inscrire au concours de synopsis.")

    return true
  end #/ traite_inscription
end #/HTML
