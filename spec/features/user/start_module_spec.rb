# encoding: UTF-8
=begin
  Test de démarrage de module d'apprentissage
=end
require './_lib/_watchers_processus_/_constants_'
require './_lib/pages/bureau/travail/constants'

feature "Test du démarrage de module" do
  before(:all) do
    load('./_lib/modules/watchers/Watcher/constants.rb')
  end

  context 'un visiteur quelconque' do
    before(:each) do
      degel('elie_demarre_son_module') # juste avant le démarrage du module de Benoit
    end
    scenario "ne peut pas démarrer de module" do
      pitch("Un visiteur quelconque tente de démarrer un module à partir d'une adresse qu'il a composée par exemple en fouillant le code. Il ne parvient à rien.")
      # Pour y parvenir, il faut qu'il existe un module validé en attente de
      # démarrage. On le fait avec Benoit.

      # --- Vérifications préliminaires ---
      dwat = db_get('watchers', 18)
      expect(dwat).not_to eq(nil)
      expect(dwat[:wtype]).to eq('start_module')
      # C'est bon, ce watcher de démarrage de module existe.

      # --- TEST ---
      goto('bureau?op=run&wid=18')
      screenshot('someone-force-start-module')

      # --- Vérifications ---
      pitch('Malgré la tentative pour forcer les choses…')
      expect(page).to have_titre('Identification'),
        "Le visiteur devrait être sur la page d'identification"
      pitch('… le visiteur se retrouve sur la page pour s’identifier')
      expect(benoit).to have_watcher(wtype:'start_module'),
        "Benoit devrait avoir toujours son watcher de démarrage de module."
      pitch('… Benoit a toujours son module de démarrage de module.')

    end
  end











  context 'un icarien déjà en activité, Marion,'do
    before(:each) do
      degel('elie_demarre_son_module')
        # juste avant le démarrage du module de Benoit
        # Et Marion est déjà en activité
    end

    scenario 'ne peut pas démarrer le module d’apprentissage d’un autre icarien' do

      # --- Vérifications préliminaires ---
      dwat = db_get('watchers', 18)
      expect(dwat).not_to eq(nil)
      expect(dwat[:wtype]).to eq('start_module')
      # C'est bon, ce watcher de démarrage de module existe.

      marion.rejoint_le_site
      goto('bureau?op=run&wid=18')
      screenshot('Marion-force-start-module')

      # --- Vérifications ---
      pitch('Malgré la tentative de Marion pour forcer les choses…')
      expect(page).to have_error(ERRORS[:owner_or_admin_required] % 'Marion')
      pitch('… Marion trouve un message d’erreur')
      expect(benoit).to have_watcher(wtype:'start_module'),
        "Benoit devrait avoir toujours son watcher de démarrage de module."
      pitch('… Benoit a toujours son module de démarrage de module.')

    end


  end #/ icarien en activité





  context 'un icarien inactif' do
    scenario 'peut démarrer un module approuvé' do
      degel('elie_demarre_son_module')

      # --- Vérifications préliminaires ---
      dwat = db_get('watchers', 18)
      expect(dwat).not_to eq(nil)
      expect(dwat[:wtype]).to eq('start_module')
      # C'est bon, ce watcher de démarrage de module existe.
      expect(benoit).not_to be_actif
      expect(benoit.icmodule_id).to eq(nil)

      start_time = Time.now.to_i

      pitch("Benoit rejoint ses notifications et démarre son module d'apprentissage. Il devient alors actif (status 2) et une actualité est générée.")
      benoit.rejoint_ses_notifications
      click_on('Démarrer le module “Personnages”')

      benoit.reset

      # --- Vérifications ---
      expect(benoit).to be_actif
      expect(benoit.option(16)).to eq(2)
      expect(benoit.icmodule_id).not_to eq(nil)
      expect(TActualites).to have_actualite(user_id:benoit.id, after:start_time, id:DATA_WATCHERS[:start_module][:actu_id]),
        "Une actualité devrait informer du démarrage du module".freeze
      pitch("Une actualité informe du démarrage de module".freeze)
      expect(benoit).to have_watcher(wtype:'paiement_module', after:start_time),
        "Benoit devrait avoir un watcher de paiement de module.".freeze
      pitch('Benoit possède maintenant un watcher de paiement'.freeze)
      expect(benoit).to have_etape(numero:1, after:start_time),
        "Benoit devrait avoir une étape de travail courante".freeze
      pitch('Une étape de travail a été créée pour Benoit'.freeze)
      expect(phil).to have_mail(subject:DATA_WATCHERS[:start_module][:titre], after:start_time),
        "J'aurais dû recevoir un mail d'avertissement de démarrage de module.".freeze
      pitch("Phil a été averti par mail du démarrage de module".freeze)

      click_on('Bureau')
      click_on('Travail courant')
      expect(page).to have_css('h1', text: '1. Introduction au module Personnage'),
        "Benoit devrait trouver son travail sur son bureau".freeze
      expect(page).to have_link(UI_TEXTS[:btn_remettre_travail]),
        "Benoit devrait avoir un bouton pour remettre son travail".freeze
      pitch("Benoit trouve son travail sur son bureau et un bouton pour remettre ses documents")
      click_on(UI_TEXTS[:btn_remettre_travail])
      expect(page).to have_titre('Envoi des documents de travail')
      expect(page).to have_button('Choisir le document 1…')
      pitch("Benoit trouve un formulaire pour envoyer ses documents, tout va bien.")
    end

  end #/icarien inactif

end
