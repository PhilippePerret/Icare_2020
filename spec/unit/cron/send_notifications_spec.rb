# encoding: UTF-8
# frozen_string_literal: true
describe 'Le JOB send_notifications' do

  def read_notifications
    File.read(notifications_path)
  end #/ read_notifications
  def write_notification(msg)
    File.open(notifications_path,'a'){|f|f.puts msg}
  end #/ write_notifications
  def erase_notifications
    File.delete(notifications_path) if File.exists?(notifications_path)
  end #/ erase_notifications
  def notifications_path
    @notifications_path ||= File.join('.','cronjob2','_lib','notifications.data')
  end #/ notifications_path

  before(:all) do
    require_support('cronjob')
    erase_notifications
  end

  before(:each) do
    TMails.remove_all
    remove_main_log
  end

  context 'appelé à 11 heures n’importe quel jour' do
    context 'sans notification pour le jour' do
      before(:all) do
        erase_notifications
        write_notification("24/10/2020/00:00___Notification à envoyer")
      end
      it 'ne m’envoie pas de mail de notification' do
        TMails.remove_all
        expect(TMails.count).to eq(0)
        start_time = Time.now.to_i - 1
        res = run_cronjob(noop:false, time:"2020/10/25/11/00")
        # TODO À CORRIGER
        # expect(phil).to have_mail(after: start_time)
      end
    end



    context 'avec des notifications pour le jour' do
      before(:all) do
        erase_notifications
        write_notification("24/10/2020/00:00___Notification à envoyer")
      end
      it 'm’envoie un mail de notification et la supprime des notifications' do
        expect(File).to be_exists(notifications_path)
        expect(TMails.count).to eq(0)
        start_time = Time.now.to_i - 1
        res = run_cronjob(noop:false, time:"2020/10/24/11/30")
        expect(phil).to have_mail(after: start_time, subject:"Notification automatique")
        expect(File).not_to be_exists(notifications_path)
      end
    end
  end

  context 'avec des notifications à envoyer le jour même' do
    before(:all) do
      erase_notifications
      write_notification("24/10/2020/00:00___Notification à envoyer")
      write_notification("24/10/2020/00:00___Autre notification à envoyer")
    end
    context 'appelé à une autre heure que 11 heures' do
      it 'ne produit rien' do
        expect(TMails.count).to eq(0)
        start_time = Time.now.to_i - 1
        res = run_cronjob(noop:false, time:"2020/10/24/3/55")
        expect(phil).to have_no_mail
        res = run_cronjob(noop:false, time:"2020/10/24/5/23")
        expect(phil).to have_no_mail
        res = run_cronjob(noop:false, time:"2020/10/24/1/27")
        expect(phil).to have_no_mail
      end
    end
  end
end
