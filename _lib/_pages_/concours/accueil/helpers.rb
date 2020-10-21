# encoding: UTF-8
# frozen_string_literal: true
class HTML
  def bouton_evaluation
    <<-HTML
<div class="right">
  Vous êtes évaluateur. #{Tag.link(route:"concours/evaluation",text:"Rejoindre la section d'évaluation")}.
</div>
    HTML
  end #/ bouton_evaluation
end #/HTML
