# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module de test de la section concours, partie inscription
=end
feature "Section d'inscription de la partie concours" do



  scenario "Une page conforme permet de s'inscrire au concours" do
    implementer(__FILE__,__LINE__)
  end





  context 'un visiteur déjà inscrit' do
    scenario 'ne peut pas se réinscrire au concours' do
      implementer(__FILE__,__LINE__)
    end
  end





  context 'un icarien identifié' do
    scenario 'peut s’inscrire très facilement au concours' do
      implementer(__FILE__,__LINE__)
    end
  end




end
