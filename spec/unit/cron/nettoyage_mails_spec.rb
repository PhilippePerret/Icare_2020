# encoding: UTF-8
# frozen_string_literal: true
require_support('cronjob')

describe 'CRON:Nettoyage des mails' do

  it 'le job nettoie les mails et enregistre le résultat' do
    # = Préparation =
    folder_mails = File.expand_path(File.join('.','tmp','mails'))
    test_time = "2020/10/24/1/23"
    text_real_time = realtime(test_time)
    # Un mail récent
    path_mail_recent = File.join(folder_mails,'mail-recent.html')
    File.open(path_mail_recent,'wb'){|f|f.write("C'est un mail récent")}
    path_autre_recent = File.join(folder_mails,'autre-recent.html')
    File.open(path_autre_recent,'wb'){|f|f.write("C'est un autre mail récent")}
    path_mail_ancien = File.join(folder_mails,'mail-ancien.html')
    File.open(path_mail_ancien,'wb'){|f|f.write("C'est un mail ancien")}
    FileUtils.touch(path_mail_ancien, :mtime => text_real_time - 20.days)
    path_mail_tres_ancien = File.join(folder_mails,'mail-tres-ancien.html')
    File.open(path_mail_tres_ancien,'wb'){|f|f.write("C'est un mail très ancien")}
    FileUtils.touch(path_mail_tres_ancien, :mtime => text_real_time - 40.days)


    # = On test =
    remove_main_log
    cur_report_path = remove_report(test_time)
    res = run_cronjob(time:test_time)
    puts res
    # = On vérifie =
    code = read_main_log
    expect(code).not_to include("JOB [nettoyage_mails] NOT TIME"),
      "Le job de nettoyage des mails aurait dû être joué"

    expect(File).to be_exists(path_mail_recent),
      "Le fichier récent n'aurait pas dû être touché"
    expect(File).to be_exists(path_autre_recent),
      "L'autre fichier récent n'aurait pas dû être touché"
    expect(File).not_to be_exists(path_mail_ancien),
      "Le fichier mail ancien aurait dû être détruit"
    expect(File).not_to be_exists(path_mail_tres_ancien),
      "Le fichier mail très ancien aurait dû être détruit"

    code_report = File.read(cur_report_path)
    expect(code_report).to include "Nombre mails détruits : 2"
  end

end
