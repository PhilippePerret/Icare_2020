# encoding: UTF-8
# frozen_string_literal: true
class HTML

  def section_fichier_candidature
    if Concours.current.phase1?
      # <=  Concours en phase 1
      # =>  Affichage du formulaire si le concurrent n'a pas encore transmis
      #     son fichier, sinon une message lui indiquant
      if concurrent.current?
        if concurrent.dossier_transmis?
          Tag.div(text:"Votre fichier de candidature a bien été transmis.")
        else
          # <= Un concurrent qui n'a pas encore transmis son fichier
          # =>  On lui propose le formulaire.
          formulaire_depot_fichier_candidature
        end
      else
        # <= Pas un concurrent de cette session
        # => l'inviter à s'inscrire
        Tag.div(text:"Vous devez #{CONCOURS_SIGNUP.with("vous inscrire à la session #{Concours.current.annee}")} du concours pour transmettre un fichier de candidature.")
      end
    else
      # <= Concours pas en phase 1 => Message
      Tag.div(text:"Votre fichier de candidature pourra être transmis lorsque le prochain concours sera lancé et que vous y serez inscrit.")
    end
  end #/ section_fichier_candidature

  def formulaire_depot_fichier_candidature
    form = Form.new(id: "concours-dossier-form", route:route.to_s, class:"nomargin noborder nobackground", file: true, value_size: "600px")
    form.rows = {
      "Titre du projet" => {type:"text", name:"p_titre"},
      "Auteur·e·(s)"    => {type:"text", name:"p_auteurs", placeholder:"Patronymes séparés par des virgules"},
      "Votre fichier"   => {type:"file", name:"p_fichier_candidature"},
      "<lien dossier/>" => {type:"raw", content:"<div class=\"italic small\">Voir le détail du #{Tag.lien(route:"concours/dossier", text:"contenu du dossier")}.</div>"},
    }
    form.submit_button = UI_TEXTS[:concours_bouton_send_dossier]
    form.out
  end #/ formulaire_depot_fichier_candidature
end #/HTML
