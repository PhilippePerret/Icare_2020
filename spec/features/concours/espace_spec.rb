# encoding: UTF-8
# frozen_string_literal: true
feature "L'espace concours du participant" do
  before(:all) do
    require_support('concours')
  end
  scenario "Le participant, après identification, trouve une page valide" do
    nb_participants = db_count(DBTBL_CONCURS_PER_CONCOURS, {annee:ANNEE_CONCOURS_COURANTE})
    expect(page).to have_css()
  end
end
