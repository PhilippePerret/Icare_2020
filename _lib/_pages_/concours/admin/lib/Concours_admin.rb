# encoding: UTF-8
# frozen_string_literal: true
class Concours

attr_reader :resultat
def save(data)
  columns = data.keys.collect{|c|"#{c} = ?"}
  columns << "updated_at = ?"
  values  = data.values
  values << Time.now.to_i.to_s
  db_exec("UPDATE #{DBTBL_CONCOURS} SET #{columns.join(', ')} WHERE annee = #{annee}", values)
end #/ save

private

  # OUT   Les données par défaut, à la création du concours de l'année
  def data_default
    {
      annee: ANNEE_CONCOURS_COURANTE,
      theme: "l'accident",
      prix1: "Un an de \#{Tag.link(text:\"suivi de développement en suivi intensif\", route:\"modules/home#absmodule-7\",target: :blank)} au sein de l'atelier (d'une valeur de 1380 €) <span class=\"small\">(*)</span>",
      prix2: "Un an de \#{Tag.link(text:\"suivi de développement en suivi normal\", route:\"modules/home#absmodule-8\",target: :blank)} au sein de l'atelier (d'une valeur de 900 €) <span class=\"small\">(*)</span>",
      prix3: "Deux \#{Tag.link(text:\"modules de “coaching intensif”\", route:\"modules/home#absmodule-12\")} (d'une valeur de 400 €)",
      theme_d: <<-TEXT
Avant l'accident, après l'accident, pendant l'accident, accident de la route ou de caddie, accident involontaire ou provoqué, peu importe le temps, le lieu, la durée choisis, l'histoire présentée dans le synopsis devra s'articuler autour de cet évènement dramatique.
      TEXT
    }
  end #/ data_default

end #/Concours
