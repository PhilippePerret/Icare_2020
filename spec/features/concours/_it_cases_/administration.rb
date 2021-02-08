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
    item_menu = case phase_expected - 1
                when 0 then 'Lancer et annoncer le concours'
                when 1 then 'Annoncer l\'échéance des dépôts'
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

    # === POST-OPÉRATION ===
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

def peut_refuser_un_dossier(concurrent)
  it 'peut refuser un dossier pour non conformité' do

    # *** Vérifications préliminaires ***
    expect(concurrent.specs[0]).to eq('1')
    expect(concurrent.specs[1]).to eq('0')

    phil.rejoint_le_site
    goto("concours/evaluation")
    expect(page).to be_fiches_synopsis
    expect(page).to have_css(fiche_concurrent_selector)
    screenshot("avec-bouton-fichier-concours-non-conforme")
    within(fiche_concurrent_selector) do
      expect(page).to have_link(BUTTON_NON_CONFORME)
      phil.click_on(BUTTON_NON_CONFORME)
    end
    screenshot("phil-on-synopsis-form-pour-non-conformite")
    expect(page).to be_formulaire_synopsis(conformite: true)

    # Liste des points de non conformité
    premier_motif_ajouted = "ceci est une raison détaillée du refus (à ne pas corriger)"
    second_motif_ajouted = "une autre raison finale (à ne pas corriger)"
    # non_conformites = [:incomplet, :titre, :bio]
    non_conformites = MOTIF_NON_CONFORMITE.keys
    motif_detailled = "#{premier_motif_ajouted}\n#{second_motif_ajouted}"
    within("form#non-conformite-form") do
      non_conformites.each do |motif|
        check("motif_#{motif}")
      end
      fill_in('motif_detailled', with: motif_detailled)
      phil.click_on(BUTTON_NON_CONFORME)
    end
    screenshot("phil-envoie-non-conformite")

    # Un message confirme la bonne manœuvre
    expect(page).to have_message("Le synopsis a été marqué non conforme. #{concurrent.pseudo} a été averti#{concurrent.fem(:e)}")

    # Le synopsis a été marqué non conforme
    concurrent.reset
    expect(concurrent.specs[0]).to eq('1')
    expect(concurrent.specs[1]).to eq('2'),
      "Le deuxième bit des specs du synopsis devrait être à 2 (non conforme) il est à #{concurrent.specs[1].inspect}"


    # La concurrent a reçu le mail avec chaque motif explicité
    bouts = [] # les bouts à trouver dans le mail
    non_conformites.each do |motif|
      dmotif = MOTIF_NON_CONFORMITE[motif]
      bouts << dmotif[:motif]
      bouts << dmotif[:precision] unless dmotif[:precision].nil?
    end
    bouts << "#{premier_motif_ajouted}," # noter la virgule
    bouts << "#{second_motif_ajouted}." # noter le point
    expect(concurrent).to have_mail(after: start_time, from:CONCOURS_MAIL, subject:"Votre fichier n'est pas conforme", message: bouts)

    goto("concours/evaluation")
    expect(page).to have_css("div#synopsis-#{synopsis.id}.not-conforme"),
      "La page devrait contenir la fiche du synopsis entourée de rouge (class not-conforme)"
    within(fiche_concurrent_selector) do
      expect(page).not_to have_link("Marquer conforme")
      expect(page).not_to have_link(BUTTON_NON_CONFORME)
    end
    phil.se_deconnecte
  end
end #/ peut_refuser_un_dossier
