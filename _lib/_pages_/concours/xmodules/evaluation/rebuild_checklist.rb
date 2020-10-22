# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module qui reconstruit la check list après une modification des questions
  ou autre. Cela permet de ne pas la refaire à chaque fois qu'on charge
  la page.
=end
require 'yaml'

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
    File.open(PARTIAL_CHECKLIST,'wb'){|f| f.write(deserb('checklist_template',self))}
    message("La check-list a été reconstruite.")
    File.open(NOMBRE_QUESTIONS_PATH,'wb'){|f|f.write(@nombre_questions)}
  rescue Exception => e
    raise e
  ensure
    # ff.close if not ff.nil?
  end #/ rebuild_check_list

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

  # # La référence au fichier partiel de la checklist
  # #
  # def ff
  #   @ff ||= begin
  #     File.delete(PARTIAL_CHECKLIST) if File.exists?(PARTIAL_CHECKLIST)
  #     File.open(PARTIAL_CHECKLIST,'a')
  #   end
  # end #/ ff

  # Les données d'évaluation (questions) dans le fichier data_evaluation.yaml
  def data
    @data ||= YAML.load_file(DATA_CHECK_LIST_FILE)
  end #/ data
end # /<< self

# *** LES TEMPLATES pour construire la check-list ***

TEMPLATE_MENU_CHIFFRE = <<-HTML
<select name="%{fullid}">
  <option value="-">  -  </option>
  #{(0..5).to_a.reverse.collect{|i| "<option value=\"#{i}\">  #{i}  </option>"}.join('')}
</select>
HTML

TEMPLATE_MENU_APPRE = <<-HTML
<select name="%{fullid}">
  <option value="-">  -  </option>
  <option value="5">Excellent</option>
  <option value="4">Bon</option>
  <option value="3">Moyen</option>
  <option value="2">Faible</option>
  <option value="1">Bas</option>
  <option value="0">Nul</option>
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
  <div class="expli hidden">%{ex}</div>
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
  <div class="expli hidden">%{explication}</div>
  #{TEMPLATE_TITRE_SELECT}
  <div class="common-properties">__COMMON_PROPERTIES__</div>
  <div class="items">__ITEMS__</div>
</div>
HTML

end #/FicheLecture
