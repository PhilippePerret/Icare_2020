# encoding: UTF-8
# frozen_string_literal: true
class Concours
class << self

  def bind ; binding() end

  # Retourne la liste Array des Concurrents (sous forme de Hash) en appliquant
  # le filtre +filtre+ s'il est défini.
  # Si la commande contient '-s/--simuler', on prend une liste pour essai
  # seulement.
  # +filtre+
  #   last: true    Ne renvoyer que ceux qui ont participé au dernier concours
  def concurrents(filtre = nil)
    where = ""
    request =
      if filtre && filtre[:last]
        REQUEST_LAST_CONCURRENTS
      else
        REQUEST_ALL_CONCURRENTS
      end
    liste =
      if IcareCLI.mode_simulation?
        [
          {patronyme: "Philippe Perret", mail: "phil@atelier-icare.net"},
          {patronyme: "Phil chezMoi", mail: "phil@philippeperret.fr"}
        ]
      else
        require './_lib/required/__first/db'
        MyDB.online = true
        MyDB.DBNAME = "icare_db"
        db_exec(request)
      end
    # On retourne la liste
    return liste
  end #/ concurrents

  # Requête remontant tous les concurrents
  REQUEST_ALL_CONCURRENTS = "SELECT * FROM #{DBTBL_CONCURRENTS}"
  # Requête remontant les concurrents ayant participé
  REQUEST_LAST_CONCURRENTS = <<-SQL
SELECT
    cc.*,
    cpc.specs AS specs, cpc.prix AS prix
  FROM #{DBTBL_CONCURRENTS} cc
  INNER JOIN #{DBTBL_CONCURS_PER_CONCOURS} cpc ON cpc.concurrent_id = cc.concurrent_id
  WHERE cpc.annee = "#{ANNEE_CONCOURS_COURANTE - 1}"
  SQL

  # Retourne TRUE is le concours est démarré
  def started?
    config[:started] == true
  end #/ started?

  def save_config
    File.open(config_path,'wb'){|f|f.write(config.to_json)}
  end #/ save_config

  def config
    @config ||= begin
      h = {}
      JSON.parse(File.read(config_path)).each do |k,v|
        h.merge!(k.to_sym => v)
      end ; h
    end
  end #/ config

  def config_path
    @config_path ||= File.expand_path('./_lib/_pages_/concours/xrequired/config.json')
  end #/ config_path
end # /<< self
end #/Concours
