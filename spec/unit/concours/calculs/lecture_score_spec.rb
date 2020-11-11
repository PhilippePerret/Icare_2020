# encoding: UTF-8
# frozen_string_literal: true
=begin
  Pour tester la lecture d'un score
=end
# Le module de calcul => ConcoursScore.parse
require './_lib/_pages_/concours/xmodules/evaluation/module_calculs'

def ascorepath
  Dir["./_lib/data/concours/**/*.json"].shuffle.first
end #/ ascorepath

describe ConcoursScore do
  before(:all) do
  end
  let(:sujet) { @sujet ||= ConcoursScore.new(ascorepath) }
  it 'répond à la méthode :parse' do
    expect(sujet).to respond_to :parse
  end
  it 'le parsing, à l’instanciation, a permis de définir toutes les valeurs' do
    expect(sujet.note).not_to eq(nil)
    expect(sujet.note_abs).not_to eq(nil)
    expect(sujet.pourcentage).not_to eq(nil)
    expect(sujet.owners).not_to eq(nil)
    expect(sujet.nombre_questions).not_to eq(nil)
    expect(sujet.nombre_reponses).not_to eq(nil)
    expect(sujet.nombre_missings).not_to eq(nil)
  end

  it 'on peut instancier sans chemin d’accès, en fournissant le table du score au parse' do
    expect{sujet = ConcoursScore.new}.not_to raise_error
    sujet.parse({"po" => 5})
    expect(sujet.note).not_to eq(nil)
    expect(sujet.nombre_questions).to eq(1)
    expect(sujet.nombre_reponses).to eq(1)
  end
end
