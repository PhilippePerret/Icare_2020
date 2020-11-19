# encoding: UTF-8
# frozen_string_literal: true
=begin
  Méthodes pour simplifier les calculs
=end
require './_lib/_pages_/concours/xmodules/synopsis/Evaluation'

# Cette méthode teste de deux manières :
#   1) en envoyant directement le score à la méthode :parse
#   2) en instanciant avec le fichier json
# Les deux méthodes doivent produire le même résultat.
# Elle teste sur la base de plusieurs scores.

def teste_concours_calculs_scores(yaml_filename)
  data = YAML.load_file(File.join(__dir__,'data',yaml_filename))
  yaml_name = File.basename(yaml_filename, File.extname(yaml_filename))
  data[:cases].each do |k, data_case|
    traite_calcul_case(data_case.merge(id: k, main_titre: "[#{yaml_name}] #{data[:titre]}"))
  end

end #/ concours_calculs_scores

def traite_calcul_case(data_case)
  # Le coefficiant 200 qui devra être utilisé
  coef200 = data_case[:coef200]
  # On définit le nombre de questions absolu
  Evaluation.NOMBRE_ABSOLU_QUESTIONS = data_case[:nombre_questions]
  # puts "data_case: #{data_case.inspect}"
  # *** 1) En envoyant la table du score ***
  # On crée l'instance évaluation
  # 1.1) En calculant après chaque scrore
  e = Evaluation.new
  data_case[:scores].each_with_index do |data_score, idx|
    e.parse_and_calc(data_score[:values])
    dupe = e.dup # la subtilité pour tester vraiment
    # === Vérifications ===
    check_evaluation_in_with(dupe, data_score[:attentes], "#{data_case[:main_titre]}/CASE:#{data_case[:id].to_s.gsub(/_/,' ')}/score ##{idx}", coef200)
  end

  # return

  # 1.2) En calculant à la fin du traitement des scores
  e = Evaluation.new
  data_case[:scores].each { |dscore| e.parse(dscore[:values]) }
  e.calculate_values
  dupe = e.dup
  # === Vérification ===
  check_evaluation_in_with(dupe, data_case[:scores][-1][:attentes], "#{data_case[:main_titre]}/score:#{data_case[:id]}/dernier score", coef200)

  # *** 2) En instanciant avec le fichier contenant le score ***
  score_paths = []
  data_case[:scores].each_with_index do |dscore, idx|
    path = File.join(__dir__,'data','json', "#{data_case[:id]}-#{idx}.json")
    File.open(path,'wb'){|f|f.write dscore[:values].to_json}
    score_paths << path
  end

  e = Evaluation.new(score_paths)
  # Rappel : quand on instancie avec une liste de chemins, tout le travail de
  # parse et de calcul est lancé automatiquement.
  # === Vérifications ===
  check_evaluation_in_with(e, data_case[:scores][-1][:attentes], "#{data_case[:main_titre]} PAR PATHS/score:#{data_case[:id]}/dernier score", coef200)

end #/ traite_calcul_case

def check_evaluation_in_with(e, attentes, name, coef200)
  # puts "attentes: #{attentes.inspect}"
  describe name.bleu do
    attentes.each do |key, value|
      it "produit la bonne valeur pour #{key.inspect}" do
        if key != :categories
          # Le cas général normal, où on teste seulement une propriété comme
          # :note, ou :nombre_missings
          expected_value = realvalue(key, value, coef200)
          evaluate_value = e.send(key)
          expect(evaluate_value).to eq(expected_value),
            "PROPERTY: #{key.inspect} EXPECTED: #{expected_value.inspect} ACTUAL: #{evaluate_value.inspect}"
        else
          # Le cas où on traite les catégories (appelées aussi :owners). :value
          # est alors une table avec en clé les catégories et en valeur les
          # valeurs que ces catégories doivent avoir dans l'instance +e+
          value.each do |cate, vcate|
            expected_value = realvalue(cate, vcate, coef200)
            evaluate_value = e.send(:owners)[cate][:note]
            expect(evaluate_value).to eq(expected_value),
              "CATEGORIE: #{cate.inspect} EXPECTED: #{expected_value.inspect} ACTUAL: #{evaluate_value.inspect}"
          end
        end
      end
    end
  end
end #/ check_evaluation_in_with

def realvalue(key, value, coef200)
  if value.to_s.start_with?('(')
    c = key.to_s.start_with?('note') ? coef200 : nil
    traite_val_note(value, c)
  else
    value
  end
end #/ realvalue

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
  # return [val, init_val] # avant, pour le message d'erreur
  return val
end
