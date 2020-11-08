# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la class Synopsis pour les tests
=end
class Synopsis
  def reset
    current_data = get_data.freeze
    data.each { |prop, val| instance_variable_set("@#{prop}", nil) }
    @data = current_data.dup
    [:evaluations, :formated_auteurs, :formated_keywords, :data_score, :fiche_lecture, :concurrent, :css, :template_fiche_classement, :template_fiche_synopsis, :cfile
    ].each { |prop| instance_variable_set("@#{prop}", nil) }
  end #/ reset
end #/Synopsis
