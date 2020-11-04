# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class GConcours
  ---------------
  Classe pour la fabrication des concours pour les gels
=end
class GConcours
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  # Réinitialisation de vraiment tout
  # On détruit les dossiers, les fichiers, on vide les bases de données
  def reset_all
    # Effacement des bases de données
    db_exec(<<-SQL)
START TRANSACTION;
TRUNCATE TABLE `#{DBTBL_CONCOURS}`;
TRUNCATE TABLE `#{DBTBL_CONCURRENTS}`;
TRUNCATE TABLE `#{DBTBL_CONCURS_PER_CONCOURS}`;
COMMIT;
    SQL
    # Effacement des dossiers concours
    FileUtils.rm_rf(CONCOURS_DATA_FOLDER)
    `mkdir "#{CONCOURS_DATA_FOLDER}"`
  end #/ reset_all
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :annee, :theme, :theme_d, :phase, :created_ds, :evaluators
attr_reader :prix1, :prix2, :prix3, :prix4, :prix5
def initialize(data_ini)
  @data_ini = data_ini
  @data_ini.each{|k,v|instance_variable_set("@#{k}", v)}
  @is_current = !!@annee.nil? # renseigné juste ci-dessous
  # Si l'année est nil (donc que c'est la session courante du concours), il
  # faut mettre la phase correspondant au gel
  if @annee.nil?
    @phase = PHASE_GEL
    @annee = Concours.current.annee
  end
end #/ initialize

# = main =
# Pour construire le concours
# (pour un concours cela consiste à :
#   - faire sa donnée dans la base de données
#   - faire le fichier concours.rb secret (en fonction des évaluateurs) quand
#     c'est le concours courant
def build
  create_db_data
  create_secret_file if current?
end #/ build

# ---------------------------------------------------------------------
#   MÉTHODES D'ÉTAT
# ---------------------------------------------------------------------
def current?
  @is_current === true
end
# ---------------------------------------------------------------------
#   MÉTHODES DE CRÉATION
# ---------------------------------------------------------------------
def create_secret_file
  require 'pp'
  require_relative './modeles/data_secret/concours.rb'
  code = CODE_SECRET_FILE % {current_evaluators: liste_current_evaluators.pretty_inspect.strip}
  File.open(CONCOURS_SECRET_DATA_FILE,'wb') do |f|
    f.write code.strip
  end
end #/ create_secret_file
# ---------------------------------------------------------------------
#   MÉTHODES DE BASE DE DONNÉES
# ---------------------------------------------------------------------
def create_db_data
  db_compose_insert(DBTBL_CONCOURS, db_data)
end #/ create_db_data
def db_data
  @db_data ||= {
    annee: annee,
    theme: theme,
    theme_d: theme_d,
    prix1: prix1 || "1 an de suivi de développement intensif",
    prix2: prix2 || "1 an de suivi de développement en rythme normal",
    prix3: prix3 || "2 modules coaching intensif",
    prix4: prix4,
    prix5: prix5,
    phase: phase,
    created_at: created_at,
    updated_at: created_at
  }
end #/ db_data
# ---------------------------------------------------------------------
#   MÉTHODES DE DONNÉES
# ---------------------------------------------------------------------
# OUT   La liste des évaluateurs du concours présent, pour insertion
#       dans le fichier secret.
def liste_current_evaluators
  require './_lib/data/secret/phil'
  require './_lib/data/secret/marion'
  liste = CONCOURS_GEL_DATA[:evaluators].collect do |m|
    jury = 0
    jury |= 1 if evaluators[:jury1].include?(m[:id])
    jury |= 2 if evaluators[:jury2].include?(m[:id])
    next if jury == 0
    pwd = if m[:password].nil?
      case m[:id]
      when 1 then PHIL[:password]
      when 2 then MARION[:password]
      end
    end
    {pseudo: m[:pseudo], id: m[:id], jury:jury, mail:m[:mail], password:pwd, sexe:m[:sexe]}
  end.compact
end #/ liste_current_evaluators
# ---------------------------------------------------------------------
#   DATA
# ---------------------------------------------------------------------
def created_at
  @created_at ||= begin
    @created_ds = created_ds.sub(/YYYY/, annee.to_s) # quand courante
    DateString.new(created_ds).to_time.to_i.to_s
  end
end #/ created_at

end #/GConcours
