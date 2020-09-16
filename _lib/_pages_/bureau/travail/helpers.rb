# encoding: UTF-8
require_module('form')
class IcEtape < ContainerClass

  # Retourne la date de fin attendue, avec une alerte en
  # cas de retard
  def f_expected_end
    @f_expected_end ||= begin
      now = Time.now
      ti  = Time.at(data[:expected_end])
      fti = formate_date(ti)
      css = ti < now ? 'warning' : nil ;
      first_year = (ti < Time.now ? ti : now).year
      Form.date_field({
        default:data[:expected_end],
        prefix_id: 'echeance',
        class:css
      })
    end
  end #/ f_expected_end

end #/IcEtape < ContainerClass

class User
  def echeance_field
    '<form id="change-echeance" method="POST" class="inline">' +
      Tag.hidden(value:'bureau/travail', name:'route') +
      Tag.hidden(value:'echeance', name:'ope') +
      user.icetape.f_expected_end +
      BR +
      Tag.submit_button(UI_TEXTS[:btn_modify_echeance], class:'small') +
      Tag.span(text:'  (après l’avoir ajustée)'.freeze, class:'small') +
    '</form>'
  end

end #/User