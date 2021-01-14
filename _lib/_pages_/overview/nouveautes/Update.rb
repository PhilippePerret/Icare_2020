# encoding: UTF-8
# frozen_string_literal: true
class Update
  LINE_HTML = '<div class="update"><span class="date">%s</span><span class="content">• %s</span><span class="lien">%s</span>'
  LINE_HTML_SANS_DATE = '<div class="update"><span class="content">• %s</span><span class="lien">%s</span>'
  attr_reader :line
  attr_reader :date_str, :libelle, :lien
  def initialize(line)
    @line = line
    parse_line
  end #/ initialize

  # Sortie formatée de la nouveauté/modification
  def output(current_date)
    if current_date == date
      LINE_HTML_SANS_DATE % [libelle, formated_lien]
    else
      LINE_HTML % [formate_date(date), libelle, formated_lien]
    end
  end #/ output

  def formated_lien
    @formated_lien ||= begin
      if lien.nil?
        ''
      else
        Tag.lien(text:" (voir)",route:lien)
      end
    end
  end #/ formated_lien

  def parse_line
    @date_str, @libelle, @lien = line.split('::')
  end #/ parse_line

  def time
    @time ||= date.to_i
  end #/ time

  def date
    @date ||= begin
      jour,mois,annee = date_str.split(' ').collect{|n|n.to_i}
      Time.new(annee, mois, jour)
    end
  end #/ date

end #/Update
