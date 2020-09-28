# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class IcEtape < ContainerClass

  # Retourne le span qui contient la date d'envoi des documents de travail
  # lorsqu'ils ont été envoyés
  def f_work_sent_at
    "<span class=\"date-sent-work\">#{formate_date(icdocuments.first.created_at)}</span>"
  end #/ f_work_sent_at

  # Retourne le span qui contient la date de retour préconisé pour les
  # commentaires (la données expected_comments de l'étape)
  def f_comments_expected_date
    "<span>Approximativement prévus pour le <span class=\"date-expected-comments\">#{formate_date(expected_comments)}</span></span>"
  end #/ f_comments_expected_date

  # Retourne la date de fin attendue, avec une alerte en
  # cas de retard
  def f_expected_end
    @f_expected_end ||= begin
      now = Time.now
      ti  = Time.at(data[:expected_end].to_i)
      fti = formate_date(ti)
      css = ti < now ? 'warning' : nil ;
      first_year = (ti < Time.now ? ti : now).year
      Form.date_field({
        default:data[:expected_end].to_i,
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
