# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class EvaluationForm
  --------------------
  Pour l'évaluation d'un synopsis

  Ici, la classe et l'instance sont deux entités presques séparées dans le
  sens où la classe va gérer le formulaire en tant que formulaire alors que
  l'instance va plutôt gérer l'évaluation.
=end
# Pour mettre tous les full-id créés et trouver éventuellement les doublons
ALL_FULL_ID = {}

TEMPLATE_TITRE_SELECT = <<-HTML
<span class="prop-name">%{titre}</span>
<select name="%{fullid}">
  <option value="">&nbsp;&nbsp;-&nbsp;&nbsp;</option>
  #{(0..5).collect{|i| "<option value=\"#{i}\">&nbsp;&nbsp;#{i}&nbsp;&nbsp;</option>"}.join('')}
</select>
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

class EvaluationForm
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

  # Méthode qui construit le formulaire
  # Je préfère un nom explicite (build) plutôt qu'un propriété qui
  # soustendrait la construction
  def build
    @build ||= begin
      build_sujet(DATA_PROJET[0])
    end
  end #/ build
  def build_sujet(dataprop, fullid = "", common_properties = nil)
    # log("dataprop: #{dataprop.inspect}")
    common_properties ||= []
    id = dataprop[:id]
    fullid = "#{fullid}-#{id}"
    raise "Le fullid #{fullid} est un doublon à corriger" if ALL_FULL_ID.key?(fullid)
    ALL_FULL_ID.merge!(fullid => true)
    # Classe CSS
    css = 'prop'
    if dataprop[:common_properties] === false && (dataprop[:items].nil? || dataprop[:items].empty?)
      css = "#{css} simple"
    end
    dataprop.merge!(fullid: fullid, class:css)
    line = TEMPLATE_LINE_MAINPROP % dataprop
    comsprops = ""
    unless dataprop[:common_properties] === false
      common_properties += dataprop[:common_properties] if dataprop.key?(:common_properties)
      comsprops = common_properties.collect do |dprop|
        TEMPLATE_LINE_PROP % dprop.merge!(fullid: "#{fullid}-#{dprop[:id]}", class:"subprop")
      end.join('')
    end
    line = line.sub(/__COMMON_PROPERTIES__/,comsprops)
    # On ajoute les items
    if dataprop[:items]
      sousprops = dataprop[:items].collect do |datap|
        build_sujet(datap, fullid, common_properties)
      end.join('')
    else
      sousprops = ""
    end
    return line.sub(/__ITEMS__/, sousprops)
  end #/ build_sujet

  # Les données d'évaluation du synopsis
  def data
    @data ||= begin
    end
  end #/ data
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
# Instance Synopsis du synopsis visé par l'évaluation
attr_reader :synopsis
# Instance User de l'évaluateur du synopsis
attr_reader :evaluateur
def initialize(synopsis, evaluateur)
  @synopsis = synopsis
  @evaluateur = evaluateur
end #/ initialize

# Sortie HTML du formulaire d'évaluation du synopsis
def out

end #/ out

# Sauvegarde de l'évaluation
def save

end #/ save

# Méthode appelée pour informer les autres évaluateurs qu'une évaluation
# a été créée ou actualisée.
def warn_other_evaluateur

end #/ warn_other_evaluateur

# Données d'évaluation, c'est-à-dire les notes attribuées par l'évaluateur
# À ne pas confondre avec +data+ du constructor qui sont les données
# absolues d'évaluation.
def data
  @data ||= begin
    if File.exists?(path)
      JSON.parse(File.read(path))
    else
      {}
    end
  end
end #/ data

# Chemin d'accès au fichier d'évaluation (pour le synopsis donné et l'évaluateur
# donné)
def path
  @path ||= File.join(synopsis.folder, "evaluation-#{evaluateur.id}.json")
end #/ path
end #/EvaluationForm
