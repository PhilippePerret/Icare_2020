# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test de la commande CLI 'load' (icare load…)
=end
require_relative '../xrequired'

describe 'Commande CLI load' do
  it 'répond' do
    res = cli("load")
    expect(res).to include("tout est ok")
  end
end
