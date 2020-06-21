# encoding: UTF-8
require_modules(['minifaq','absmodules'])
class Watcher < ContainerClass
  def answer_question
    log('-> question_minifaq')
    if param(:form_id) === 'minifaq-form'
      form = Form.new
      if form.conform?
        log('   Le formulaire est conforme')
        # Je dois enregistrer la question MiniFAQ ou la détruire
        if param(:minifaq_reponse).nil_if_empty.nil?
          raise WatcherInterruption.new(ERRORS[:reponse_required])
        else
          objet.save(reponse: param('minifaq_reponse'), question:param('minifaq_question'))
          # S'il y avait un mail indiqué (:user_mail dans les data du watcher),
          # alors il faut avertir l'utilisateur qu'une réponse a été donnée
          # à sa question.
          send_notification_if_user
        end
      end#/conforme?
    end#/formulaire ilya
  end # / question_minifaq

  # Si l'administrateur décide de détruire cette question (peut-être qu'elle
  # n'est pas pertinente ou qu'il y a répondu par un autre biais)
  def contre_answer_question
    objet.destroy # +objet+ = instance MiniFaq
    message(MESSAGES[:minifaq_destroyed])
  end # / contre_question_minifaq

  # Pour la désignation.
  #   Soit "le module d'apprentissage “<son noms>”"
  #   Soit "l'étape n°<x> du module “<son nom”"
  def la_chose
    @la_chose ||= begin
      # +objet+ ici est l'objet du watcher, donc l'instance MiniFaq
      if objet.for_etape?
        "l’étape n°#{objet.absetape.numero} du module “objet.absetape.absmodule.name”"
      else
        "le module d’apprentissage “#{objet.absmodule.name}”"
      end
    end
  end #/ la_chose

  # Envoie une notification de réponse :
  # - à l'utilisateur quelconque s'il a donné son mail
  # - à l'icarien si c'est une question icarien
  def send_notification_if_user
    log('-> send_notification_if_user')
    require_module('mail')
    Mail.send({
      to:       data[:user_mail] || owner.mail,
      subject:  "Réponse à une question Mini-FAQ".freeze,
      message:  deserb('mail2_auteur_question.erb', self)
    })
  end #/ send_notification_if_user
end # /Watcher < ContainerClass
