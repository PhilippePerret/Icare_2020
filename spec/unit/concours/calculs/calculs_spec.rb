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
    it 'produit une instance avec des valeurs correctes' do
      alldata[:cases].each do |data|
        score   = data[:score]
        attente = data[:attente]
        fails   = data[:fails]
        NOMBRE_ABSOLU_QUESTIONS = data[:nombre_questions]
        # Evaluation.nombre_absolu_questions = data[:nombre_questions]
        e = Evaluation.new
        e.parse(score)
        KD2KH.each do |ka, kh|
          val, init_val = traite_val_note(attente[ka], (data[:coef200] if ka.to_s.start_with?('note')))
          expect(e.send(kh)).to eq(val),
            "devrait produire un Hash de valeurs correctes #{fails}.\nClé défectueuse et valeurs\n\t\t#{kh.inspect}\n\t\tAttendu: #{val.inspect}#{init_val}\n\t\tObtenu: #{e.send(kh).inspect}\n#{reftest}\nFailure: #{data[:fails]}"
        end
      end
    end
  # end
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

describe 'Le module de calcul du concours de synopsis (class Evaluation)' do

  before(:all) do
    require './_lib/_pages_/concours/xmodules/synopsis/Evaluation'
    NOMBRE_QUESTIONS = File.read(NOMBRE_QUESTIONS_PATH).to_i
  end

  it 'répond aux bonnes méthodes/propriétés', only:true do
    e = Evaluation.new()
    expect(e).to respond_to(:parse_scores)
    expect(e).to respond_to(:parse_score)
    expect(e).to respond_to(:parse)
    res = e.parse({})
    expect(res).to be_a(Evaluation)
    expect(e).to respond_to(:note)
    expect(e).to respond_to(:note_abs)
    expect(e).to respond_to(:pourcentage)
    expect(e).to respond_to(:nombre_questions)
    expect(e).to respond_to(:nombre_reponses)
    expect(e).to respond_to(:nombre_missings)
  end

  context 'avec un score entièrement vide', only:true do
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

end
