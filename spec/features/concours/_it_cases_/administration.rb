# encoding: UTF-8
# frozen_string_literal: true
=begin
  IT-CASES concernant l'administration du concours
=end


def peut_passer_le_concours_a_la_phase_suivante(phase_expected)
  it "peut passer le concours à la phase #{phase_expected}" do
    # Avant toute chose, on prend la phase courante
    conc = TConcours.current
    old_phase = conc.phase.freeze

    # === OPÉRATION ===
    # Le nom du menu en fonction de la phase
    # + Certaines opérations à exécuter pour s'assurer que les tests se
    #   feront complètement
    require_relative "../xlib/phases_check/phase-#{phase_expected}"
    item_menu = case phase_expected - 1
                when 0 then 'Lancer et annoncer le concours'
                when 1
                  ensure_test_phase_2
                  'Annoncer l\'échéance des dépôts'
                when 2 then 'Annoncer fin de présélection'
                when 3 then 'Annoncer le palmarès'
                when 5 then 'Annoncer fin officielle du concours'
                when 8 then 'Nettoyer le concours'
                when 9 then raise "C'est impossible, normalement"
                end
    goto("concours/admin")
    # sleep 15
    within('form#concours-phase-form') do
      select(item_menu, from: 'current_phase')
      click_on('Simuler pour procéder à cette étape…')
    end
    click_on('Procéder aux opérations cochées')

    # === VÉRIFICATION ===
    conc.reset
    new_phase = conc.phase
    expect(new_phase).to eq(old_phase + 1)
    expect(new_phase).to eq(phase_expected)

    # === Vérification profonde ===
    send("check_phase_#{old_phase + 1}".to_sym)

    # === POST-OPÉRATION ===
    # On revient à la phase précédente
    degel("concours-phase-#{old_phase}")
  end
end #/ peut_passer_le_concours_a_la_phase_suivante

def ne_peut_pas_passer_le_concours_a_la_phase_suivante
  it "ne peut pas passer le concours a la phase suivante" do
    goto("concours/admin")
    pending
    # En rejoignant l'administration
    # TODO
    # Par route directe
    # TODO
  end
end
