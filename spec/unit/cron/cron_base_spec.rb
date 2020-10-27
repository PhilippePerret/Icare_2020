# frozen_string_literal: true

require_support('cronjob')

describe 'Le runner du cronjob' do
  it 'se lance sans erreur' do
    expect{run_cronjob}.not_to raise_error
  end

  it 'prend l’heure qu’on lui fourni pour les tests' do
    res = run_cronjob(time: "2000/10/02/4/26", noop:true)
    expect(res).to include("CRON-CURRENT-TIME: 02 10 2000 - 04:26")
  end
  it 'se met en mode simulation avec l’option NOOP = true' do
    res = run_cronjob(noop:true)
    expect(res).to include("CRON-NOOP: true (SIMULATION)")
  end

  it 'joue tous les jobs' do
    remove_main_log
    res = run_cronjob(noop:true)
    # On lit le journal
    code = File.read(MAIN_LOG_PATH)
    # On doit trouver une mention de chaque job dans l'historique
    Dir["#{CRONJOB_FOLDER}/_lib/JOBS/*.rb"].each do |jpath|
      jname = File.basename(jpath,File.extname(jpath))
      expect(code).to include jname
    end
  end

  it 'le nettoyage des mails se font seulement le samedi, à 1 heure' do
    remove_main_log
    res = run_cronjob(noop:true, time:"2020/10/24/1/12")
    code = File.read(MAIN_LOG_PATH)
    expect(code).to include "RUN JOB [nettoyage_mails]"
    expect(code).not_to include "RUN JOB [nettoyage_dossiers]"
  end

  it 'le nettoyage des dossiers se fait seulement le samedi, à 2 heures' do
    remove_main_log
    res = run_cronjob(noop:true, time:"2020/10/24/2/0")
    code = File.read(MAIN_LOG_PATH)
    expect(code).to include "RUN JOB [nettoyage_dossiers]"
    expect(code).not_to include "RUN JOB [nettoyage_mails]"
  end

  it 'l’envoi des actualités se fait tous les jours, à 3 heures' do
    [
      "2020/10/24/3/0",
      "2020/10/10/3/10",
      "2020/10/9/3/23",
    ].each do |time|
      remove_main_log
      res = run_cronjob(noop:true, time:time)
      code = File.read(MAIN_LOG_PATH)
      expect(code).to include "RUN JOB [send_actualites]"
      expect(code).not_to include "RUN JOB [nettoyage_dossiers]"
      expect(code).not_to include "RUN JOB [nettoyage_mails]"
    end
    [
      "2020/10/24/1/0",
      "2020/10/10/2/10",
      "2020/10/9/4/0",
    ].each do |time|
      remove_main_log
      res = run_cronjob(noop:true, time:time)
      code = File.read(MAIN_LOG_PATH)
      expect(code).not_to include "RUN JOB [send_actualites]"
    end

  end
end
