# encoding: UTF-8
# frozen_string_literal: true

def peut_transmettre_son_dossier(data = nil)
  data ||= {}
  data[:titre] ||= "Titre à #{Time.now.to_i}"
  it "peut transmettre son dossier pour le projet “#{data[:titre]}”" do
    start_time = Time.now.to_i - 1
    # Préparation
    # -----------
    # Si le visiteur a déjà déposé son fichier, on le détruit
    vtested = visitor.is_a?(TUser) ? visitor.as_concurrent : visitor
    if vtested.dossier_transmis?
      vtested.destroy_fichier
      vtested.reset
    end
    goto("concours/espace_concurrent")
    screenshot('accueil-pour-depot-dossier')
    expect(page).to be_espace_personnel
    expect(vtested.specs[0]).not_to eq "1"
    syno_path = File.expand_path(File.join('.','spec','support','asset','documents','synopsis_concours.pdf'))
    expect(page).to have_css('form#concours-fichier-form')
    within("form#concours-fichier-form") do
      fill_in("p_titre",    with: data[:titre])
      fill_in("p_auteurs",  with: data[:auteurs]) if data.key?(:auteurs)
      attach_file("p_fichier_candidature", syno_path)
      click_on(UI_TEXTS[:concours_bouton_send_dossier])
    end
    screenshot("after-send-fichier-concours")
    vtested.reset
    expect(vtested.specs[0..1]).to eq("10"), "Les deux premiers bit des specs du concurrent devrait être '10'…"
    # *** Vérifications ***
    # Le document a été déposé avec le bon titre au bon endroit
    # (vérifier aussi la taille)
    path = File.join(vtested.folder, "#{vtested.id}-#{ANNEE_CONCOURS_COURANTE}.pdf")
    expect(File).to be_exists(path)
    expect(File.stat(syno_path).size).to eq(File.stat(path).size)
    # Un mail de confirmation a été envoyé au concurrent
    expect(vtested).to have_mail(subject:"[CONCOURS] Réception de votre fichier de candidature", after: start_time, message:["Je vous informe que votre dossier de candidature pour le concours de synopsis"])
    # Les specs de son enregistrement pour le concours ont été modifiée
    # J'ai reçu un mail m'informant de l'envoi du synopsis
    expect(TMails).to have_mail(to:CONCOURS_MAIL, subject:"[CONCOURS] Dépôt d'un fichier de candidature", after: start_time, message:["Je t’informe d’un dépôt de dossier de cancidature", "icare concours download"])
    # Une actualité annonce l'envoi du synopsis
    expect(TActualites).to be_exists(after:start_time, type:"CONCOURSFILE"), "Une actualité devrait annoncer l'envoi du fichier"
  end
end #/ peut_transmettre_son_dossier

def ne_peut_pas_transmettre_de_dossier(message = nil)
  it "ne peut pas/plus transmettre de dossier de candidature" do
    goto("concours/espace_concurrent")
    expect(page).not_to be_page_erreur
    expect(page).not_to have_css('form#concours-fichier-form')
    unless message.nil?
      expect(page).to have_content(message)
    end
  end
end #/ ne_peut_pas_transmettre_de_dossier
alias :ne_peut_plus_transmettre_son_dossier :ne_peut_pas_transmettre_de_dossier



def peut_refuser_un_dossier(concurrent)
  it 'peut refuser un dossier pour non conformité' do

    # *** Vérifications préliminaires ***
    expect(concurrent.specs[0]).to eq('1')
    expect(concurrent.specs[1]).to eq('0')

    phil.rejoint_le_site
    goto("concours/evaluation")
    expect(page).to be_cartes_synopsis
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
