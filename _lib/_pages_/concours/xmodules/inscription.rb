# encoding: UTF-8
# frozen_string_literal: true
require_module('mail')
class HTML

  # Traitement de l'inscription à la session courante d'un ancien concurrent
  def traite_inscription_ancien
    # Les données pour le concours courant
    data = {
      concurrent_id: concurrent.id,
      annee:  Concours.current.annee,
      specs:  "00000000"
    }
    db_compose_insert(DBTBL_CONCURS_PER_CONCOURS, data)
    message("#{concurrent.pseudo}, vous êtes inscrit#{concurrent.fem(:e)} à la session #{Concours.current.annee} du concours ! Bon courage et inspiration à vous !")
  end #/ traite_inscription_ancien

  # Dans le cas d'un icarien identifié
  def traite_inscription_icarien
    icarien_required # barrière de sécurité
    proceed_inscription_icarien(mail:user.mail, patronyme:user.patronyme||user.pseudo, sexe:user.sexe)
  end

  # Quand un icarien ancien concurrent veut s'inscrire à la session courante
  # du concours
  def traite_inscription_icarien_session_courante
    icarien_required
    dc = db_get(DBTBL_CONCURRENTS, {mail: user.mail})
    dc || raise("Vous n'êtes pas un ancien concurrent… Je dois renoncer.")
    make_inscription_session_courante_for(dc[:concurrent_id])
    message(MESSAGES[:concours_confirm_inscription_session_courante] % {e: user.fem(:e)})
  end #/ traite_inscription_icarien_session_courante

  # Procède à l'inscription de l'icarien
  #
  # IN    Données pour l'inscription (mail, patronyme, sexe)
  #
  # Note : au départ, le traitement de l'inscription se faisait entièrement
  # dans la méthode traite_inscription_icarien, mais ensuite j'ai voulu
  # l'utiliser aussi pour un icarien non identifié qui s'inscrirait en
  # remplissant le formulaire. Mais finalement, je renonce à cette dernière
  # utilisation sinon un visiteur mal intentionné pourrait créer une inscription
  # au concours en se faisant passer pour un icarien.
  def proceed_inscription_icarien(data_cc)
    concid = new_concurrent_id
    data_cc.merge!({
      session_id:     session.id,
      concurrent_id:  concid,
      options:        "11100000" # 3 bit à 1 => icarien
    })
    db_compose_insert(DBTBL_CONCURRENTS, data_cc)
    make_inscription_session_courante_for(concid)
    session['concours_user_id'] = concid
    # Envoyer un mail à l'administration
    phil.send_mail({
      subject: MESSAGES[:concours_new_signup_titre],
      message: "<p>Phil,</p><p>#{user.pseudo} (##{user.id}) s'est inscrit#{user.fem(:e)} au concours de synopsis.</p>"
    })
    message(MESSAGES[:concours_signup_ok] % [user.pseudo])
    redirect_to('concours/espace_concurrent')
  end #/ traite_inscription_icarien

  def make_inscription_session_courante_for(concurrent_id)
    data_cpc = {concurrent_id:concurrent_id, annee:Concours.current.annee, specs:"00000000"}
    db_compose_insert(DBTBL_CONCURS_PER_CONCOURS, data_cpc)
  end #/ make_inscription_session_courante_for(concurrent_id)

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
  #
  # Mais il peut s'agir d'un icarien qui ne s'est pas identifié.
  #
  def traite_inscription

    # On s'assure que les données soient valides
    data_concurrent = data_are_valid || raise

    # Si c'est un icarien non identifié qui tente de s'inscrire au concours,
    # on le renvoie vers l'identification pour qu'il s'inscrive d'un simple
    # clic. Ou, s'il est déjà inscrit, il a juste à s'identifier pour participer
    # au concours présent.
    if data_concurrent[:is_icarien]
      fem_ne = data_concurrent[:sexe]=="F" ? "ne" : ""
      fem_e = data_concurrent[:sexe]=="F" ? "e" : ""
      if Concurrent.exists?(mail:data_concurrent[:mail])
        # <= L'icarien non identifié est inscrit aux concours
        # => On lui demande de s'identifier
        message(MESSAGES[:concours_icarien_inscrit_login_required] % {pseudo:data_concurrent[:patronyme], e:fem_e})
      else
        # <= L'icarien non identifié n'est pas inscrit aux concours
        # => On lui demande de s'identifier
        message(MESSAGES[:concours_just_icarien_login_required] % {ne:fem_ne})
      end
      session['back_to'] = "concours/espace_concurrent"
      redirect_to("user/login")
      return
    elsif data_concurrent[:is_concurrent]
      # <=  Le candidat a été détecté comme étant un concurrant déjà inscrit
      #     Soit il utilise le formulaire par dépit, soit il est un ancien
      #     concurrent qui veut s'inscrire à la session courante.
      # =>  Dans les deux cas, on le renvoie à l'identification avec un message
      message(MESSAGES[:concurrent_login_required])
      redirect_to("concours/identification")
      return
    end

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
      message:  deserb('mails/inscription/mail-signup-confirmation', self)
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
      message: deserb('mails/inscription/mail-signup-admin', self)
    })

    # Ajouter une actualité pour l'inscription
    Actualite.add('CONCOURS', nil, "<strong>#{data_concurrent[:patronyme]}</strong> s'inscrit au concours de synopsis.")

    return true

  rescue Exception => e
    log(e)
    erreur("Les données sont invalides… #{e.message}")
    return false
  end #/ traite_inscription


  def data_are_valid
    # On commence par s'assurer que le visiteur qui s'inscrit n'est pas un
    # icarien. Si c'est le cas, on renvoie tout de suite false pour que
    # ce cas soit traité juste après
    mail = param(:p_mail).nil_if_empty
    patronyme = param(:p_patronyme).nil_if_empty
    genre     = param(:p_sexe)
    dcandidat = {
      mail: mail,
      patronyme: patronyme,
      sexe: genre,
      is_icarien:     User.exists?(mail: mail),
      is_concurrent:  Concurrent.exists?(mail: mail)
    }
    # SI c'est un icarien (reconnu par son adresse mail), on ne le
    # traite pas ici, on le laisse "remonter" avec les données minimales
    # pour voir ce qu'il faut faire.
    # IDEM pour un concurrent reconnu (qui est peut-être un ancien concurrent
    # qui veut s'inscrire à la session courante)
    if not(dcandidat[:is_icarien]) && not(dcandidat[:is_concurrent])
      # OK, on peut étudier sérieusement cette candidature
      patronyme || raise("Patronyme non défini.")
      patronyme.length < 256 || raise(ERRORS[:concours_patronyme_too_long])
      patronyme_unique?(patronyme) || raise(ERRORS[:concours_patronyme_exists])
      mail || raise("Mail non défini.")
      mail.length < 256 || raise(ERRORS[:mail_too_long])
      mail.match?(/(.*)@(.*)\.(.*){1,7}/) || raise(ERRORS[:mail_invalide])
      mail_unique?(mail) || raise(ERRORS[:concours_mail_exists])
      mailconf  = param(:p_mail_confirmation).nil_if_empty
      mailconf == mail || raise("La confirmation du mail ne correspond pas.")
      reglement = param(:p_reglement).nil_if_empty
      reglement == "on" || raise("Le réglement doit être approuvé.")
    end
    return dcandidat
  end #/ data_are_valid

  # Retourne TRUE si le mail ne correspond pas déjà à un inscrit
  def mail_unique?(mail)
    db_count(DBTBL_CONCURRENTS, {mail: mail}) == 0
  end #/ mail_unique?

  def patronyme_unique?(patronyme)
    db_count(DBTBL_CONCURRENTS, {patronyme: patronyme}) == 0
  end #/ patronyme_unique?

end #/HTML
