# encoding: UTF-8
# frozen_string_literal: true
require_module('mail')
require_js_module('jquery')
class HTML
  def traite_inscription(form)

    # On s'assure que les données soient valides
    data_concurrent = data_are_valid || raise

    now = Time.now

    # IDENTIFIANT UNIQUE pour le concours
    user_id = "#{now.strftime("%Y%m%d%H%M%S")}"
    while db_count(DBTABLE_CONCURRENTS, {concurrent_id: user_id}) > 1
      now += 1
      user_id = "#{now.strftime("%Y%m%d%H%M%S")}"
    end

    # Options
    options = "0" * 8
    options[1] = "1" if !!param(:p_fiche_lecture)

    # On enregistre le numéro de session avec l'enregistrement de l'user
    # C'est comme ça qu'on le retrouvera à chaque fois.
    data_save = {
      mail:           data_concurrent[:mail],
      patronyme:      data_concurrent[:patronyme],
      sexe:           param(:p_sexe),
      session_id:     session.id,
      concurrent_id:  user_id,
      options:        options
    }
    log("data_conc: #{data_save}")
    new_id = db_compose_insert(DBTABLE_CONCURRENTS, data_save)

    session['concours_user_id'] = user_id

    # Les données pour le concours courant
    data = {
      concurrent_id:  user_id,
      annee:          ANNEE_CONCOURS_COURANTE
    }
    db_compose_insert(DBTBL_CONCURS_PER_CONCOURS, data)

    # On crée une instance de concurrent pour que ce soit plus facile,
    # et notamment pour les mails envoyés.
    @concurrent = Concurrent.new(concurrent_id: user_id, session_id: session.id)

    # Envoyer un mail pour confirmer l'inscription
    Mail.send({
      to:       data_concurrent[:mail],
      subject:  MESSAGES[:concours_signed_confirmation],
      message:  deserb('mail-signup-confirmation', self)
    })

    # Annonce à l'administration
    # Pour connaitre la source d'information (la façon dont le concurrent
    # a entendu parler du concours)
    knowledge = param(:p_knowledge)
    source = nil
    if knowledge != "none"
      CONCOURS_KNOWLEDGE_VALUES.each do |paire|
        if paire[0] == knowledge
          source = "Il/elle a connu le concours par #{paire[1]}."
          break
        end
      end
    end
    @source_concours = source || "--- source non donnée ---"

    # Envoyer un mail à l'administration
    phil.send_mail({
      subject: MESSAGES[:concours_new_signup_titre],
      message: deserb('mail-signup-admin', self)
    })

    # Ajouter une actualité pour l'inscription
    Actualite.add('CONCOURS', nil, "#{data_concurrent[:patronyme]} s'inscrire au concours de synopsis.")

    return true

  rescue Exception => e
    log(e)
    erreur("Les données sont invalides… #{e.message}")
    return false
  end #/ traite_inscription

  def data_are_valid
    patronyme = param(:p_patronyme).nil_if_empty
    patronyme || raise("Patronyme non défini.")
    patronyme.length < 256 || raise("Patronyme trop long (255 max.).")
    patronyme_unique?(patronyme) || raise("Ce patronyme est déjà utilisé…")
    mail      = param(:p_mail).nil_if_empty
    mail || raise("Mail non défini.")
    mail.length < 256 || raise("Mail trop long.")
    mail.match?(/(.*)@(.*)\.(.*){1,7}/) || raise("Mail invalide.")
    mail_unique?(mail) || raise("Ce mail est déjà utilisé pour une inscription.")
    mailconf  = param(:p_mail_confirmation).nil_if_empty
    mailconf == mail || raise("La confirmation du mail ne correspond pas.")
    genre     = param(:p_sexe)
    reglement = param(:p_reglement).nil_if_empty
    reglement == "on" || raise("Le réglement doit être approuvé.")
    {
      mail: mail,
      patronyme: patronyme,
      genre: genre
    }
  end #/ data_are_valid

  # Retourne TRUE si le mail ne correspond pas déjà à un inscrit
  def mail_unique?(mail)
    db_count(DBTABLE_CONCURRENTS, {mail: mail}) == 0
  end #/ mail_unique?

  def patronyme_unique?(patronyme)
    db_count(DBTABLE_CONCURRENTS, {patronyme: patronyme}) == 0
  end #/ patronyme_unique?

end #/HTML
