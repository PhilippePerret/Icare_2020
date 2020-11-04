# encoding: UTF-8
# frozen_string_literal: true

# Chemin d'accès absolu au fichier contenant les données secrètes du
# concours (et notamment les évaluateurs)
CONCOURS_SECRET_DATA_FILE = File.expand_path(File.join('.','_lib','data','secret','concours.rb'))

# Chemin absolu au fichier contenant toutes les données pour la fabrication
# du gel.
CONCOURS_DATA_FILE = File.join(__dir__,'concours_data_gel.yaml')

CONCOURS_GEL_DATA = YAML.load_file(CONCOURS_DATA_FILE)
# puts CONCOURS_DATA.inspect

NOW = Time.now

# Le path au fichier qui sera dupliqué pour faire le fichier de candidature
TEMPLATE_FICHIER_CANDIDATURE = File.expand_path(File.join('.','spec','support','asset','documents','autre_doc.pdf'))
