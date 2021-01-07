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
    expect(visitor.options[0]).to eq("1"), "Les options du concurrent devraient être réglées pour recevoir le mail d'info (c'est un problème qu'il faut régler au niveau du test)"
    goto("concours/espace_concurrent")
    expect(page).to be_espace_personnel
    expect(page).to have_content(MESSAGE_RECOIT_MAIL_INFOS)
    expect(page).to have_link(LINK_DONT_WANT_MAIL_INFOS)
    # *** Test ***
    visitor.click_on(LINK_DONT_WANT_MAIL_INFOS)
    # *** Vérifications ***
    expect(page).to have_message("D'accord, vous ne recevrez plus d'informations sur le concours")
    expect(page).to have_content(MESSAGE_DONT_WANT_MAIL_INFOS)
    expect(page).to have_link(LINK_WANT_MAIL_INFOS)
    # Dans les données du concurrent
    visitor.reset
    expect(visitor.options[0]).to eq("0")
    # *** Test 2***
    visitor.click_on(LINK_WANT_MAIL_INFOS)
    # *** Vérifications ***
    expect(page).to have_message("D'accord, vous recevrez les informations sur le concours.")
    expect(page).to have_content(MESSAGE_RECOIT_MAIL_INFOS)
    expect(page).to have_link(LINK_DONT_WANT_MAIL_INFOS)
    # Dans les données du concurrent
    visitor.reset
    expect(visitor.options[0]).to eq("1")
    visitor.logout
  end
  it "ne peut pas modifier la préférence de mail d'info par lien direct" do
    visitor.logout
    goto("concours/espace_concurrent?op=nonwarn")
    expect(page).to be_identification_concours
    goto("concours/espace_concurrent?op=ouiwarn")
    expect(page).to be_identification_concours
  end
end #/ peut_modifier_ses_preferences_notifications


def peut_modifier_ses_preferences_fiche_de_lecture
  it "peut modifier ses préférences de fiche de lecture" do
    expect(visitor.options[1]).to eq("1"), "Les options du concurrent devraient être réglées pour recevoir la fiche de lecture (c'est un problème qu'il faut régler au niveau du test)"
    goto("concours/espace_concurrent")
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
  end
  it "ne peut pas modifier ses préférences de fiche de lecture par lien direct" do
    visitor.logout
    goto("concours/espace_concurrent?op=nonfl")
    expect(page).to be_identification_concours
    goto("concours/espace_concurrent?op=ouifl")
    expect(page).to be_identification_concours
  end
end #/ peut_modifier_ses_preferences_fiche_de_lecture
