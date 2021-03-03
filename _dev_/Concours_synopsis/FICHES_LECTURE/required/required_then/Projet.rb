# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class Projet
  ------------
  Pour la gestion des projets
=end
class Projet
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :data
# La position du projet par rapport aux autres
attr_accessor :position

def initialize(data)
  @data = data
end

def ref
  @ref ||= "“#{titre}” de #{patronyme}"
end

def id; @id ||= data[:id] end
def titre; @titre ||= data[:titre] end

def fiche_lecture
  @fiche_lecture ||= FicheLecture.new(self)
end

def formated_note
  note || "---"
end
# IN    {Float} Une valeur réelle, normalement flottante
# OUT   {String} Le nombre pour affichage. Principale, sans ".0" à la fin
#       s'il y en a un
def formate_note(v)
  if v.nil?
    '---'
  elsif v.to_i == v
    v.to_i
  else
    v
  end.to_s
end #/ formate_float

def note; evaluation.note end

def real_auteurs
  @real_auteurs ||= begin
    patros =  if data[:auteurs]
                data[:auteurs].split(',').collect{|p|p.strip}
              else
                [data[:patronyme]]
              end
    # On les transforme bien tous en noms
    patros.collect do |patro|
      patronimize(patro)
    end.pretty_join
  end
end
def patronyme ; @patronyme ||= data[:patronyme] end

def evaluation
  @evaluation ||= begin
    ENV['is_projet_suivi'] = (concurrent_id == '20210103111210').inspect
    Evaluation.new(fiches_evaluation)
  end
end #/ evaluation

# Retourne TRUE si le projet peut être évalué (i.e. s'il a des fiches
# d'évaluation)
def fichable?
  fiches_evaluation.count > 0
end

def fiches_evaluation
  @fiches_evaluation ||= FLFactory.evaluations_for(concurrent_id)
end

def concurrent_id
  @concurrent_id ||= data[:concurrent_id]
end

def folder
  @folder ||= File.join(FLFactory.data_folder, concurrent_id)
end #/ folder

end #/Projet
