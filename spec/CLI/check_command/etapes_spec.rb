# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module de test des checks des étapes d'icarien
  Rappel : le check et les réparations se font toujours ONLINE, sauf
  pour le test où on les fait sur la table icare_test donc les gels sont
  utilisables.
=end
require_relative '../xrequired'

describe 'CLI Commande check' do
  before(:all) do
    degel('benoit_frigote_phil_marion_et_elie')
  end
  describe 'La commande existe et produit un résultat' do
    it 'produit un résultat' do
      res = cli("check users")
      expect(res).to include("Tout est OK")
      expect(res).to include("Tout va bien")
    end

  end
end
