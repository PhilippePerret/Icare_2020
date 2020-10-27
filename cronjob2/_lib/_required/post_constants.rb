# encoding: UTF-8
# frozen_string_literal: true
=begin
  Les "post-constantes" sont des constantes qui ne peuvent être définies
  qu'après avoir tout chargé. Typiquement, il s'agit de la constante
  QUINZE_JOUR_AGO qui se calcule par rapport à Cronjob.current_time (qui peut
  être explicitement défini par les tests)
=end

QUINZE_JOUR_AGO = Cronjob.current_time.to_i - 15*24*3600
