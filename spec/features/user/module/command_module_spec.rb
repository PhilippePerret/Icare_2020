# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module de test de la commande d'un module
=end
feature "Commande d'un module" do
  before(:all) do
    require "#{FOLD_REL_PAGES}/modules/xrequired/constants"
  end
  context 'un visiteur quelconque' do
    scenario 'ne peut pas commander directement un module' do
      pitch("Un visiteur quelconque, s'il commande un module dans la liste, est renvoyé au formulaire d'inscription.")
      goto('home')
      within('section#header'){click_on('en savoir plus')}
      click_on('modules d’apprentissage et de développement')
      expect(page).to have_titre(UI_TEXTS[:modules_apprentissage])
      first('a', text: (UI_TEXTS[:btn_commander_module])).click
      expect(page).to have_content("vous devez au préalable poser votre candidature")
      expect(page).to have_link(UI_TEXTS[:btn_canditater])
    end
  end

  context 'un icarien actif', only:true do
    before(:all) do
      require "#{FOLD_REL_PAGES}/plan/constants"
      degel('define_sharing')
    end
    scenario 'ne peut pas commander un nouveau module tant qu’il suit le sien' do
      pitch("Marion, en activité, si elle commande un module, est renvoyée à une page qui lui explique qu'elle ne peut pas commander un nouveau module avant d'avoir terminé le sien.")
      marion.rejoint_le_site
      goto('plan')
      click_on(UI_TEXTS[:les_modules])
      expect(page).to have_titre(UI_TEXTS[:modules_apprentissage])
      first('a', text: (UI_TEXTS[:btn_commander_module])).click
      expect(page).to have_titre(UI_TEXTS[:titre_commande_module])
      expect(page).not_to have_content('Merci de confirmer votre option')
      expect(page).to have_content('vous ne pouvez pas commander')
    end
  end



  context 'un icarien inactif' do
    before(:all) do
      degel('phil_arrete_module_marion')
    end
    scenario 'peut commander un nouveau module comme il veut' do
      pitch("Marion, en tant qu'icarienne inactive, peut commander un nouveau module. ELle suit alors toute la procédure normale jusqu'au démarrage de son nouveau module.")
      implementer(__FILE__,__LINE__)
    end
  end
end
