# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test de toutes les phases du concours pour un :

    NOUVEAU CONCURRENT

  Description des phases :

  PHASE 0
    Trouve un simple encart annonçant le concours et permettant de s'inscrire
    Il peut s'inscrire et le fait.
  PHASE 1
    Trouve la page d'accueil normale.
    Il peut s'inscrire et le fait.
  PHASE 2
    Trouve la page d'accueil annonçant les 10 dossiers présélectionnés.
    Il ne peut plus s'inscrire.
  PHASE 3
    Trouve la page d'accueil annonçant la fin du concours et donc le palmarès.
    Ne peut plus s'inscrire.
  PHASE 5, 8 et 9
    Page d'accueil de fin du concours (palmarès).
    Peut s'inscrire à nouveau et le fait.
=end
require_relative './_required'

feature 'Un nouveau concurrent' do

  before(:all){ headless(false) }

  before(:each) do
    # puts "J'identifie le visiteur".bleu
    @visitor = TConcurrent.get_random(current:true, ancien:false, femme:true, fichier:false)
    try_identify_visitor
  end

  context 'en PHASE 0', phase0:true do

    before(:all) { degel('concours-phase-0') }

    # peut_rejoindre_le_concours
    # peut_atteindre_lannonce_du_prochain_concours
    # ne_peut_pas_sinscrire_au_concours
    # peut_rejoindre_son_espace_personnel(0)
    # ne_peut_pas_transmettre_de_dossier("Vous pourrez transmettre votre dossier lorsque le concours sera lancé")

    context 'qui ne veut pas recevoir sa fiche de lecture' do
      before(:each){ visitor.set_pref_fiche_lecture(false);reconnecte_visitor }
      peut_rejoindre_la_section_fiches_de_lecture_as(as = :concurrent, MESSAGES[:prefs_dont_want_fiches_lecture])
      ne_peut_pas_telecharger_sa_fiche_de_lecture(raison = :not_want)
    end

    context 'qui veut recevoir sa fiche de lecture' do
      before(:each){ visitor.set_pref_fiche_lecture(true);reconnecte_visitor }
      peut_rejoindre_la_section_fiches_de_lecture_as(as = :concurrent, MESSAGES[:too_soon_to_get_fiche_lecture])
      ne_peut_pas_telecharger_sa_fiche_de_lecture(raison = :new)
    end

    # peut_detruire_son_inscription

    # --- Sections interdites ---
    # ne_peut_pas_atteindre_la_section_evalutation

  end #/context PHASE 0


  context 'PHASE 1' do
    before :all do
      # puts "Je dégèle la phase 1".bleu
      degel('concours-phase-1')
    end

    peut_rejoindre_le_concours
    peut_rejoindre_toutes_les_sections_depuis_laccueil
    ne_peut_pas_sinscrire_au_concours
    peut_rejoindre_son_espace_personnel(1)
    peut_modifier_ses_preferences_notifications
    peut_modifier_ses_preferences_fiche_de_lecture

    peut_rejoindre_la_section_fiches_de_lecture_as(as = :concurrent)
    ne_peut_pas_telecharger_sa_fiche_de_lecture(:new)

    peut_detruire_son_inscription

    context 's’il n’a pas encore déposé son dossier' do
      before(:each){ visitor.destroy_fichier } # au cas où
      peut_transmettre_son_dossier
    end

    context 's’il a déjà déposé un dossier valide' do
      before(:each){ visitor.make_fichier_conforme }
      ne_peut_pas_transmettre_de_dossier("Votre fichier de candidature a bien été transmis.")
    end

    context 's’il a déposé un dossier invalide' do
      before(:each){ visitor.make_fichier_non_conforme }
      peut_transmettre_son_dossier
    end

    # --- Sections interdites ---
    # ne_peut_pas_atteindre_la_section_evalutation

  end #/context PHASE 1

  context 'PHASE 2' do
    before :all do
      # puts "Je dégèle la phase 2".bleu
      degel('concours-phase-2')
    end
    peut_rejoindre_le_concours
    ne_peut_pas_atteindre_la_section_evalutation

    peut_rejoindre_la_section_fiches_de_lecture_as(as = :concurrent)
    ne_peut_pas_telecharger_sa_fiche_de_lecture(:new)

    peut_detruire_son_inscription

    context 'qui a envoyé un dossier valide' do
      before(:each){ visitor.make_fichier_conforme }
      ne_peut_plus_transmettre_son_dossier("Votre dossier a été pris en compte")
    end

    context 'qui a envoyé un dossier invalide' do
      before(:each){ visitor.make_fichier_non_conforme }
      ne_peut_plus_transmettre_son_dossier("Votre dossier est invalide")
    end

    context 'qui n’a pas envoyé de dossier' do
      before(:each){ visitor.destroy_fichier } # au cas où
      ne_peut_plus_transmettre_son_dossier("Vous n'avez transmis aucun dossier de candidature")
    end

  end #/context PHASE 2

  context 'PHASE 3' do
    before :all do
      degel('concours-phase-3')
    end

    peut_rejoindre_le_concours
    ne_peut_plus_transmettre_son_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_rejoindre_la_section_fiches_de_lecture_as(as = :concurrent)
    ne_peut_pas_telecharger_sa_fiche_de_lecture(raison = :new)
    peut_detruire_son_inscription

  end #/context PHASE 3

  context 'PHASE 5, 8 et 9' do
    before :all do
      degel('concours-phase-5')
    end

    peut_rejoindre_le_concours
    ne_peut_plus_transmettre_son_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_telecharger_sa_fiche_de_lecture
    peut_detruire_son_inscription

  end #/context PHASE 5, 8 et 9

end
