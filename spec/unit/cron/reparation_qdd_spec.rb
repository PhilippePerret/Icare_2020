# encoding: UTF-8
# frozen_string_literal: true
describe 'Contrôle et réparation des documents QDD' do
  before(:all) do
    require_support('cronjob')
    degel('real-icare-2020')
  end

  context 'à l’heure attendue' do
    before(:all) do
      @test_time = "2020/12/15/2/12"
      @res = run_cronjob(time: @test_time)
      # puts "@res: #{@res.inspect}"
    end
    it 'le cron contrôle la validité des documents QDD' do
      pitch("Noter que ça ne teste que le fonctionnement général du contrôle. Un test en profondeur pourrait être développé.")
      # code = File.read(MAIN_LOG_PATH)
      # puts "MAIN LOG:\n#{code}"
      expect(cron_report(@test_time)).to include "= Nombre documents QDD checkés : "
    end
  end
end
