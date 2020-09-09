# encoding: UTF-8
=begin
  Class MiniFaq
  Pour gérer la MiFaq

  Noter que depuis la version 2020, cette minifaq concerne aussi
  les modules d'apprentissage, où on peut poser des questions pour en
  savoir plus sur eux.
=end
class MiniFaq < ContainerClass
# ---------------------------------------------------------------------
#
#   CLASSE
#
#  Les méthodes de classe gère la minifaq comme un ensemble de
#  questions/réponses.
# ---------------------------------------------------------------------
class << self
  def table
    @table ||= 'minifaq'.freeze
  end #/ table

  # = main =
  # Méthode principale à appeler quand on soumet une question.
  # Noter que maintenant la question peut aussi bien venir d'un icarien sur
  # une étape de travail qu'à propos d'un module.
  def add_question
    require_modules(['watchers','mail'])
    user_mail = param(:minifaq_user_mail)
    user_id = param(:minifaq_user_id)&.to_i
    dquestion = {
      question:   param(:minifaq_question)&.safetize,
      user_id:    user_id
    }
    for_etape = param(:minifaq_target_type) == 'absetape'
    chose_id  = param(:minifaq_target_id)&.to_i
    if for_etape
      dquestion.merge!(absetape_id: chose_id)
    else
      dquestion.merge!(absmodule_id: chose_id)
    end
    # Checker la question (non vide et surtout : safe)
    dquestion[:question] || raise("Il faut définir votre question.".freeze)
    log("--- question minifaq: #{dquestion.inspect}")

    # On enregistre la question
    question_id = db_compose_insert('minifaq', dquestion)

    # Soit c'est un visiteur quelconque qui n'a pas fourni
    # son mail
    # Soit c'est un visiteur quelconque qui a fourni son mail
    # Soit c'est un icarien (param(:minifaq_user_id) est défini)
    # Faire un watcher pour répondre à la question posée
    watcher_owner = user.guest? ? phil : user
    watcher_owner.watchers.add('question_faq',{objet_id:question_id, data:dquestion})

    # Envoyer un mail à Phil (moi) pour prévenir qu'une question
    # a été déposé
    Mail.send({
      subject:'Nouvelle question Minifaq'.freeze,
      message: deserb('mail_admin', MiniFaq.get(question_id))
    })

    msg = "Merci pour votre question. "
    if user_mail || user_id
      msg << "Vous recevez un mail pour vous avertir quand la réponse aura été déposée."
    else
      msg << "Pour lire la réponse, repassez sur le site dans quelques jours."
    end
    message(msg)
  rescue Exception => e
    log(e)
    erreur(e.message)
  end #/ add_question
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
#   Une instance est une question/réponse
# ---------------------------------------------------------------------
def out
  <<-HTML
<div class="minifaq-qr">
<div class="minifaq-question">
  <span class="fright">#{user_pseudo}</span>
  <span class="question">#{question}</span>
</div>
<div class="minifaq-reponse">#{deserb_or_markdown(reponse, self)}</div>
</div>
  HTML
end #/ out

def for_etape?
  @is_for_etape = !!absmodule_id.nil? if @is_for_etape.nil?
  @is_for_etape
end #/ for_etape?

def absetape
  @absetape ||= for_etape? && objet
end #/ absetape

def absmodule
  @absmodule ||= for_etape? || objet
end #/ absmodule

# Soit l'instance de l'AbsModule, soit l'instance de l'AbsEtape
# en fonction de la destination de la question
def objet
  @objet ||= begin
    require_module('absmodules')
    if for_etape?
      AbsEtape.get(absetape_id)
    else
      AbsModule.get(absmodule_id)
    end
  end
end #/ objet

end #/MiniFaq < ContainerClass
