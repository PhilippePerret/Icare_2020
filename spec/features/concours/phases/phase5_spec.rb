# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test du passage à la phase 3 du concours (donc la phase de lancement)
=end
require_relative './_required'

feature "Phase 4 du concours" do

  BTN_VOIR_PALMARES = "Voir le palmarès actuel"

  # Retourne le nombre de fichiers candidature conformes
  def nombre_fichiers_candidature
    TConcurrent.all_current.select{|c|c.specs[1]=="1"}.count
  end #/ nombre_fichiers_candidature

  before(:all) do
    require './_lib/_pages_/concours/admin/lib/PHASES_DATA'
    expect(defined?(Concours::PHASES_DATA)).not_to be_nil
    PHASES_DATA = Concours::PHASES_DATA
    degel('concours-phase-4')
    # On fait deux concurrents dont un avec un fichier conforme et l'autre
    # sans fichier
    @conc_preselected      = TConcurrent.get_random(preselected: true)
    puts "\n\n@conc_preselected: #{@conc_preselected.inspect}" if VERBOSE
    expect(@conc_preselected).not_to eq(nil)
    @conc_non_selected  = TConcurrent.get_random(preselected: false)
    puts "\n\n@conc_non_selected: #{@conc_non_selected.inspect}" if VERBOSE
    expect(@conc_non_selected).not_to eq(nil)
    @conc_sans_fichier  = TConcurrent.get_random(avec_fichier_conforme: false)
    puts "\n\n@conc_sans_fichier: #{@conc_sans_fichier.inspect}" if VERBOSE
    expect(@conc_sans_fichier).not_to eq(nil)
    # On compte le nombre de synopsis pour cette session
    @nombre_synopsis = nombre_fichiers_candidature.freeze
  end

  before(:each) do
    # Il faut avoir un concours courant en phase 2
    TConcours.current.set_phase(3)
    TConcours.current.reset
  end

  let(:conc_non_selected) { @conc_non_selected }
  let(:conc_preselected) { @conc_preselected }
  let(:conc_sans_fichier) { @conc_sans_fichier }

  context 'Un administrateur' do

    scenario 'peut lancer la phase 5 du concours en se rendant à l’administration' do

    end



    scenario 'peut lancer la phase 5 du concours par route directe' do
      TConcours.current.reset
      expect(TConcours.current.phase).to eq 3
      phil.rejoint_le_site
      goto("concours/admin?op=change_phase&current_phase=5")
      phil.se_deconnecte
      TConcours.current.reset
      expect(TConcours.current.phase).to eq 5
    end

  end #/contexte un administrateur

  context 'Un non administrateur' do
    scenario 'ne peut pas lancer la phase 5 du concours en se rendant à l’administration' do
      goto("concours/admin")
      expect(page).not_to have_titre "Administration du concours"
    end
    scenario 'ne peut pas lancer la phase 5 par route directe' do
      TConcours.current.reset
      expect(TConcours.current.phase).to eq 3
      goto("concours/admin?op=change_phase&current_phase=3")
      TConcours.current.reset
      expect(TConcours.current.phase).not_to eq 5
      expect(TConcours.current.phase).to eq 3
    end

    scenario 'ne peut pas rejoindre la page d’évaluation des synopsis' do
      goto("concours/evaluation")
      expect(page).not_to be_page_evaluation
      expect(page).to have_titre "Identification"
    end
  end #/ contexte : un non administrateur


  context 'Un administrateur' do
    scenario 'peut rejoindre la page d’évaluation' do
      phil.rejoint_le_site
      goto("concours/evaluation")
      expect(page).to be_page_evaluation
    end
  end
end
