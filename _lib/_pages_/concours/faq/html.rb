# encoding: UTF-8
# frozen_string_literal: true

class HTML
  def titre
    "#{bouton_retour}#{EMO_TITRE}FAQ du concours"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec

  end # /exec

  # Fabrication du body
  def build_body
    @body = questions_reponses
  end # /build_body

  BLOC_QR = <<-HTML
<div class="qr">
  <div class="question">%{question}</div>
  <div class="reponse">%{reponse}</div>
</div>
  HTML

  def questions_reponses
    QUESTIONS_REPONSES.collect do |dq|
      BLOC_QR % dq
    end.join('')
  end #/ questions_reponses

end #/HTML
