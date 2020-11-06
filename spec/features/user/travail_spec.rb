# encoding: UTF-8
# frozen_string_literal: true
require_relative './_required'

feature "Travail d'un icarien" do
  before(:all) do
    require './_lib/_pages_/bureau/travail/constants'
    require './_lib/_pages_/bureau/sender/constants'
  end

  scenario "Un icarien en activité trouve son travail sur son bureau" do
    degel('demarrage_module')
    pitch('Après avoir démarré son module, Marion rejoint son travail courant…'.freeze)
    marion.rejoint_son_bureau
    click_on('Travail courant')
    screenshot('marion-dans-sa-section-travail')
    expect(page).to have_titre('Votre travail', {retour:{route:'bureau/home', text:'Bureau'}})
    pitch('… et trouve un bon titre'.freeze)

    expect(page).to have_css('h1', text: "1. Introduction à l'analyse de film")
    pitch('… le titre de l’étape courante')

    [
      'div#etat-des-lieux',
      'section.etape_work',
      'fieldset#etape-work',
      'fieldset#etape-minifaq',
      'fieldset#quai-des-docs'
    ].each do |selector|
      expect(page).to have_selector(selector)
    end
    pitch('… les bonnes sections (et fieldset)')

    [
      'Travail à effectuer',
      'OBJECTIF',
      'ÉNONCÉ DU TRAVAIL',
      'ÉLÉMENTS DE MÉTHODES',
      'LIENS UTILES',
      'Quai des docs'
    ].each do |legende|
      expect(page).to have_css('fieldset legend', text: legende)
    end
    pitch('… les bonnes légendes')

    expect(page).to have_css('a[href="bureau/sender?rid=send_work_form"]', text:'Remettre le travail'),
      "La page devrait contenir le bouton pour remettre le travail"
    pitch("… un bouton pour remettre son travail")

  end



  context 'Un icarien en activité' do
    context 'qui n’a pas encore envoyé son travail' do
      before(:all) do
        degel('demarrage_module')
      end
      scenario 'trouve un bouton pour envoyer le travail' do
        pitch("Marion trouve un bouton pour envoyer son travail (i.e. pour rejoindre la section d'envoi des documents).")
        marion.rejoint_son_bureau
        marion.click_on("Travail courant")
        expect(page).to have_link(UI_TEXTS[:btn_remettre_travail])
      end
      scenario 'peut rejoindre la section d’envoi des documents' do
        pitch("Marion peut rejoindre la section d'envoi des documents et trouver un formulaire pour envoyer le travail.")
        marion.rejoint_son_bureau
        marion.click_on("Travail courant")
        marion.click_on(UI_TEXTS[:btn_remettre_travail])
        expect(page).to have_titre(MESSAGES[:titre_send_work_form])
        expect(page).to have_css('form#send-work-form')
      end
    end

    context 'qui a envoyé son travail' do
      before(:all) do
        degel('envoi_travail')
      end
      scenario 'trouve la mention de sa date d’envoi et de possible retour' do
        pitch("Quand marion rejoint son travail courant, elle ne trouve plus le bouton pour remettre son travail mais une date d'envoi et une date de retour des commentaires.")
        marion.rejoint_son_bureau
        marion.click_on("Travail courant")
        expect(page).not_to have_link(UI_TEXTS[:btn_remettre_travail])
        expect(page).to have_css("span.date-sent-work")
        expect(page).to have_css("span.date-expected-comments")
      end
      scenario 'ne peut pas rejoindre le formulaire d’envoi des documents' do
        pitch("Quand Marion rejoint son bureau, elle ne peut rejoindre la section d'envoi des documents même en forçant l'adresse.")
        marion.rejoint_son_bureau
        marion.click_on("Travail courant")
        expect(page).not_to have_link(UI_TEXTS[:btn_remettre_travail])
        goto("bureau/sender?rid=send_work_form")
        expect(page).not_to have_css('form#send-work-form')
        expect(page).to have_content("vous avez déjà transmis le travail de votre étape courante")
      end
    end

  end



end
