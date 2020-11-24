# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML
  def titre
    "#{bouton_retour}#{EMO_TITRE}Identification au concours"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    if param(:form_id)
      form = Form.new
      if form.conform?
        if param(:p_op) == "retrievenum"
          # Pour récupérer son numéro d'inscription
          retrieve_numero_inscription
        else
          # On checke l'user
          check_concurrent
        end
      end
    end
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

  def check_concurrent
    dc = db_exec(REQUEST_CHECK_CONCURRENT, [param(:p_concurrent_id), param(:p_mail)]).first
    if not dc.nil?
      session['concours_user_id'] = param(:p_concurrent_id).dup
      db_compose_update(DBTBL_CONCURRENTS, dc[:id], {session_id: session.id})
      # Ici, deux solutions : soit 1) le concurrent est ancien concurrent, i.e.
      # il n'est pas inscrit pour le concours courant, soit 2) il est inscrit à
      # la session courante. Si c'est le 1), on l'envoie vers l'inscription (qui
      # lui présentera un panneau propre à son cas) soit on l'envoie vers
      # l'espace personnel normal
      if Concurrent.is_current_concurrent?(session['concours_user_id']) || Concours.current.phase > 1
        redirect_to("concours/espace_concurrent")
      else
        redirect_to("concours/inscription")
      end
    else
      erreur(ERRORS[:concours_invalid_informations])
    end
  end #/ check_concurrent


  def retrieve_numero_inscription
    mail = param(:p_mail).nil_if_empty
    mail || raise(ERRORS[:concours_mail_required])
    mail_exists?(mail) || raise(ERRORS[:concours_mail_unknown] % mail)
    require_module('mail')
    Mail.send({
      to: mail,
      from: CONCOURS_MAIL,
      subject: MESSAGES[:concours_sujet_retrieve_numero],
      message: <<-HTML
<p>Bonjour #{@mail_data[:patronyme]},</p>
<p>Veuillez trouvez ci-dessous votre NUMÉRO D'INSCRIPTION au #{CONCOURS_LINK.with(absolute:true)}.</p>
<p>Numéro : <strong>#{@mail_data[:concurrent_id]}</strong></p>
<p>Bien à vous,</p>
<p>#{le_bot}</p>
      HTML
      })
    message("Je vous ai renvoyé votre numéro à l'adresse #{mail}.")
  rescue Exception => e
    erreur(e.message)
  end #/ retrieve_numero


  def mail_exists?(mail)
    @mail_data = db_exec("SELECT concurrent_id, patronyme FROM concours_concurrents WHERE mail = ?", [mail]).first
    @mail_data != nil
  end #/ mail_exists?
end #/HTML
