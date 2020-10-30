# encoding: UTF-8
# frozen_string_literal: true
describe 'CRONJOB' do
  before(:all) do
    require_support('cronjob')
    require_support('concours')
    degel('concours')
    # Il faut :
    #   - 1 concurrent qui n'a rien envoyé
    #   - 1 concurrent qui a envoyé un fichier pas encore confirmé
    #   - 1 concurrent qui a envoyé un fichier confirmé
    #   - 1 concurrent qui a envoyé un fichier à corriger
    concurrents = TConcurrent.all_current
    expect(concurrents.count).to be >= 4
    req_update = "UPDATE concurrents_per_concours SET specs = ? WHERE concurrent_id = ?"
    list_mods = [
      [0, "00000000"], [1, "10000000"], [2, "11000000"], [3, "12000000"]
    ]
    list_mods.each do |paire|
      idx, specs = paire
      db_exec(req_update, [specs, concurrents[idx].concurrent_id])
    end

  end

  before(:each) do
    TMails.remove_all
    remove_main_log
    remove_all_reports
  end

  # OUT   Retourne le nombre de mails concernant les informations sur le concours
  def nombre_mails_info_concours
    TMails.count(subject_contains:"CONCOURS")
  end #/ nombre_mails_info_concours

  context 'À la bonne heure (11 heures), plus ou moins loin de l’échéance' do

    it 'à un mois, les messages contiennent les bons textes' do
      res = run_cronjob(noop:false, time:"2021/1/30/11/12")
      expect(nombre_mails_info_concours).to be > 4
      # TODO Vérifier l'exactitude du message d'échéance
    end

    it 'à quinze jours, les messages contiennent les bons textes' do
      res = run_cronjob(noop:false, time:"2021/2/13/11/20")
      expect(nombre_mails_info_concours).to be > 4
      # TODO Vérifier l'exactitude du message d'échéance
    end

    it 'à deux jours, les messages contiennent les bons textes' do
      res = run_cronjob(noop:false, time:"2021/2/27/11/20")
      expect(nombre_mails_info_concours).to be > 4
      # TODO Vérifier l'exactitude du message d'échéance
    end


  end #/ contexte : aà la bonne heure en se rapprochant de l'échéance

  context 'À plusieurs heures le samedi' do
    it 'aucun mail n’est envoyé en dehors de 11 heures' do
      # *** Vérification préliminaire ***

      expect(TMails.count).to eq(0)

      # *** Opération ***
      res = run_cronjob(noop:false, time:"2020/10/24/0/20")
      expect(nombre_mails_info_concours).to eq(0)
      res = run_cronjob(noop:false, time:"2020/10/24/1/4")
      expect(nombre_mails_info_concours).to eq(0)
      res = run_cronjob(noop:false, time:"2020/10/24/2/20")
      expect(nombre_mails_info_concours).to eq(0)
      res = run_cronjob(noop:false, time:"2020/10/24/11/20")
      expect(nombre_mails_info_concours).not_to eq(0)
      TMails.remove_all
      res = run_cronjob(noop:false, time:"2020/10/24/4/10")
      expect(nombre_mails_info_concours).to eq(0)
      res = run_cronjob(noop:false, time:"2020/10/24/5/8")
      expect(nombre_mails_info_concours).to eq(0)
    end
  end #/context : une autre heure le samedi

  context 'À 11 heures les autres jours' do
    it 'Aucun mail n’est envoyé' do
      expect(TMails.count).to eq(0)
      res = run_cronjob(noop:false, time:"2020/10/22/11/4")
      expect(nombre_mails_info_concours).to eq(0)
    end
  end# /context: à 3 heures les autres jours


end
