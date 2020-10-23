# encoding: UTF-8
# frozen_string_literal: true
require_module('mail')
class HTML

  # Dans le cas d'un icarien identifié
  def traite_inscription_icarien
    icarien_required # barrière de sécurité
    concid = new_concurrent_id
    data_cc = {
      mail:           user.mail,
      patronyme:      user.patronyme || user.pseudo,
      sexe:           user.sexe,
      session_id:     session.id,
      concurrent_id:  concid,
      options:        "11100000" # 3 bit à 1 => icarien
    }
    db_compose_insert(DBTBL_CONCURRENTS, data_cc)
    data_cpc = {concurrent_id:concid, annee:ANNEE_CONCOURS_COURANTE, specs:"00000000"}
    db_compose_insert(DBTBL_CONCURS_PER_CONCOURS, data_cpc)
    session['concours_user_id'] = concid
    # Envoyer un mail à l'administration
    phil.send_mail({
      subject: MESSAGES[:concours_new_signup_titre],
      message: "<p>Phil,</p><p>#{user.pseudo} (##{user.id}) s'est inscrit#{user.fem(:e)} au concours de synopsis.</p>"
    })
    message("Votre inscription au concours a été effectuée avec succès, #{user.pseudo} !")
    redirect_to('concours/espace_concurrent')
  end #/ traite_inscription_icarien

  def new_concurrent_id
    now = Time.now
    concid = "#{now.strftime("%Y%m%d%H%M%S")}"
    while db_count(DBTBL_CONCURRENTS, {concurrent_id: concid}) > 1
      now += 1
      concid = "#{now.strftime("%Y%m%d%H%M%S")}"
    end
    return concid
  end #/ new_concurrent_id

  # Inscription d'un visiteur quelconque
  def traite_inscription

    # On s'assure que les données soient valides
    data_concurrent = data_are_valid || raise

    # IDENTIFIANT UNIQUE pour le concours
    user_id = new_concurrent_id

    # Options
    options = "0" * 8
    options[0] = "1" # Par défaut, on reçoit toujours les informations
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
    new_id = db_compose_insert(DBTBL_CONCURRENTS, data_save)

    session['concours_user_id'] = user_id

    # Les données pour le concours courant
    data = {
      concurrent_id:  user_id,
      annee:  ANNEE_CONCOURS_COURANTE,
      specs:  "00000000"
    }
    db_compose_insert(DBTBL_CONCURS_PER_CONCOURS, data)

    # On crée une instance de concurrent pour que ce soit plus facile,
    # et notamment pour les mails envoyés.
    @concurrent = Concurrent.new(concurrent_id: user_id, session_id: session.id)

    # Envoyer un mail pour confirmer l'inscription
    Mail.send({
      to:       data_concurrent[:mail],
      subject:  MESSAGES[:concours_signed_confirmation],
      message:  deserb('inscription/mail-signup-confirmation', self)
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
      message: deserb('inscription/mail-signup-admin', self)
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
    patronyme.length < 256 || raise(ERRORS[:concours_patronyme_too_long])
    patronyme_unique?(patronyme) || raise(ERRORS[:concours_patronyme_exists])
    mail      = param(:p_mail).nil_if_empty
    mail || raise("Mail non défini.")
    mail.length < 256 || raise(ERRORS[:mail_too_long])
    mail.match?(/(.*)@(.*)\.(.*){1,7}/) || raise(ERRORS[:mail_invalide])
    mail_unique?(mail) || raise(ERRORS[:concours_mail_exists])
    mailconf  = param(:p_mail_confirmation).nil_if_empty
    mailconf == mail || raise("La confirmation du mail ne correspond pas.")
    genre     = param(:p_sexe)
    reglement = param(:p_reglement).nil_if_empty
    reglement == "on" || raise("Le réglement doit être approuvé.")
    {
      mail: mail,
      patronyme: patronyme,
      sexe: genre
    }
  end #/ data_are_valid

  # Retourne TRUE si le mail ne correspond pas déjà à un inscrit
  def mail_unique?(mail)
    db_count(DBTBL_CONCURRENTS, {mail: mail}) == 0
  end #/ mail_unique?

  def patronyme_unique?(patronyme)
    db_count(DBTBL_CONCURRENTS, {patronyme: patronyme}) == 0
  end #/ patronyme_unique?

end #/HTML
