# encoding: UTF-8
# frozen_string_literal: true
class HTML

  # OUT   Les boutons permettant de s'inscrire, de s'identifier, etc.
  def boutons_visiteur
    if not concurrent
      bouton_formulaire + bouton_login_or_espace
    elsif concurrent.current?
      "<p class='right'>Rejoindre #{ESPACE_LINK.with("votre espace personnel")}.</p>"
    end
  end #/ boutons_visiteur


  def bouton_evaluation
    <<-HTML
<div class="right">
  <strong>Vous êtes membre du jury</strong>. #{Tag.link(route:"concours/evaluation",text:"Rejoindre la section d'évaluation")}.
</div>
    HTML
  end #/ bouton_evaluation


  def description_etape_courante
    t = case Concours.current.step
        when 0 then ""
        when 1 then
          # Étape 1 (concours en cours)
          # Message différent en fonction du fait qu'il s'agit d'un visiteur
          # quelconque, d'un icarien identifié ou d'un icarien identifié
          # inscrit aux concours
          identified = not(user.guest?)
          segs = []
          segs << "<strong>Le concours est ouvert !</strong>"
          if identified
            if user.concurrent?
              # Icarien identifié concurrent
              if user.concurrent_session_courante?
                # Icarien identifié inscrit au concours courant
                segs << "Puisque vous êtes inscrit#{user.fem(:e)}, vous pouvez" #"envoyer votre manuscrit"
              else
                # Icarien identifié, concurrent mais non inscrit à la session courante
                segs << "Vous pouvez #{CONCOURS_SIGNUP.with('vous inscrire à la session courante')} et"
              end
            else
              # Icarien identifié ne participant pas aux concours (non concurrent)
              segs << "Vous pouvez #{CONCOURS_SIGNUP.with('vous inscrire')} et"
            end
          else
            segs << "Vous pouvez #{CONCOURS_SIGNUP.with('vous inscrire')} ou #{CONCOURS_LOGIN.with('vous identifier')} et"
          end
          segs << "#{ESPACE_LINK.with('envoyer votre synopsis')}."
          segs.join(" ")
        when 2 then "<strong>Les #{nombre_synopsis} synopsis sont en préselection</strong>.<br/><br/>Rendez-vous aux alentours du #{date_premiere_selection} pour les résultats de la première sélection !"
        when 3 then "<strong>Les 10 synopsis sélectionnés sont en pleiniaire</strong>.<br/>(#{PALMARES_LINK.with('voir les synopsis retenus')})<br/><br/>Rendez-vous aux alentours du #{date_selection_finale} pour le palmarès final."
        when 5 then "<strong>Les synopsis lauréats ont été choisis !</strong><br/><br/>Voir le #{PALMARES_LINK}."
        else "<strong>Le concours est achevé</strong> mais vous pouvez #{CONCOURS_SIGNUP.with('vous inscrire pour la prochaine session')}.<br/><br/>Rendez-vous pour la prochaine session !"
        end
    # Composer le texte final
    "<div id=\"description-step-concours\">#{t}</div>"
  end #/ description_etape_courante

  def description_concours
    <<-HTML
<p class='explication'>Chaque année, l'atelier Icare organise un concours d'écriture ouvert à toutes et tous, auteur·e·s de langue française. Ce concours offre l'opportunité à trois gagnant·e·s d'intégrer l'atelier pour suivre jusqu'à un an d'accompagnement à l'écriture.</p>
    HTML
  end #/ description_concours

  def faq
    deserb('partials/faq_link_section')
  end #/ faq

  def reglement
    deserb('partials/reglement_link_section')
  end #/ reglement

private

  def date_premiere_selection
    @date_premiere_selection ||= begin
      formate_date(Time.new(ANNEE_CONCOURS_COURANTE, 4, 15))
    end
  end #/ date_premiere_selection

  def date_selection_finale
    @date_selection_finale ||= "1<exp>er</exp> juin #{ANNEE_CONCOURS_COURANTE}"
  end #/ date_selection_finale

  def nombre_synopsis
    @nombre_synopsis ||= begin
      db_count(DBTBL_CONCURS_PER_CONCOURS, {annee:ANNEE_CONCOURS_COURANTE})
    end
  end #/ nombre_synopsis
end #/HTML
