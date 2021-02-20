# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class Dossier
  ------------
  Cette classe a été produite pour essayer de pouvoir "isoler" complètement
  le travail d'évaluation. C'est-à-dire pour pouvoir faire :
  iprojet = Dossier.new(concurrent_id, annee) pour obtenir une instance qui permet
  ensuite d'obtenir :
    iprojet.note_totale   => La note générale
    iprojet.position      => La position
  … ainsi que d'autres données utile
=end
require_relative './Evaluation_module'

class Dossier
include EvaluationMethodsModule

class << self

  # Méthode qui permet de calculer la note de tous les projets conformes et
  # leur classement actuel.
  def calculate_all_notes_and_positions
    # On commence par calculer les évaluations de tous les dossiers conformes
    conformes.each { |dossier| dossier.calc_evaluation_for_all(nil) }
    # On les classe suivant leur note générale
    @classement = conformes.sort_by { |dossier| - dossier.note_totale }
    # On renseigne leur position
    @classement.each_with_index do |dossier, idx|
      dossier.position = 1 + idx
    end
    @classement
  end

  def classement
    @classement || calculate_all_notes_and_positions
  end

  # Retourne les dix présélectionnés
  def preselecteds
    @preselecteds ||= classement[0..9]
  end

  # Retourne les non présélectionnés
  def non_preselecteds
    @non_preselecteds ||= classement[10..-1]
  end
  alias :nonselecteds :non_preselecteds

  # Retourne la liste Array des instances de tous les projets conformes
  def conformes
    @conformes ||= begin
      request = "SELECT concurrent_id FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE annee = ? AND SUBSTRING(specs,1,2) = ?"
      db_exec(request, [ANNEE_CONCOURS_COURANTE, '11']).collect do |dp|
        Dossier.new(dp[:concurrent_id], ANNEE_CONCOURS_COURANTE)
      end
    end
  end

  # Retourne la liste Array des instances de concurrents sans dossiers
  def sans_dossiers
    @sans_dossiers ||= begin
      request = "SELECT concurrent_id FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE annee = ? AND SUBSTRING(specs,1,1) = ?"
      db_exec(request, [ANNEE_CONCOURS_COURANTE, '0']).collect do |dp|
        Dossier.new(dp[:concurrent_id], ANNEE_CONCOURS_COURANTE)
      end
    end
  end

  def palmares_data(annee)
    YAML.load_file(palmares_file_path(annee))
  end

  def palmares_file_path(annee)
    @palmares_file_path ||= File.join(palmares_folder(annee), "palmares.yaml")
  end

  def palmares_folder(anne)
    mkdir(File.join(CONCOURS_PALM_FOLDER,annee.to_s))
  end


end # /<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :concurrent_id, :annee
def initialize(concurrent_id, annee)
  @concurrent_id = concurrent_id
  @annee = annee
end #/ initialize

def position
  @position || self.class.calculate_all_notes_and_positions
  @position
end

def position=(value); @position = value end

def folder
  @folder ||= File.join(CONCOURS_DATA_FOLDER,concurrent_id,folder_name)
end
def folder_name; @folder_name ||= "#{concurrent_id}-#{annee}" end
end #/Dossier
