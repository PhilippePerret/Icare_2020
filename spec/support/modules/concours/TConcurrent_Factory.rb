# encoding: UTF-8
# frozen_string_literal: true
class TConcurrent
class Factory
class << self

  # Retourne des données arbitraire pour créer un nouveau concurrent
  def random_concurrent_data
    now = Time.now.to_i
    {
      patronyme: "Patro #{now}",
      mail: "patro_now@chez.lui",
      sexe: ['F','M'][rand(2)],
      concurrent_id: (Time.now - (rand(10000) + rand(10000))).strftime("%Y%m%d%H%M%S"),
      options: "11000000",
      created_at: now,
      updated_at: now
    }
  end #/ random_data

  # Retourne des données aléatoires pour une participation à un concours
  # +params+ doit au moins contenir :concurrent_id
  def random_concours_data(params)
    now = Time.now.to_i
    {
      annee: params[:annee] || (Time.now.year - rand(5)),
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
    conc_id = db_compose_insert('concours_concurrents', data)
    conc  = TConcurrent.new(data.merge(id: conc_id))
    data_participation = random_concours_data(annee: annee, concurrent_id: conc_id)
    part_id = db_compose_insert('concurrents_per_concours', )
    conc.make_fichier_conforme(annee, conforme = true)
    return conc
  end #/ create_ancien

end #/<< self
end #/ Factory
end #/ TConcurrent
