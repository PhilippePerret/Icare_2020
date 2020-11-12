# encoding: UTF-8
# frozen_string_literal: true
=begin
  Pour tester la lecture d'un score
=end
# Le module de calcul => Evaluation.parse
require './_lib/_pages_/concours/xmodules/evaluation/Evaluation'

def nombre_absolu_questions
  File.read(NOMBRE_QUESTIONS_PATH).to_i
end
def ascorepath
  Dir["./_lib/data/concours/**/*.json"].shuffle.first
end
def somepaths_pres
  Dir["./_lib/data/concours/**/evaluation-pres-*.json"].shuffle[0..6]
end
def somepaths_prix
  Dir["./_lib/data/concours/**/evaluation-prix-*.json"].shuffle[0..6]
end

describe Evaluation do
  before(:all) do
  end
  it 'répond à la méthode :parse' do
    sujet = Evaluation.new
    expect(sujet).to respond_to :parse_scores
    expect(sujet).to respond_to :parse_score
    expect(sujet).to respond_to :parse
  end
  it 'le parsing, à l’instanciation, a permis de définir toutes les valeurs' do
    sujet = Evaluation.new(ascorepath)
    expect(sujet.note).not_to eq(nil)
    expect(sujet.note_abs).not_to eq(nil)
    expect(sujet.pourcentage).not_to eq(nil)
    expect(sujet.owners).not_to eq(nil)
    expect(sujet.nombre_questions).not_to eq(nil)
    expect(sujet.nombre_reponses).not_to eq(nil)
    expect(sujet.nombre_missings).not_to eq(nil)
  end

  it 'on peut instancier sans chemin d’accès, en fournissant le table du score au parse' do
    expect{Evaluation.new}.not_to raise_error
    sujet = Evaluation.new
    sujet.parse({"po" => 5}).calc
    expect(sujet.note).not_to eq(nil)
    expect(sujet.nombre_questions).to eq(1)
    expect(sujet.nombre_reponses).to eq(1)
  end

  it 'on peut instancier avec une liste de chemins d’accès' do
    e = nil
    expect{e = Evaluation.new(somepaths_pres)}.not_to raise_error
    expect(e.note).not_to eq(nil)
    expect(e.formated_note).not_to eq(nil)
  end



  describe 'Les catégories' do

    it 'une table mémorise les notes par catégorie' do
      NOMBRE_QUESTIONS_ABSOLU = 1
      e = Evaluation.new
      expect(e.owners).to eq(nil)
      e.parse({"po-cohe" => 5, "po-p-adth" => 5, "po-i-cohe" => 5}).calc
      puts "e.owners: #{e.owners}"
      expect(e.owners).not_to eq(nil)
    end
  end
end
