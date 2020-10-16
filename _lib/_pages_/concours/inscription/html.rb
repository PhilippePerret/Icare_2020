# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML
  def titre
    "#{bouton_retour}#{EMO_TITRE}#{UI_TEXTS[:titre_page_inscription]}"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    if param(:form_id)
      form = Form.new
      if form.conform?
        case param(:form_id)
        when 'concours-signup-form'
          if traite_inscription(form)
            redirect_to("concours/concurrent")
          end
        when 'concours-signedup-form'
          raise "Je ne traite pas encore ce formulaire"
        end
      end
    end
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb("form", self)
  end # /build_body

  def traite_inscription(form)
    now = Time.now

    # IDENTIFIANT UNIQUE pour le concours
    user_id = "#{now.strftime("%Y%m%d%H%M%S")}"
    while db_count(DBTABLE_CONCURRENTS, {user_id: user_id}) > 1
      now += 1
      user_id = "#{now.strftime("%Y%m%d%H%M%S")}"
    end

    # On enregistre le numéro de session avec l'enregistrement de l'user
    # C'est comme ça qu'on le retrouvera à chaque fois.
    data = {
      user_mail:  param(:p_mail),
      patronyme:  param(:p_patronyme),
      sexe:       param[:p_sexe],
      session_id: session.id,
      user_id:    user_id,
      mail_confirmed: false
    }
    new_id = db_compose_insert(DBTABLE_CONCURRENTS, data)

    session['concours_user_id'] = user_id

    # Les données pour le concours courant
    data = {
      user_id:        user_id,
      annee:          ANNEE_CONCOURS_COURANTE,
      fiche_required: !!param(:p_fiche_lecture)
    }
    db_compose_insert(DBTABLE_CONCOURS, data)

    # Envoyer un mail pour confirmer l'inscription
    # TODO
    # Envoyer un mail pour confirmer l'adresse mail
    # TODO
    # Ajouter une actualité pour l'inscription
    # TODO

    return true
  end #/ traite_inscription

end #/HTML
