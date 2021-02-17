# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module qui reconstruit la check list après une modification des questions
  ou autre. Cela permet de ne pas la refaire à chaque fois qu'on charge
  la page.
=end
require 'yaml'

# Notamment pour les titres "Excellent", "Bon", etc.
require './_lib/_pages_/concours/evaluation/lib/constants'

# Pour consigner les "ID full" afin d'éviter les doublons
ALL_IDS = {}

class CheckList
class << self

  def bind ; binding() end

  # = main =
  #
  # Reconstruction de la check-list qui permet d'affecter les notes
  def rebuild_checklist
    @nombre_questions = 0
    File.open(PARTIAL_CHECKLIST,'wb') do |f|
      f.puts "<%\n# Ce partiel est généré de façon automatique. NE PAS LE TOUCHER\n%>"
      f.puts deserb('checklist_template',self)
    end
    File.open(NOMBRE_QUESTIONS_PATH,'wb'){|f|f.write(@nombre_questions)}
  rescue Exception => e
    raise e
  ensure
    # ff.close if not ff.nil?
  end #/ rebuild_check_list

  # Parfois le fichier NOMBRE_QUESTIONS n'est pas construit, on peut le
  # refaire grâce à cette méthode
  def remake_nombre_questions_file
    log("-> remake_nombre_questions_file")
    @nombre_questions = 0
    build_sujet(data, [], [])
    File.open(NOMBRE_QUESTIONS_PATH,'wb'){|f|f.write(@nombre_questions)}
    log("Le fichier du nombre de questions est reconstruit.")
  end #/ remake_nombre_questions_file

  # = Construction du sujet =
  def build_sujet(datasuj, fullid, commons_props)
    common_properties = commons_props.dup # pour ne pas toutes les ajouter
    id = datasuj[:id]
    fullid << id
    fullid_str = fullid.join('-')
    datasuj.merge!(titre: datasuj.delete(:ti))
    datasuj.merge!(explication: datasuj.delete(:ex))
    log("datasuj: #{datasuj.inspect}")
    if ALL_IDS.key?(id) && ALL_IDS[id] != datasuj[:titre]
      raise "Doublon d'identifiant (#{id.inspect}) avec titre différent (#{ALL_IDS[id]}/#{datasuj[:titre]}). Je dois m'arrêter là."
    else
      # On enregistre cet identifiant avec son titre
      ALL_IDS.merge!(datasuj[:id] => datasuj[:titre])
    end
    # Classe CSS
    css = 'prop'
    if datasuj[:common_properties] === false && (datasuj[:items].nil? || datasuj[:items].empty?)
      css = "#{css} simple"
    end
    datasuj.merge!(fullid: fullid_str, class:css, fond: fond_line)
    template = datasuj[:explication] ? TEMPLATE_LINE_MAINPROP_WITHEX : TEMPLATE_LINE_MAINPROP
    line = template % datasuj
    @nombre_questions += 1
    comsprops = ""
    unless datasuj[:common_properties] === false
      if datasuj.key?(:common_properties)
        datasuj[:common_properties].each do |dp|
          common_properties << dp.merge!(titre:dp.delete(:ti))
        end
      end
      comsprops = common_properties.collect do |dprop|
        @nombre_questions += 1
        template = dprop.key?(:ex) ? TEMPLATE_LINE_PROP_WITHEX : TEMPLATE_LINE_PROP
        template % dprop.merge!(fullid: "#{fullid_str}-#{dprop[:id]}", class:"subprop", fond:fond_line)
      end.join('')
    end
    line = line.sub(/__COMMON_PROPERTIES__/,comsprops)
    # On ajoute les items
    if datasuj[:items]
      sousprops = datasuj[:items].collect do |datap|
        build_sujet(datap, fullid.dup, common_properties)
      end.join('')
    else
      sousprops = ""
    end
    return line.sub(/__ITEMS__/, sousprops)
  end #/ build_sujet

  def fond_line
    @ifondline ||= 0
    @ifondline = @ifondline == 1 ? 0 : 1
    ['deep','soft'][@ifondline]
  end #/ fond_line

  # Les données d'évaluation (questions) dans le fichier data_evaluation.yaml
  def data
    @data ||= YAML.load_file(DATA_QUESTIONS_CONCOURS)
  end #/ data
end # /<< self

# *** LES TEMPLATES pour construire la check-list ***

TEMPLATE_MENU_CHIFFRE = <<-HTML
<select name="%{fullid}">
  <option value="-">#{CONCOURS_EVALUATION_VAL2TIT['-']}</option>
  <option value="x">#{CONCOURS_EVALUATION_VAL2TIT['x']}</option>
  #{(0..5).to_a.reverse.collect{|i| "<option value=\"#{i}\">  #{i}  </option>"}.join('')}
</select>
HTML

TEMPLATE_MENU_APPRE = <<-HTML
<select name="%{fullid}">
  <option value="-">#{CONCOURS_EVALUATION_VAL2TIT['-']}</option>
  <option value="x">#{CONCOURS_EVALUATION_VAL2TIT['x']}</option>
  <option value="5">#{CONCOURS_EVALUATION_VAL2TIT[5]}</option>
  <option value="4">#{CONCOURS_EVALUATION_VAL2TIT[4]}</option>
  <option value="3">#{CONCOURS_EVALUATION_VAL2TIT[3]}</option>
  <option value="2">#{CONCOURS_EVALUATION_VAL2TIT[2]}</option>
  <option value="1">#{CONCOURS_EVALUATION_VAL2TIT[1]}</option>
  <option value="0">#{CONCOURS_EVALUATION_VAL2TIT[0]}</option>
</select>
HTML

TEMPLATE_TITRE_SELECT = <<-HTML
<div class="line-note %{fond}">
  <span class="prop-name">%{titre}</span>
  #{TEMPLATE_MENU_APPRE}
</div>
HTML

TEMPLATE_TITRE_SELECT_CHFFRES = <<-HTML
<div class="line-note %{fond}">
  <span class="prop-name">%{titre}</span>
  #{TEMPLATE_MENU_CHIFFRE}
</div>
HTML

TEMPLATE_LINE_PROP = <<-HTML
<div id="div-%{fullid}" class="%{class}">
  #{TEMPLATE_TITRE_SELECT}
</div>
HTML
TEMPLATE_LINE_PROP_WITHEX = <<-HTML
<div id="div-%{fullid}" class="%{class} withex">
  <div class="expli hidden">%{ex}<div style="font-size:0.85em;text-align:right;">(cliquez sur ce texte pour le faire disparaitre)</div></div>
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

TEMPLATE_LINE_MAINPROP_WITHEX = <<-HTML
<div id="div-%{fullid}" class="%{class} withex">
  <div class="expli hidden">%{explication}<div style="font-size:0.85em;text-align:right;">(cliquez sur ce texte pour le faire disparaitre)</div></div>
  #{TEMPLATE_TITRE_SELECT}
  <div class="common-properties">__COMMON_PROPERTIES__</div>
  <div class="items">__ITEMS__</div>
</div>
HTML

end #/FicheLecture
