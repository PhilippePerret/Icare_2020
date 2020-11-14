# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module qui teste la pertinence des calculs du module de calcul du
  concours de synopsis (qui se doit d'être absolument intraitable)
=end
require_relative './calculs_tests_methods'

# RESKEYS = [:note, :note_abs, :pourcentage, :nb_questions, :nb_reponses, :nb_missings]
KD2KH = {note: :note, note_abs: :note_abs, pourcentage: :pourcentage,
nb_questions: :nombre_questions, nb_reponses: :nombre_reponses, nb_missings: :nombre_missings}

shared_examples_for "un bon résultat" do |yfile|

  let(:alldata) { @alldata  ||= YAML.load_file(File.join(__dir__,'data',"#{yfile}.yaml")) }
  let(:reftest) { @reftest  ||= "File: #{yfile}\nDescription: #{alldata[:context][:description]}\nDeepness: #{alldata[:context][:deepness]}\nAbsolute question count: #{alldata[:context][:nombre_questions]}" }
  it {
    alldata[:cases].each do |data|
      score   = data[:score]
      attente = data[:attente]
      fails   = data[:fails]
      Evaluation.NOMBRE_ABSOLU_QUESTIONS = data[:nombre_questions]
      # Evaluation.nombre_absolu_questions = data[:nombre_questions]
      e = Evaluation.new
      e.parse_and_calc(score)
      KD2KH.each do |ka, kh|
        val, init_val = traite_val_note(attente[ka], (data[:coef200] if ka.to_s.start_with?('note')))
        expect(e.send(kh)).to eq(val),
          "devrait produire un Hash de valeurs correctes #{fails}.\nClé défectueuse et valeurs\n\t\t#{kh.inspect}\n\t\tAttendu: #{val.inspect}#{init_val}\n\t\tObtenu: #{e.send(kh).inspect}\n#{reftest}\nFailure: #{data[:fails]}"
      end
    end
  }
end

describe 'CONCOURS. Le module de calcul (class Evaluation)' do

  before(:all) do
    require './_lib/_pages_/concours/xmodules/synopsis/Evaluation'
    NOMBRE_QUESTIONS = File.read(NOMBRE_QUESTIONS_PATH).to_i
  end

  before(:each) do
    Evaluation.NOMBRE_ABSOLU_QUESTIONS = nil
  end

  it 'répond aux bonnes méthodes/propriétés' do
    e = Evaluation.new()
    expect(e).to respond_to(:parse_scores)
    expect(e).to respond_to(:parse_score)
    expect(e).to respond_to(:parse)
    res = e.parse({})
    expect(res).to be_a(Evaluation) # pour le chainage
    expect(e).to respond_to(:note)
    expect(e).to respond_to(:note_abs)
    expect(e).to respond_to(:pourcentage)
    expect(e).to respond_to(:nombre_questions)
    expect(e).to respond_to(:nombre_reponses)
    expect(e).to respond_to(:nombre_missings)
  end

  # Évaluation avec des scores vides
  teste_concours_calculs_scores('no_score.yaml')

  # Tests avec des valeurs simples
  teste_concours_calculs_scores('same_questions_count.yaml')

  # Calculs complets avec plusieurs scores
  teste_concours_calculs_scores('plusieurs_scores.yaml')

  # Avec des nombres divergents entre le nombre de questions absolues
  # et le nombre de réponses, comme si les questions avaient été modifiées
  # après les évaluations, par exemple d'un concours à l'autre.
  teste_concours_calculs_scores('diff_questions_count.yaml')

  # Avec des questions en profondeur
  teste_concours_calculs_scores('with_deepness_1.yaml')

  # Avec des questions en profondeur (profondeur de 2)
  teste_concours_calculs_scores('with_deepness_2.yaml')


  describe 'La propriété :owners' do
    it 'contient les bons résultats en profondeur' do
      score = {"po-cohe":0, "po-p-adth-cohe":5}
      e = Evaluation.new
      e.parse_and_calc(score)
      own = e.owners
      r = own['cohe']
      # puts "own['cohe']: #{r}"
      tot = 3.5 # ;tot = 0*5*0.9 + 1*5*0.7
      totm = 8.0 # ; totm = 1*5*0.9 + 1*5*0.7
      ratio = tot / totm
      note20 = 8.8 # ; note20 = (20.0 * ratio).round(1)
      # puts "tot:#{tot} / totm:#{totm} / note20: #{note20}"
      expect(r[:total]).to eq(tot)
      expect(r[:totmax]).to eq(totm)
      expect(r[:note]).not_to eq 20.0
      expect(r[:note]).to eq(note20)
    end
    it 'contient ce qu’on attend' do
      score = {"po":5, "po-cohe":5, "po-adth":5, "po-cohe-adth":5}
      e = Evaluation.new
      e.parse_and_calc(score)
      own = e.owners
      expect(own).not_to eq(nil)
      expect(own).to be_a(Hash)
      expect(own).to have_key("po")
      expect(own).to have_key("cohe")
      expect(own).to have_key("adth")
      expect(own['cohe'][:total]).to eq(8.5)
      expect(own['cohe'][:note]).to eq 20.0
      expect(own['adth'][:total]).to eq(1*5*0.9 + 1*5*0.8)
      expect(own['adth'][:note]).to eq 20.0
    end
  end
end
