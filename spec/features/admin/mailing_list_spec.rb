# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module de test de mailing-list
  Quand l'administrateur est connecté, le formulaire de contact fonctionne
  comme un mailing list.
=end
include Capybara::DSL


BTN_PROCEED_ENVOI_MAILING = "Procéder à l’envoi du mailing enregistré"
BTN_DESTROY_ENVOI_MAILING = "Détruire ce mailing"

describe 'Mailing-list d’administration' do

  before(:all) do
    require './_lib/_pages_/contact/mail/constants'
    degel('marion-et-elie-invites-discussion-benoit-phil') # Pour avoir trois icariens
    require './spec/support/data/user_seed'
    UserSeed.feed(status:{recu:7, candidat:6, actif:5, en_pause:4, inactif:3})

  end


  context 'Un utilisateur quelconque' do
    let(:datapath) { './tmp/mails/mailing.json' }
    before(:each) do
      File.open(datapath,'wb'){|f| f.write('{"uuid":"DGFTY456DFG"}')}
    end
    after(:each) do
      File.delete(datapath)
    end

    scenario 'ne peut pas utiliser le mailing-list pour envoyer des messages' do
      expect(File.exists?(datapath)).to eq(true)
      goto('contact/mail')
      expect(page).not_to have_link(BTN_PROCEED_ENVOI_MAILING)
      goto('contact/mail?op=traite_mailing_list')
      expect(page).to have_titre('Identification')
      expect(File.exists?(datapath)).to eq(true)
    end

    scenario 'ne peut pas détruire un mailing-list enregistré' do
      expect(File.exists?(datapath)).to eq(true)
      goto('contact/mail')
      expect(page).not_to have_link(BTN_DESTROY_ENVOI_MAILING)
      goto('contact/mail?op=detruire_mailing_list?uuid=pourrire')
      expect(File.exists?(datapath)).to eq(true)
    end

  end




  context 'Un icarien identifié' do
    let(:datapath) { './tmp/mails/mailing.json' }
    before(:each) do
      File.open(datapath,'wb'){|f| f.write('{"uuid":"DGFTY456DFG"}')}
    end
    after(:each) do
      File.delete(datapath)
    end

    scenario 'ne peut pas utiliser le mailing-list pour envoyer des messages', only: true do

      expect(File.exists?(datapath)).to eq(true)
      benoit.rejoint_son_bureau
      goto('contact/mail')
      expect(page).not_to have_link(BTN_PROCEED_ENVOI_MAILING)
      goto('contact/mail?op=traite_mailing_list')
      expect(page).to have_titre('Accès interdit')
      expect(File.exists?(datapath)).to eq(true)
    end

    scenario 'ne peut pas détruire un mailing-list enregistré' do
      expect(File.exists?(datapath)).to eq(true)
      benoit.rejoint_son_bureau
      goto('contact/mail')
      expect(page).not_to have_link(BTN_DESTROY_ENVOI_MAILING)
      goto('contact/mail?op=detruire_mailing_list?uuid=pourrire')
      expect(File.exists?(datapath)).to eq(true)
    end
  end




  context 'Un administrateur' do
    scenario 'peut envoyer des messages par le formulaire de contact' do
      phil.rejoint_le_site
      phil.click('contact', within: '#footer')

      pitch("Je rejoins le site, m'identifie et rejoint le formulaire de contact.")
      expect(page).to have_titre("Mailing-list")

      pitch("Je trouve un formulaire valide, avec des choix pour caractériser l'envoi")
    end



    scenario 'peut envoyer un mailing-list enregistré avant' do
      pending
    end


    scenario 'ne peut pas transmettre deux fois un même mailing-list (en rechargeant la page)' do
      pending
    end



    scenario 'peut procéder à la destruction d’un mailing enregistré' do
      pending
    end
  end # / fin context administrateur
end
