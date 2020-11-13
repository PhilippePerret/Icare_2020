# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module qui teste la pertinence des calculs du module de calcul du
  concours de synopsis (qui se doit d'être absolument intraitable)
=end
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

# Dans les fichiers YAML, une note peut être fournie par une opération (qui
# doit obligatoirement commencer par une parenthèse)
def traite_val_note(val, coef200 = nil)
  if coef200
    coef200 = 200.0 / eval(coef200)
  end
  init_val = ""
  if val.to_s.start_with?('(')
    init_val = " [#{val.freeze} / coefficiant 200 : #{coef200}]"
    val = eval(val)
    if coef200
      val = (val.to_f * coef200) / 10
    end
    val = val.round(1)
  end
  return [val, init_val]
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

  context 'avec un score entièrement vide' do
    it_behaves_like "un bon résultat", "no_score"
  end
  context 'avec un nombre de questions identique' do
    it_behaves_like "un bon résultat", "same_questions_count"
  end
  context 'avec un nombre de questions différent du score' do
    it_behaves_like "un bon résultat", 'diff_questions_count'
  end

  context 'avec des questions en profondeur' do
    it_behaves_like "un bon résultat", 'with_deepness_1'
  end

  context 'avec des questions d’un profondeur de 2' do
    it_behaves_like "un bon résultat", 'with_deepness_2'
  end

  context 'plusieurs scores' do
    it 'peuvent être additionnés' do
      Evaluation.NOMBRE_ABSOLU_QUESTIONS = 2
      scores = [
        {"po":5, "po-cohe":5},
        {"po":1, "po-cohe":0}
      ]
      e = Evaluation.new
      scores.each do |score|
        e.parse(score)
      end
      e.calculate_values
      # Valeurs générales
      expect(e.nombre_scores).to eq(2)
      expect(e.nombre_reponses).to eq(2.0)
      expect(e.nombre_questions).to eq(2.0)
      # Catégories
      expect(e.owners['cohe'][:note]).to eq(10.0)
    end

    it 'réussi un test complet (plusieurs_scores.yaml)', only:true do
      data = YAML.load_file(File.join(__dir__,'data','plusieurs_scores.yaml'))
      sd = data[:cases][:complete]
      coef200 = sd[:coef200]
      Evaluation.NOMBRE_ABSOLU_QUESTIONS = sd[:nombre_questions]
      e = Evaluation.new
      (0..2).each do |iscore|
        e.parse_and_calc(sd[:scores][iscore])
        expectations = sd[:attentes][iscore]
        expectations.each do |key, expected_value|
          if key.to_s.start_with?('note')
            expected_value, init_val = traite_val_note(expected_value, coef200)
          else
            expected_value = traite_val_note(expected_value).first
          end
          expect(e.send(key)).to eq(expected_value),
            "Après le parse du score #{iscore + 1} La clé #{key.inspect} devrait avoir la bonne valeur…\n\tAttendu : #{expected_value} (#{init_val})\n\tObtenu : #{e.send(key)}"
        end
      end #/fin de boucle sur chaque score
    end
  end

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
