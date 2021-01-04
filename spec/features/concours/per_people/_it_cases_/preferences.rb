# encoding: UTF-8
# frozen_string_literal: true

MESSAGE_RECOIT_FICHE_LECTURE = "Vous recevrez la fiche de lecture sur votre projet."
LINK_DONT_WANT_FICHE_LECTURE = "Je ne veux plus recevoir cette fiche de lecture"
MESSAGE_DONT_WANT_FICHE_LECTURE = "Vous ne recevrez pas la fiche de lecture."
LINK_WANT_FICHE_LECTURE = "Finalement, je veux bien recevoir cette fiche de lecture"
MESSAGE_RECOIT_MAIL_INFOS = "Vous recevez des informations sur le concours (échéances, inscrits, etc.)."
LINK_DONT_WANT_MAIL_INFOS = "Je ne veux plus recevoir ces informations"
MESSAGE_DONT_WANT_MAIL_INFOS = "Vous ne recevez pas les informations sur le concours."
LINK_WANT_MAIL_INFOS = "Finalement, je voudrais bien recevoir ces informations (échéances, inscrits, etc.)"


def peut_modifier_ses_preferences_notifications
  it "peut modifier ses préférences pour le mail d'infos" do
    pending "à implémenter"
  end
end #/ peut_modifier_ses_preferences_notifications


def peut_modifier_ses_preferences_fiche_de_lecture
  it "peut modifier ses préférences de fiche de lecture" do
    expect(visitor.options[1]).to eq("1")
    visitor.identify
    expect(page).to be_espace_personnel
    expect(page).to have_content(MESSAGE_RECOIT_FICHE_LECTURE)
    expect(page).to have_link(LINK_DONT_WANT_FICHE_LECTURE)
    # *** Test ***
    visitor.click_on(LINK_DONT_WANT_FICHE_LECTURE)
    # *** Vérifications ***
    expect(page).to have_message("D'accord, vous ne recevrez plus la fiche de lecture")
    expect(page).to have_content(MESSAGE_DONT_WANT_FICHE_LECTURE)
    expect(page).to have_link(LINK_WANT_FICHE_LECTURE)
    # Dans les données du concurrent
    visitor.reset
    expect(visitor.options[1]).to eq("0")
    # *** Test 2***
    visitor.click_on(LINK_WANT_FICHE_LECTURE)
    # *** Vérifications ***
    expect(page).to have_message("D'accord, vous recevrez la fiche de lecture.")
    expect(page).to have_content(MESSAGE_RECOIT_FICHE_LECTURE)
    expect(page).to have_link(LINK_DONT_WANT_FICHE_LECTURE)
    # Dans les données du concurrent
    visitor.reset
    expect(visitor.options[1]).to eq("1")
    visitor.logout
  end
end #/ peut_modifier_ses_preferences_fiche_de_lecture
