# encoding: UTF-8
# frozen_string_literal: true
class TConcurrent
class << self

  def reset
    @allconcurrents = nil
  end #/ reset

  # Retourne une instance TConcurrent choisie au hasard
  def get_random
    all[rand(all.count)]
  end #/ get_a_concurrent

  def all
    @allconcurrents ||= begin
      db_exec("SELECT * FROM #{DBTBL_CONCURRENTS}").collect { |dc| new(dc) }
    end
  end #/ all

  # OUT   Liste ARRAY de tous les concurrents du concours courant
  def all_current
    @all_current ||= begin
      db_exec(REQUEST_CONCURRENTS_COURANTS, [Concours.current.annee]).collect{|dc|new(dc)}
    end
  end #/ all_current

  # Pour inscrire un {TUser} qui est un icarien
  # Noter que cette inscription se fera toujours sur un concours précédent,
  # jamais sur le concours présent.
  #
  # IN    +u+ {User} à inscrire
  #       +options+   {Hash} d'options, donc :
  #         :session_courante   Si true, on l'inscrit à la session courante
  #                             Sinon, non.
  def inscrire_icarien(u, options)
    data_cc = {
      patronyme: u.patronyme||u.pseudo,
      mail: u.mail,
      sexe: u.ini_sexe, # u.sexe = "une femme" ou "un homme" pour le moment…
      session_id: "1"*32,
      concurrent_id: new_concurrent_id,
      options: "11100000" # 3e bit à 1 => icarien
    }
    db_compose_insert(DBTBL_CONCURRENTS, data_cc)
    if options && false === options[:session_courante]
      # Note : il faut forcément une participation à un concours, donc on prend
      # un des concours précédent
      dco = db_exec("SELECT annee FROM concours WHERE annee < ? LIMIT 1", Time.now.year).first
      dco || raise("Pour inscrire un concurrent, il faut au moins un concours précédent")
      data_cpc = {concurrent_id:data_cc[:concurrent_id], annee:dco[:annee], specs:"00000000"}
    elsif options && options[:session_courante]
      data_cpc = {concurrent_id:data_cc[:concurrent_id], annee:ANNEE_CONCOURS_COURANTE, specs:"00000000"}
    end
    db_compose_insert(DBTBL_CONCURS_PER_CONCOURS, data_cpc)
  end #/ inscrire

  def new_concurrent_id
    now = Time.now
    concid = "#{now.strftime("%Y%m%d%H%M%S")}"
    while db_count(DBTBL_CONCURRENTS, {concurrent_id: concid}) > 1
      now += 1
      concid = "#{now.strftime("%Y%m%d%H%M%S")}"
    end
    return concid
  end #/ new_concurrent_id

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :patronyme, :mail, :concurrent_id, :options, :created_at, :updated_at
def initialize(data)
  data.each{|k,v|instance_variable_set("@#{k}",v)}
end #/ initialize

alias :pseudo :patronyme
alias :id :concurrent_id

def folder
  @folder ||= File.join(CONCOURS_DATA_FOLDER, self.id)
end #/ folder

REQUEST_CONCURRENTS_COURANTS = <<-SQL
SELECT
  cc.*, cpc.titre, cpc.auteurs, cpc.keywords, cpc.specs, cpc.prix
  FROM concours_concurrents cc
  INNER JOIN concurrents_per_concours cpc ON cc.concurrent_id = cpc.concurrent_id
  WHERE cpc.annee = ?
SQL
end #/TConcurrent
