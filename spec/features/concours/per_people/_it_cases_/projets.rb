# encoding: UTF-8
# frozen_string_literal: true


def peut_lire_un_projet
  # Méthode qui teste que le visiteur courant peut lire un projet, sous forme de PDF, sur le site. Pour pouvoir fonctionner, il faut que le before crée au moins un document à lire.
  it "peut lire un projet déposé" do
    goto('concours/evaluation')
    expect(page).to be_page_evaluation
    id_synopsis = first('div.synopsis')[:id].split('-')[1..2].join('-')
    id_concurrent = id_synopsis.split('-')[0]
    first('div.synopsis').click_on('Évaluer')
    expect(page).to have_titre("Évaluation de #{id_synopsis}")
    expect(page).to have_link("Lire le projet")
    click_on('Lire le projet')
    sleep 2 # le temps que ça charge
    tab_id = page.driver.browser.window_handles.last
    page.driver.browser.switch_to.window tab_id
    expect(page.current_url).to eq("#{App.url}/_lib/data/concours/#{id_concurrent}/#{id_synopsis}.pdf")
  end
end

def ne_peut_pas_lire_un_projet
  it "ne peut pas lire de projet en se rendant sur la page d'évaluation" do
    goto('concours/evaluation')
    expect(page).not_to be_page_evaluation
  end
  # it "ne peut pas lire un projet en jouant son lien direct" do
  #   # On trouve un projet
  #   id_synopsis = File.basename(Dir["./_lib/data/concours/**/*-#{ANNEE_CONCOURS_COURANTE}.pdf"].first)
  #   id_synopsis = File.basename(id_synopsis, File.extname(id_synopsis))
  #   puts "Projet : #{id_synopsis.inspect}"
  #   id_concurrent = id_synopsis.split('-').first
  #   url = "#{App.url}/_lib/data/concours/#{id_concurrent}/#{id_synopsis}.pdf"
  #   visit(url)
  #   sleep 2 # le temps que ça charge
  #   tab_id = page.driver.browser.window_handles.last
  #   page.driver.browser.switch_to.window tab_id
  #   expect(page.current_url).not_to eq("#{App.url}/_lib/data/concours/#{id_concurrent}/#{id_synopsis}.pdf")
  # end
end #/ ne_peut_pas_lire_un_projet
