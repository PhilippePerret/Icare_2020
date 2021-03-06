# encoding: UTF-8
# frozen_string_literal: true
describe 'Le nettoyage des dossiers' do

  def folder_forms_count
    Dir["./tmp/forms/*"].count
  end #/ folder_forms_count
  # OUT   Nombre d'éléments dans le dossier des downloads
  def nombre_downloads
    Dir["./tmp/downloads/*"].count
  end #/ nombre_downloads
  # OUT   Nombre d'éléments dans le dossier des signups
  def nombre_signups
    Dir["./tmp/signups/*"].count
  end #/ nombre_signups

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

    # *** Dossier des downloads ***
    @folder_tmp_downloads = File.expand_path(File.join('.','tmp','downloads'))
    pathfile1 = File.expand_path('./spec/support/asset/documents/doc_travail_final.odt')
    pathfile2 = File.expand_path('./spec/support/asset/documents/extrait.html')
    destfile1 = File.join(@folder_tmp_downloads, 'doczip.zip')
    destfile2 = File.join(@folder_tmp_downloads, 'download-12345678.zip')
    destfile3 = File.join(@folder_tmp_downloads, 'IBAN-12345678.zip')
    FileUtils.copy(pathfile1,destfile1)
    FileUtils.copy(pathfile2,destfile2)
    FileUtils.copy(pathfile2,destfile3)
    FileUtils.touch(destfile1, :mtime => @test_real_time - rand(32..60).days)
    FileUtils.touch(destfile2, :mtime => @test_real_time - rand(32..60).days)
    folder1 = File.join(@folder_tmp_downloads, 'sent-comments')
    folder2 = File.join(@folder_tmp_downloads, 'sent-works')
    FileUtils.mkdir(folder1)
    FileUtils.mkdir(folder2)
    dest2file1 = File.join(folder1, 'doczip.zip') # aujourd'hui
    dest2file2 = File.join(folder2, 'download-12345678.zip') # vieux
    FileUtils.copy(pathfile1,dest2file1)
    FileUtils.copy(pathfile2,dest2file2)
    datefile2 = @test_real_time - rand(32..60).days
    FileUtils.touch(dest2file2, :mtime => datefile2)
    FileUtils.touch(folder2, :mtime => datefile2)

    # *** Pour le dossier des signups ***
    Dir["./spec/support/asset/dossiers/signups/*"].each do |fpath|
      FileUtils.cp_r(fpath, "./tmp/signups/")
    end
    @nombre_signups_init = nombre_signups.freeze
    elements = Dir["./tmp/signups/*"]
    FileUtils.touch(elements[0], :mtime => @test_real_time - rand(62..100).days)
    FileUtils.touch(elements[3], :mtime => @test_real_time - rand(62..100).days)

  end

  context 'à l’heure voulue' do
    before(:all) do
      @nombre_downloads_init = nombre_downloads.freeze
      res = run_cronjob(time:@test_time)
    end
    it 'nettoie les tokens de formulaires' do
      expect(folder_forms_count).to eq(@init_forms_count - 9)
      expect(cron_report(@test_time)).to include "= Nombre tokens de formulaire détruits : 9/30"
    end
    it 'nettoie le dossier des downloads' do
      expect(nombre_downloads).to eq(@nombre_downloads_init - 3)
      expect(cron_report(@test_time)).to include "= Nombre éléments downloads détruits : 3/5"
    end

    it 'nettoie le dossier des inscriptions' do
      expect(nombre_signups).to eq(@nombre_signups_init - 2)
      expect(cron_report(@test_time)).to include "= Nombre dossiers inscription détruits : 2/5"
    end
  end

  context 'à une autre heure' do
    it 'ne se nettoient pas' do

    end
  end
end
