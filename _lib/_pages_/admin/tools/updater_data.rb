# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module pour actualiser les données de outils administrateur
=end

class AdminToolsUpdater
class << self

  # = main =
  # Méthode qui produit le fichier data.js si nécessaire
  def update_if_required
    return if not out_of_date?
    update
  end #/ update_if_required

  # Méthode pour actualiser le fichier de données
  def update
    log("Actualisation des données opérations admin requises")
    datajs = []
    DATA_OPERATIONS_ICARIENS.each do |opid, dope|
      opstr = []
      opstr << "'#{opid}': {"
      opstr << regular_definition(:description, dope)
      opstr << regular_definition(:aide, dope)
      opstr << "for: #{dope[:for].to_json}, "
      opstr << "select_value: #{dope[:select_value] ? dope[:select_value].to_json : 'null'}, "
      opstr << "cb_value: #{dope[:cb_value] ? dope[:cb_value].to_json : 'null'}, "
      opstr << regular_definition(:long_value, dope)
      opstr << regular_definition(:medium_value, dope)
      opstr << regular_definition(:short_value, dope)
      opstr << "required:#{dope[:required].to_json}"
      opstr << "}"
      datajs << opstr.join('')
    end
    datajs = datajs.join(",#{RC}")
    datajs =  "/***#{RC} Fichier fabriqué automatiquement#{RC} NE PAS MODIFIER À LA MAIN#{RC} Cf. #{__FILE__}:#{__LINE__}#{RC}***/" +
              'const DATA_OPERATIONS = {' + RC + datajs + RC + '};'
    File.open(DATA_JS_PATH,'wb'){|f|f.write datajs}
  end #/ update

  # Méthode de formatage
  def regular_definition(key, dope)
    "#{key}: #{dope[key] ? dope[key].inspect : 'null'}, "
  end #/ regular_definition

  # Retourne TRUE si le fichier 'data.js' n'existe pas ou est périmé
  def out_of_date?
    return true if not(File.exists?(DATA_JS_PATH))
    return plus_vieille_date > data_file_date
  end #/ out_of_date?

  def data_file_date
    @data_file_date ||= File.stat(DATA_JS_PATH).mtime
  end #/ data_file_date

  # Date la plus vieille concernant tous les fichiers pouvant intervenir dans
  # la fabrication du fichier de données
  def plus_vieille_date
    @plus_vieille_date ||= begin
      mtimes = []
      # Fichiers à prendre en compte
      [
        './_lib/modules/admin/operations/operations_admin.rb',
        __FILE__,
        './_lib/modules/admin_operations/_data_operations_.rb'
      ].each do |pth|
        mtimes << File.stat(pth).mtime
      end
      mtimes.max
    end
  end #/ plus_vieille_date
end # /<< self
end #/AdminToolsUpdater
