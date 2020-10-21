# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module qui reconstruit la check list après une modification des questions
  ou autre. Cela permet de ne pas la refaire à chaque fois qu'on charge
  la page.
=end
require 'yaml'

# Pour consigner les "ID full" afin d'éviter les doublons
ALL_FULL_ID = {}

class FicheLecture
class << self

  # = main =
  #
  # Reconstruction de la check-list qui permet d'affecter les notes
  def rebuild_checklist
    w("<%# frozen_string_literal: true %>")
    w('<div id="checklist">')
    w(build_sujet(data, "", []))
    w('</div>') # / div#checklist
    message("La check-list a été reconstruite.")
  rescue Exception => e
    raise e
  ensure
    ff.close if not ff.nil?
  end #/ rebuild_check_list

  # Pour écrire dans le fichier
  def w str
    ff.write(str+RC)
  end #/ w

  # = Construction du sujet =
  def build_sujet(datasuj, fullid, common_properties)
    id = datasuj[:id]
    datasuj.merge!(titre: datasuj.delete(:ti))
    datasuj.merge!(explication: datasuj.delete(:ex))
    log("datasuj: #{datasuj.inspect}")
    fullid = "#{fullid}-#{id}"
    raise "Le fullid #{fullid} est un doublon à corriger" if ALL_FULL_ID.key?(fullid)
    ALL_FULL_ID.merge!(fullid => true)
    # Classe CSS
    css = 'prop'
    if datasuj[:common_properties] === false && (datasuj[:items].nil? || datasuj[:items].empty?)
      css = "#{css} simple"
    end
    datasuj.merge!(fullid: fullid, class:css)
    line = TEMPLATE_LINE_MAINPROP % datasuj
    comsprops = ""
    unless datasuj[:common_properties] === false
      if datasuj.key?(:common_properties)
        datasuj[:common_properties].each do |dp|
          common_properties << dp.merge!(titre:dp.delete(:ti), explication:dp.delete(:ex))
        end
      end
      comsprops = common_properties.collect do |dprop|
        TEMPLATE_LINE_PROP % dprop.merge!(fullid: "#{fullid}-#{dprop[:id]}", class:"subprop")
      end.join('')
    end
    line = line.sub(/__COMMON_PROPERTIES__/,comsprops)
    # On ajoute les items
    if datasuj[:items]
      sousprops = datasuj[:items].collect do |datap|
        build_sujet(datap, fullid, common_properties)
      end.join('')
    else
      sousprops = ""
    end
    return line.sub(/__ITEMS__/, sousprops)
  end #/ build_sujet

  # La référence au fichier partiel de la checklist
  #
  def ff
    @ff ||= begin
      File.delete(PARTIAL_CHECK_LIST) if File.exists?(PARTIAL_CHECK_LIST)
      File.open(PARTIAL_CHECK_LIST,'a')
    end
  end #/ ff

  # Les données d'évaluation (questions) dans le fichier data_evaluation.yaml
  def data
    @data ||= YAML.load_file(DATA_CHECK_LIST_FILE)
  end #/ data
end # /<< self

# *** LES TEMPLATES pour construire la check-list ***

TEMPLATE_MENU_CHIFFRE = <<-HTML
<select name="%{fullid}">
  <option value="">  -  </option>
  #{(0..5).to_a.reverse.collect{|i| "<option value=\"#{i}\">  #{i}  </option>"}.join('')}
</select>
HTML

TEMPLATE_MENU_APPRE = <<-HTML
<select name="%{fullid}">
  <option value="">  -  </option>
  <option value="5">Excellent</option>
  <option value="4">Bon</option>
  <option value="3">Moyen</option>
  <option value="2">Faible</option>
  <option value="1">Bas</option>
  <option value="0">Nul</option>
</select>
HTML

TEMPLATE_TITRE_SELECT = <<-HTML
<span class="prop-name">%{titre}</span>
#{TEMPLATE_MENU_APPRE}
HTML

TEMPLATE_TITRE_SELECT_CHFFRES = <<-HTML
<span class="prop-name">%{titre}</span>
#{TEMPLATE_MENU_CHIFFRE}
HTML

TEMPLATE_LINE_PROP = <<-HTML
<div id="div-%{fullid}" class="%{class}">
  #{TEMPLATE_TITRE_SELECT}
</div>
HTML

TEMPLATE_LINE_MAINPROP = <<-HTML
<div id="div-%{fullid}" class="%{class}">
  #{TEMPLATE_TITRE_SELECT}
  <div class="common-properties">__COMMON_PROPERTIES__</div>
  <div class="items">__ITEMS__</div>
</div>
HTML

end #/FicheLecture
