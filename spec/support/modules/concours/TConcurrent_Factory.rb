# encoding: UTF-8
# frozen_string_literal: true
class TConcurrent
class Factory
class << self

  # Pour créer un concurrent avec les options +options+
  # +options+   Hash (obligatoire)
  #   :current            true (default) /false  Pour faire un concurrent du concours actuel
  #   :evaluations        true (default) /false  Si true, il faut lui faire des évaluations
  #                       mais seulement s'il a un fichier conforme.
  #   :non_conforme       true / false (default)
  #   :no_dossier         true / false (default) Si true, pas de dossier déposé
  #                       par le concurrent.
  #
  # RETURN L'instance TConcurrent créée
  def create(options)
    annee = options[:current] ? TConcours.current.annee : TConcours.current.annee - (1 + rand(5))
    data = random_concurrent_data(options)
    db_compose_insert('concours_concurrents', data)
    conc_id = data[:concurrent_id]
    conc  = TConcurrent.new(data.merge(id: conc_id))
    data_participation = random_concours_data(options.merge!(annee: annee, concurrent_id: conc_id))
    part_id = db_compose_insert(DBTBL_CONCURS_PER_CONCOURS, data_participation)
    if not(options[:no_dossier])
      conc.make_fichier_conforme(annee, conforme = !options[:non_conforme])
    end
    if options[:evaluations]
      # On doit lui faire des évaluations
      build_evaluations_for(conc, annee)
    end
    return conc
  end #/ create

  # Retourne des données arbitraire pour créer un nouveau concurrent
  def random_concurrent_data(options = nil)
    options ||= {}
    options[:options] ||= begin
      opts = [
        1, # réception des informations hebdomadaires
        1, # fiche de lecture
        0,0,0,0,0,0]
      opts.join('')
    end
    histime = Time.now - (rand(10000) + rand(10000))
    now = histime.to_i
    {
      patronyme: "Patro #{now}",
      mail: "patro_#{now}@chez.lui",
      sexe: ['F','M'][rand(2)],
      concurrent_id: histime.strftime("%Y%m%d%H%M%S"),
      options: options[:options],
      session_id: 'abdcde2fdq1fd2fdq',
      created_at: now,
      updated_at: now
    }
  end #/ random_data

  # Retourne des données aléatoires pour une participation à un concours
  # +params+ doit au moins contenir :concurrent_id
  def random_concours_data(params)
    params[:specs] ||= begin
      specs = [1,1,0,0,0,0,0,0] # par défaut un fichier déposé conforme
      params[:non_conforme] && specs[1] == 2
      params[:no_dossier] && specs[0..1] == [0,0]
      specs.join('')
    end
    params[:annee] ||= (Time.now.year - rand(5))
    now = Time.new(params[:annee], 1 + rand(12), 1 + rand(25), rand(24), rand(60), rand(60))
    {
      annee: params[:annee],
      concurrent_id: params[:concurrent_id],
      titre: params[:titre] || '',
      auteurs: params[:auteurs] || nil,
      keywords: params[:keywords] || nil,
      prix: params[:prix] || nil,
      pre_note: params[:pre_note] || nil,
      fin_note: params[:fin_note] || nil,
      specs: params[:specs] || '00000000',
      created_at: now.to_s,
      updated_at: now.to_s
    }
  end #/ random_concours_data

  # = Pour fabriquer un ancien concurrent =
  #
  # Retourne le concurrent créé
  def create_ancien
    annee = Time.now.year - 1
    data = random_concurrent_data
    db_compose_insert('concours_concurrents', data)
    conc_id = data[:concurrent_id]
    conc  = TConcurrent.new(data.merge(id: conc_id))
    data_participation = random_concours_data(annee: annee, concurrent_id: conc_id)
    part_id = db_compose_insert(DBTBL_CONCURS_PER_CONCOURS, data_participation)
    conc.make_fichier_conforme(annee, conforme = true)
    return conc
  end #/ create_ancien

  # Construction d'évaluations pour le concurrent +concurrent+ (instance TConcurrent)
  # pour l'année +annee+
  #
  # Synopsis :
  #   - On prend les questions
  #   - On prend les jurés
  #   - On fait un score par jurés et on l'enregistre
  def build_evaluations_for(concurrent, annee)
    concurrent_id = concurrent.concurrent_id
    dossier_id    = "#{concurrent_id}-#{annee}"
    data_questions = YAML.load_file('./_lib/_pages_/concours/xmodules/calculs/data_evaluation.yaml')
    TEvaluator.data_jures.each do |djure|
      score_name = "evaluation-#{djure[:jury] == 1 ? 'pres' : 'prix'}-#{djure[:id]}.json"
      score_path = File.join('.','_lib','data','concours',concurrent_id, dossier_id, score_name)
      mkdir(File.dirname(score_path))
      score = {}
      data_questions.each do |dquest|
        score = traite_question(dquest, scrore)
      end
      File.open(score_path, 'wb'){|f| f.write(score.to_json)}
    end
  end #/ build_evaluations_for
  def traite_question(dquest, score)
    valeur = rand(7)
    valeur = 'x' if valeur > 5
    score.merge!(dquest[:id] => valeur)
    (dquest[:items]||[]).each do |dsquest|
      score = traite_question(dsquest, score)
    end
    return score
  end #/ traite_question
end #/<< self
end #/ Factory
end #/ TConcurrent
