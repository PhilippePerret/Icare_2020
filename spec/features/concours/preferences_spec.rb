# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test du changement de préférences
=end
require_relative './_required'

feature "Changement des préférences pour le concours" do

  MESSAGE_RECOIT_FICHE_LECTURE = "Vous recevrez la fiche de lecture sur votre projet."
  LINK_DONT_WANT_FICHE_LECTURE = "Je ne veux plus recevoir cette fiche de lecture"
  MESSAGE_DONT_WANT_FICHE_LECTURE = "Vous ne recevrez pas la fiche de lecture."
  LINK_WANT_FICHE_LECTURE = "Finalement, je veux bien recevoir cette fiche de lecture"
  MESSAGE_RECOIT_MAIL_INFOS = "Vous recevez des informations sur le concours (échéances, inscrits, etc.)."
  LINK_DONT_WANT_MAIL_INFOS = "Je ne veux plus recevoir ces informations"
  MESSAGE_DONT_WANT_MAIL_INFOS = "Vous ne recevez pas les informations sur le concours."
  LINK_WANT_MAIL_INFOS = "Finalement, je voudrais bien recevoir ces informations (échéances, inscrits, etc.)"

  before(:all) do
    degel('concours-phase-1')
  end

  let(:concurrent) { @concurrent }

  context 'Un visiteur quelconque' do
    before(:all) do

    end
    scenario 'ne peut pas rejoindre la page pour définir des préférences' do
      goto("concours/espace_concurrent")
      expect(page).not_to have_titre("Espace personnel")
      expect(page).to have_titre("Identification")
    end

    scenario 'ne peut pas forcer les préférences par un url directe' do
      goto("concours/espace_concurrent?op=nonfl")
      expect(page).not_to have_titre("Espace personnel")
      expect(page).to have_titre("Identification")
      goto("concours/espace_concurrent?op=ouifl")
      expect(page).not_to have_titre("Espace personnel")
      expect(page).to have_titre("Identification")
      goto("concours/espace_concurrent?op=nonwarn")
      expect(page).not_to have_titre("Espace personnel")
      expect(page).to have_titre("Identification")
      goto("concours/espace_concurrent?op=ouiwarn")
      expect(page).not_to have_titre("Espace personnel")
      expect(page).to have_titre("Identification")
    end
  end

  context 'Un concurrent courant' do
    before(:all) do
      @concurrent = TConcurrent.get_random(current: true)
    end

    scenario 'peut définir sa préférence pour son mail d’information' do
      # *** Vérification préliminaire ***
      expect(concurrent.options[0]).to eq("1")
      concurrent.identify
      expect(page).to be_espace_personnel
      expect(page).to have_content(MESSAGE_RECOIT_MAIL_INFOS)
      expect(page).to have_link(LINK_DONT_WANT_MAIL_INFOS)
      # *** Test ***
      concurrent.click_on(LINK_DONT_WANT_MAIL_INFOS)
      # *** Vérifications ***
      expect(page).to have_message("D'accord, vous ne recevrez plus d'informations sur le concours")
      expect(page).to have_content(MESSAGE_DONT_WANT_MAIL_INFOS)
      expect(page).to have_link(LINK_WANT_MAIL_INFOS)
      # Dans les données du concurrent
      concurrent.reset
      expect(concurrent.options[0]).to eq("0")
      # *** Test 2***
      concurrent.click_on(LINK_WANT_MAIL_INFOS)
      # *** Vérifications ***
      expect(page).to have_message("D'accord, vous recevrez les informations sur le concours.")
      expect(page).to have_content(MESSAGE_RECOIT_MAIL_INFOS)
      expect(page).to have_link(LINK_DONT_WANT_MAIL_INFOS)
      # Dans les données du concurrent
      concurrent.reset
      expect(concurrent.options[0]).to eq("1")
      concurrent.logout
    end

  end #/context : un concurrent courant


  context 'Un ancien concurrent' do
    before(:all) do
      @concurrent = TConcurrent.get_random(current: false)
    end
    scenario 'peut définir sa préférence pour la fiche de lecture' do
      # *** Vérification préliminaire ***
      expect(concurrent.options[1]).to eq("1")
      concurrent.identify
      goto("concours/espace_concurrent")
      expect(page).to be_espace_personnel
      expect(page).to have_content(MESSAGE_RECOIT_FICHE_LECTURE)
      expect(page).to have_link(LINK_DONT_WANT_FICHE_LECTURE)
      # *** Test ***
      concurrent.click_on(LINK_DONT_WANT_FICHE_LECTURE)
      # *** Vérifications ***
      expect(page).to have_message("D'accord, vous ne recevrez plus la fiche de lecture")
      expect(page).to have_content("Vous ne recevrez pas la fiche de lecture.")
      expect(page).to have_link(LINK_WANT_FICHE_LECTURE)
      # Dans les données du concurrent
      concurrent.reset
      expect(concurrent.options[1]).to eq("0")
      # *** Test 2***
      concurrent.click_on(LINK_WANT_FICHE_LECTURE)
      # *** Vérifications ***
      expect(page).to have_message("D'accord, vous recevrez la fiche de lecture.")
      expect(page).to have_content(MESSAGE_RECOIT_FICHE_LECTURE)
      expect(page).to have_link(LINK_DONT_WANT_FICHE_LECTURE)
      # Dans les données du concurrent
      concurrent.reset
      expect(concurrent.options[1]).to eq("1")
    end
  end # /context un ancien concurrent

end
