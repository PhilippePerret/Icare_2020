# encoding: UTF-8

# Tous les supports requis (le moins possible)
require './_lib/required/__first/ContainerClass_definition' # => ContainerClass

Dir["./spec/support/lib/required/**/*.rb"].each{|m|require m}

require './_lib/required/__first/handies/string' # par exemple 'safe'
require './_lib/required/__first/extensions/Integer' # par exemple X.days
require './_lib/required/__first/extensions/Formate_helpers' # par exemple pour formate_date
require './_lib/required/__first/extensions/String'
