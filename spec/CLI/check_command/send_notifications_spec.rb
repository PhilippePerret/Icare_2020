# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module de test des envois de notification

=end
require_relative '../xrequired'

def read_cron_notifications
  File.read(cron_notifications_path)
end #/ read_cron_notifications
def erase_cron_notifications
  File.delete(cron_notifications_path) if File.exists?(cron_notifications_path)
end #/ erase_cron_notifications
def cron_notifications_path
  @cron_notifications_path ||= File.join('.','cronjob2','_lib','notifications.data')
end #/ cron_notifications_path

describe 'CLI Commande cron (notification)' do
  before(:all) do
    DEL = '___'
  end
  context 'avec les bonnes données en ligne de commande' do
    it 'produit une notification' do
      erase_cron_notifications
      cmd = "cron add 23/12 Anniversaire Marion"
      pitch("Commande cron essayée : #{"icare #{cmd}".inspect}") if VERBOSE
      res = cli(cmd)
      expect(res).not_to include("Date invalide")
      expect(File).to be_exists(cron_notifications_path)
      expect(read_cron_notifications).to include("23/12/2020/00:00#{DEL}Anniversaire Marion")
    end
  end

  context 'avec une date malformée' do
    it 'produit une erreur' do
      [
        ["cron add 23 12 Anni", "La date doit être fournie au format 'JJ MM"],
        ["cron add 32/12 Anni", "Le jour doit être un nombre entre 1 et 31"],
        ["cron add 23/13 Anni", "Le mois doit être un nombre entre 1 et 12"],
        ["cron add 23/12/1/25 Anni", "L'heure doit être un nombre entre 0 et 24."],
        ["cron add 23/12/20/23/60 Anni", "Les minutes doivent être un nombre entre 0 et 59."]
      ].each do |cmd, err_msg|
        pitch("Commande cron essayée : #{"icare #{cmd}".inspect}") if VERBOSE
        res = cli(cmd)
        expect(res).to include "Date invalide"
        expect(res).to include err_msg
      end
    end
  end
end
