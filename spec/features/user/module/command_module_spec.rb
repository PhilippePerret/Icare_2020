# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module de test de la commande d'un module
=end
require_relative './_required'

feature "Commande d'un module" do
  before(:all) do
    TMails.remove_all
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

  context 'un icarien actif' do
    before(:all) do
      require "#{FOLD_REL_PAGES}/plan/constants"
      degel('define_sharing')
      TMails.remove_all
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
      TMails.remove_all
    end
    scenario 'peut commander un nouveau module comme il veut', only:true do
      start_time = Time.now.to_i
      pitch("Marion, en tant qu'icarienne inactive, peut commander un nouveau module. ELle suit alors toute la procédure normale jusqu'au démarrage de son nouveau module.")
      marion.rejoint_son_bureau
      page.find("section#header").click
      marion.click_on("Plan")
      marion.click_on("LES MODULES")
      expect(page).to have_titre("Les Modules d’apprentissage")
      within("div#absmodule-6 div.btn-command-module", match: :first) do
        marion.click_on("Commander ce module")
      end
      expect(page).to have_titre("Commande d’un module")
      marion.click_on("Je confirme l'option sur le module « Structure »")
      # *** Vérifications ***
      expect(page).to have_titre "Confirmation de commande"
      screenshot("marion-after-confirmation-module")
      expect(phil).to have_mail(subject:"Une commande de module", after: start_time),
        "Je devrais avoir reçu un mail d'information"
      expect(marion).to have_mail(subject:"Votre commande de module", after: start_time),
        "Marion devrait avoir reçu un mail de confirmation de sa commande"
      expect(TWatchers).to be_exists(user_id: marion.id, after: start_time, wtype: 'commande_module')
      twatcher =  TWatchers.founds.first
      marion.se_deconnecte

      start_time
      pitch("Je viens me connecter pour valider la commande de module de MarionM")
      phil.rejoint_son_bureau
      phil.click_on('Notifications')
      expect(page).to have_titre("Notifications")
      within("div#watcher-#{twatcher.id}") do
        phil.click_on("Accepter")
      end
      expect(marion).to have_mail(subject:"Votre commande de module a été acceptée", after: start_time),
        "Marion devrait avoir reçu un mail d'acceptation de sa commande de module"
      expect(marion).to have_watcher(after:start_time, wtype:'start_module'),
        "Marion devrait avoir un watcher de démarrat de module"
      twatcher_start = TWatchers.founds.first
      # Un watcher de paiement N'a  PAS été créé
      expect(marion).not_to have_watcher(after:start_time, wtype:'paiement_module'),
        "Marion ne devrait pas avoir de watcher de paiement pour payer son module"
      phil.se_deconnecte

      start_time = Time.now.to_i
      marion.rejoint_son_bureau
      marion.click_on("Notifications")
      expect(page).to have_titre("Notifications")
      screenshot("notifications-marion-avant-start-module")
      expect(page).to have_css("div#watcher-#{twatcher_start.id}")
      within("div#watcher-#{twatcher_start.id}") do
        marion.click_on("Démarrer le module “Structure”")
      end
      screenshot("marion-demarre-second-module")
      expect(marion).to have_watcher(after:start_time, wtype:'paiement_module'),
        "Marion devrait avoir un watcher de paiement pour payer son module"
      expect(TActualites).to have_actualite(after: start_time, type: 'STARTMOD', user_id: marion.id),
        "Une actualité devrait annoncer le démarrage du module de Marion"
      marion.se_deconnecte
    end
  end
end
