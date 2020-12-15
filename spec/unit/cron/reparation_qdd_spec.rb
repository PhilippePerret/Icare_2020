# encoding: UTF-8
# frozen_string_literal: true
describe 'Contrôle et réparation des documents QDD' do
  before(:all) do
    require_support('cronjob')
  end

  context 'à l’heure attendue' do
    before(:all) do
      @test_time = "2020/12/15/2/12"
      res = run_cronjob(time: @test_time)
    end
    it 'le cron contrôle la validité des documents QDD' do
      expect(cron_report(@test_time)).to include "= Nombre de document QDD contrôlé : "
    end
  end
end
