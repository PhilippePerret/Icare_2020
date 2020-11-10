# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module qui teste la pertinence des calculs du module de calcul du
  concours de synopsis (qui se doit d'être absolument intraitable)
=end
RESKEYS = [:note, :note_abs, :pourcentage, :nb_questions, :nb_reponses, :nb_missings]
KD2KH = {note: :note_generale, note_abs: :note_absolue, pourcentage: :pourcentage_reponses,
nb_questions: :nombre_questions, nb_reponses: :nombre_reponses, nb_missings: :nombre_missings}

shared_examples_for "un bon résultat" do |yfile|

  let(:alldata) { @alldata  ||= YAML.load_file(File.join(__dir__,'data',"#{yfile}.yaml")) }
  let(:reftest) { @reftest  ||= "File: #{yfile}\nDescription: #{alldata[:context][:description]}\nDeepness: #{alldata[:context][:deepness]}\nAbsolute question count: #{alldata[:context][:nombre_questions]}" }
  # describe description do
    it "produit une structure de valeurs correctes (#{yfile})" do
      alldata[:cases].each do |data|
        score   = data[:score]
        attente = data[:attente]
        fails   = data[:fails]
        ConcoursCalcul.nombre_absolu_questions = data[:nombre_questions]
        result  = ConcoursCalcul.note_generale_et_pourcentage_from(score, true)

        # if attente.key?(:note_max)
        #   notemax, imax = traite_val_note(attente[:note_max])
        #   coef = 200.0 / notemax
        #   puts "notemax: #{notemax.inspect} #{imax}\nCoefficiant: #{coef}\nNote max * coefficiant = #{notemax * coef}"
        # end

        RESKEYS.each do |k|
          val, init_val = traite_val_note(attente[k], (data[:coef200] if k.to_s.start_with?('note')))
          expect(result.send(k)).to eq(val),
            "devrait produire une STRUCTure de valeurs correctes #{fails}.\nClé défectueuse et valeurs\n\t\t#{k.inspect}\n\t\tAttendu: #{val.inspect}#{init_val}\n\t\tObtenu: #{result.send(k).inspect}\n#{reftest}\nFailure: #{data[:fails]}"
        end
      end
    end
    it 'produit un Hash de valeurs correctes' do
      alldata[:cases].each do |data|
        score   = data[:score]
        attente = data[:attente]
        fails   = data[:fails]
        ConcoursCalcul.nombre_absolu_questions = data[:nombre_questions]
        reshash = ConcoursCalcul.note_generale_et_pourcentage_from(score, false)
        KD2KH.each do |ka, kh|
          val, init_val = traite_val_note(attente[ka], (data[:coef200] if ka.to_s.start_with?('note')))
          expect(reshash[kh]).to eq(val),
            "devrait produire un Hash de valeurs correctes #{fails}.\nClé défectueuse et valeurs\n\t\t#{kh.inspect}\n\t\tAttendu: #{val.inspect}#{init_val}\n\t\tObtenu: #{reshash[kh].inspect}\n#{reftest}\nFailure: #{data[:fails]}"
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

describe 'Le module de calcul du concours de synopsis (class ConcoursCalcul)' do
  before(:all) do
    require './_lib/_pages_/concours/xmodules/evaluation/module_calculs'
    NOMBRE_QUESTIONS = File.read(NOMBRE_QUESTIONS_PATH).to_i
  end

  context 'avec as_struct à true' do
    it 'retourne une structure avec les bonnes méthodes-propriétés' do
      res = ConcoursCalcul.note_generale_et_pourcentage_from({}, as_struct = true)
      expect(res).to be_a(ResScore)
      expect(res).to respond_to(:note)
      expect(res).to respond_to(:note_abs)
      expect(res).to respond_to(:pourcentage)
      expect(res).to respond_to(:nb_questions)
      expect(res).to respond_to(:nb_reponses)
      expect(res).to respond_to(:nb_missings)
    end
  end #/context score vide
  context 'avec as_struct à false' do
    it 'retourne une table Hash avec les bonnes clés' do
      res = ConcoursCalcul.note_generale_et_pourcentage_from({}, as_struct = false)
      expect(res).to be_a(Hash)
      expect(res).to have_key(:note_generale)
      expect(res).to have_key(:note_absolue)
      expect(res).to have_key(:pourcentage_reponses)
      expect(res).to have_key(:nombre_questions)
      expect(res).to have_key(:nombre_reponses)
      expect(res).to have_key(:nombre_missings)
    end
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

end
