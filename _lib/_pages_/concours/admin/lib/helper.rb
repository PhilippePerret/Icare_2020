# encoding: UTF-8
# frozen_string_literal: true
class HTML

  def lien_concours_data
    lien = Tag.link(route:"concours/admin", text:"Données du concours")
    Tag.div(text:lien, class:"mb2 right")
  end #/ lien_concours_data

  def lien_vers_evaluations
    lien = Tag.link(route:"concours/evaluation", text:"Évaluation des synopsis")
    Tag.div(text:lien, class:"right")
  end #/ lien_vers_evaluations

  # OUT   Formulaire pour les données du formulaire
  def concours_data_form
    form = Form.new(id:"concours-form", route:route.to_s, class:"nomargin nolimit", size:1000)
    form.rows = {
      "<op/>" => {type:"hidden", name:"op", value:"save_concours_data"},
      "Thème" => {type:"text", name:"concours_theme", value: concours.theme},
      "Description" => {type:"textarea", height:140, name:"concours_theme_d", value: concours.theme_d, placeholder:"Description du thème", explication: "Texte pouvant contenir des variables ruby \#{...} qui seront évaluées. Comme pour les Prix ci-dessous."},
      "Premier Prix"    => {type:"textarea", name:"concours_prix1", value: concours.prix1},
      "Deuxième Prix"   => {type:"textarea", name:"concours_prix2", value: concours.prix2},
      "Troisième Prix"  => {type:"textarea", name:"concours_prix3", value: concours.prix3},
    }
    form.submit_button = "Enregistrer"
    form.out
  end #/ concours_data_form
end #/HTML
