# encoding: UTF-8

# Tous les supports requis (le moins possible)
Dir["./spec/support/lib/required/**/*.rb"].each{|m|require m}

require './_lib/required/__first/handies/string' # par exemple 'safe'
