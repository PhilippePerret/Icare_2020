# encoding: UTF-8
# frozen_string_literal: true

require_relative './CDossier'

class Concours
class << self

# Les données des concurrents
# ---------------------------
# C'est une table avec en clé le concurrent_id du concurrent et en valeur
# un simple Hash avec des clés symboliques.
#
def data_concurrents
  @data_concurrents ||= begin
    require './_lib/required/__first/db'
    MyDB.DBNAME = 'icare_db'
    MyDB.online = true
    h = {}
    db_exec(data_concurrents_request, [annee_courante]).each do |dc|
      h.merge!(dc[:concurrent_id] => dc)
    end
    h
  end
end #/ data_concurrents

# Retourne la liste Array des chemins d'accès aux évaluations du projet du
# concurrent d'identifiant +concurrent_id+ pour l'année courante
def evaluations_for(concurrent_id)
  dossier = File.join(CDossier.folder,concurrent_id,"#{concurrent_id}-#{annee_courante}")
  return Dir["#{dossier}/**/evaluation-*.json"]
end #/ evaluations_for



# Année du concours courant
def annee_courante
  @annee_courante ||= Time.now.month < 3 ? Time.now.year : Time.now.year + 1
end

# La requête pour obtenir les données des concurrents de l'année
# en cours, avec le titre de leur projet (utile pour la fiche)
def data_concurrents_request
  <<-SQL
SELECT
  cc.id, cc.concurrent_id, cc.mail, cc.patronyme, cc.sexe,
  pc.titre, pc.auteurs, pc.specs
  FROM concours_concurrents cc
  INNER JOIN concurrents_per_concours pc ON pc.concurrent_id = cc.concurrent_id
  WHERE pc.annee = ?
  SQL
end #/ data_concurrents_request

end # /<< self
end #/Concours
