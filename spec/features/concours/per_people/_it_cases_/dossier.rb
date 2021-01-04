# encoding: UTF-8
# frozen_string_literal: true

def peut_transmettre_son_dossier(data = nil)
  data ||= {}
  data[:titre] ||= "Titre à #{Time.now.to_i}"
  it "peut transmettre son dossier pour le projet “#{data[:titre]}”" do
    start_time = Time.now.to_i - 1
    visitor.rejoint_le_concours
    goto("concours/espace_concurrent")
    expect(page).to be_espace_personnel
    expect(visitor.specs[0]).not_to eq "1"
    syno_path = File.expand_path(File.join('.','spec','support','asset','documents','synopsis_concours.pdf'))
    within("form#concours-fichier-form") do
      fill_in("p_titre",    with: data[:titre])
      fill_in("p_auteurs",  with: data[:auteurs]) if data.key?(:auteurs)
      attach_file("p_fichier_candidature", syno_path)
      click_on(UI_TEXTS[:concours_bouton_send_dossier])
    end
    screenshot("after-send-fichier-concours")
    # *** Vérifications ***
    # Le document a été déposé avec le bon titre au bon endroit
    # (vérifier aussi la taille)
    path = File.join(visitor.folder, "#{visitor.id}-#{ANNEE_CONCOURS_COURANTE}.pdf")
    expect(File).to be_exists(path)
    expect(File.stat(syno_path).size).to eq(File.stat(path).size)
    # Un mail de confirmation a été envoyé au concurrent
    expect(visitor).to have_mail(subject:"[CONCOURS] Réception de votre fichier de candidature", after: start_time)
    # Les specs de son enregistrement pour le concours ont été modifiée
    # J'ai reçu un mail m'informant de l'envoi du synopsis
    expect(phil).to have_mail(subject:"[CONCOURS] Dépôt d'un fichier de candidature", after: start_time)
    visitor.reset
    expect(visitor.specs[0..1]).to eq "10", "Les deux premiers bit des specs du concurrent devrait être '01'…"
    # Une actualité annonce l'envoi du synopsis
    expect(TActualites).to be_exists(after:start_time, type:"CONCOURSFILE"), "Une actualité devrait annoncer l'envoi du fichier"
  end
end #/ peut_transmettre_son_dossier

def ne_peut_pas_transmettre_de_dossier
  it "ne peut pas/plus transmettre de dossier de candidature" do
    visitor.rejoint_le_concours
    goto("concours/espace_concurrent")
    expect(page).not_to have_css('form#concours-fichier-form')
  end
end #/ ne_peut_pas_transmettre_de_dossier
alias :ne_peut_plus_transmettre_son_dossier :ne_peut_pas_transmettre_de_dossier
