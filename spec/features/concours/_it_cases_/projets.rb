# encoding: UTF-8
# frozen_string_literal: true


def peut_lire_un_projet
  # Méthode qui teste que le visiteur courant peut lire un projet, sous forme de PDF, sur le site. Pour pouvoir fonctionner, il faut que le before crée au moins un document à lire.
  it "peut lire un projet déposé" do
    goto('concours/evaluation')
    expect(page).to be_cartes_synopsis
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

def ne_peut_pas_lire_un_projet(raison = nil)
  it "ne peut pas lire de projet en se rendant sur la page d'évaluation" do
    goto('concours/evaluation')
    case raison
    when :too_soon
      expect(page).to be_cartes_synopsis(complete = false)
      # mais…
      expect(page).to have_content("Vous ne pouvez pas encore évaluer les synopsis")
    else
      expect(page).not_to be_cartes_synopsis
    end
  end
end #/ ne_peut_pas_lire_un_projet
