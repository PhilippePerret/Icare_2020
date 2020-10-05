# encoding: UTF-8
# frozen_string_literal: true
require_module('temoignages')
class Temoignage

# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------

class << self
  def non_confirmeds
    @non_confirmeds ||= self.get_instances(confirmed: false)
  end #/ non_confirmeds

  def confirmeds

  end #/ confirmeds
end # /<< self



# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# Sortie pour valider un témoignage
def out_to_confirm
  form = Form.new(id:"confirmation-temoignage-#{id}", route:route.to_s, class:'nolimit nomargin')
  form.rows = {
    '<identifiant>' => {type:'hidden', name:'temid', value:id},
    '<operation>' => {type:'hidden', name:'operation', value:'valider-temoignage'},
    'Contenu' => {type:'textarea', name:'content', value: content, class:'block nolimit', height:300},
    'Plébiscites' => {type:'text', name:'plebiscites', value:plebiscites, class:'short center'}
  }
  form.submit_button = UI_TEXTS[:btn_valider]
  <<-HTML
<div class="temoignage to_confirm">
  #{form.out}
</div>
  HTML
end #/ out_to_confirm

end #/Temoignage
