# encoding: UTF-8
=begin
  Test de l'ajout d'une actualité
=end
feature "Operation Arrêt d'un module d'apprentissage (forcé ou non)" do
  before(:all) do
    require './_lib/pages/admin/tools/constants'
  end

  context 'Un visiteur quelconque' do
    scenario 'ne peut pas ajouter stopper de force un module d’apprentissage' do
      goto('admin/tools')
      expect(page).not_to have_titre('Outils')
      expect(page).to have_titre('Identification')
    end
  end


  context 'Un administrateur' do
    before(:all) do
      degel('define_sharing')
    end
    scenario 'ne peut pas stopper un module d’apprentissage déjà arrêté' do
      pending
    end
    scenario 'peut stopper un module d’apprentissage', only:true do
      # --- Vérications préliminaires ---
      expect(marion).to be_actif
      expect(marion.icmodule_id).not_to eq(nil)
      icmodule_id = marion.icmodule_id.dup # pour le récupérer plus tard
      dmodule = db_get('icmodules', icmodule_id)
      expect(dmodule[:ended_at]).to eq(nil)
      expect(dmodule[:icetape_id]).not_to eq(nil)
      expect(TWatchers).to have_watcher(wtype:'paiement_module', objet_id: icmodule_id, user:marion)

      pitch("Phil rejoint le site et procède à l'arrêt du module de Marion. Le module est arrêté correctement et Marion n'est plus active.".freeze)
      phil.rejoint_le_site # pour ne pas charger le bureau avec toutes ses images
      goto('admin/tools')
      expect(page).to have_titre('Outils')
      start_time = Time.now # c'est parti
      # On choisit l'icarien (statut puis icarien)
      phil.click('cb-statut-actif', within: '#div-statuts')
      select('Marion', from: 'icariens')
      select('Arrêt module', from: 'operations')
      expect(page).to have_css('textarea#long_value')
      msg = 'J’espère te retrouver bientôt à l’atelier'.freeze
      within('div#div-fields') do
        fill_in('long_value', with: msg)
        click_on(UI_TEXTS[:btn_execute_operation])
      end
      expect(page).to have_aucune_erreur()
      expect(page).to have_message('le module de Marion a été correctement arrêté')

      # --- Vérifications ---
      marion.reset
      # Un mail a été envoyé à Marion pour l'informer
      expect(marion).to have_mail(subject:'Fin du module d’apprentissage', after: start_time)
      # Marion n'a plus de module_id
      expect(marion.icmodule_id).to eq(nil)
      expect(marion.icmodule).to eq(nil)
      expect(marion).to be_inactif
      # Le module est marqué terminé
      dmodule = db_get('icmodules', icmodule_id)
      expect(dmodule[:ended_at]).not_to eq(nil)
      expect(dmodule[:ended_at]).to be > start_time.to_i
      expect(dmodule[:icetape_id]).to eq(nil)
      # Il n'y a plus de watcher de paiement
      expect(TWatchers).not_to have_watcher(wtype:'paiement_module', objet_id: icmodule_id, user:marion)
      # Une actualité a été produit
      expect(TActualites).to have_actualite(after: start_time, id:'ENDMODULE'.freeze)
    end
  end
end
