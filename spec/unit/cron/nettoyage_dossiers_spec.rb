# encoding: UTF-8
# frozen_string_literal: true
describe 'Le nettoyage des dossiers' do

  def folder_forms_count
    Dir["./tmp/forms/*"].count
  end #/ folder_forms_count

  before(:all) do
    require_support('cronjob')
    @test_time = "2020/10/30/1/7"
    @test_real_time = realtime(@test_time)
    # *** Dossier des tokens de formulaires ***
    @folder_tmp_forms = File.expand_path(File.join('.','tmp','forms'))
    now = Time.now.to_i
    30.times do |i|
      fpath = File.join(@folder_tmp_forms, (now+=1).to_s)
      File.open(fpath,'wb'){|f| f.write("#{Time.now}")}
      if i > 20
        FileUtils.touch(fpath, :mtime => @test_real_time - rand(4..10).days)
      end
    end
    @init_forms_count = folder_forms_count.freeze
  end
  context 'à l’heure voulue' do
    before(:all) do
      res = run_cronjob(time:@test_time)
    end
    it 'nettoie les tokens de formulaires' do
      expect(folder_forms_count).to eq(@init_forms_count - 9)
      expect(cron_report(@test_time)).to include "= Nombre tokens de formulaire détruits : 9/30"
    end
    it 'nettoie le dossier des downloads' do

    end
    it 'nettoie le dossier des inscriptions' do

    end
  end

  context 'à une autre heure' do
    it 'ne se nettoient pas' do

    end
  end
end
