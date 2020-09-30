# encoding: UTF-8
# frozen_string_literal: true
=begin
  Tests du check des users
=end
require_relative '../xrequired'

describe 'La commande CLI de check des users' do
  before(:all) do
    degel('benoit_frigote_phil_marion_et_elie')
  end

  context 'avec des users valides' do
    it 'ne retourne aucune erreur' do
      res = cli("check users")
      expect(res).to include("Tout est OK")
    end
  end

end
