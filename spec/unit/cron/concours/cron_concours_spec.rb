# encoding: UTF-8
# frozen_string_literal: true
=begin
  Essai de tests unitaire sur le cron du concours

  Il y a trois périodes :
  - 1 hors-concours (du 15 juin — date de remise des résultats au 1 oct/nov -
    date d'annonce du nouveau concours)
  - 1 pré-résultats (du 1oct/nov — annonce concours au 1er mars — échéance)
  - 1 résultats (du 1er mars au 15 juin — remise des prix)

=end
describe 'Cronjob du concours' do
  before(:all) do
    require './spec/support/data/concours_data'
    TConcours.reset
    TConcours.peuple
  end

  context 'quand on est hors de la période du concours' do
    it 'le cronjob ne fait rien' do
      implementer(__FILE__,__LINE__)
    end
  end

  context 'quand on est en période de concours' do
    it 'le cronjob fait son travail' do
      implementer(__FILE__,__LINE__)
    end
  end
end
