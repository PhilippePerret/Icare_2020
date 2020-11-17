# encoding: UTF-8
# frozen_string_literal: true
require_relative './_required'

feature "L'espace concours du participant" do
  before(:all) do
    require_support('concours-phase-2')
  end
  scenario "Le participant, après identification, trouve une page valide" do
    nb_participants = db_count(DBTBL_CONCURS_PER_CONCOURS, {annee:ANNEE_CONCOURS_COURANTE})
    concurrent = TConcurrent.get_random(current: true)
    concurrent.rejoint_le_concours
    expect(page).to be_espace_personnel
    # Il y a le bon nombre de participants
    expect(page).to have_css("span#nombre-concurrents", text: nb_participants.to_s.rjust(3,'0'))
    expect(page).to have_css("span.annee-concours", text: ANNEE_CONCOURS_COURANTE)
    expect(page).to have_css("span.theme-concours.caps", text: TConcours.current.theme)
    expect(page).to have_css("span.echeance-concours", text: "1er mars #{ANNEE_CONCOURS_COURANTE}")
    # TODO On pourrait imaginer poursuivre le check plus en profondeur.
  end
end
