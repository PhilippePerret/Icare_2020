# encoding: UTF-8
# frozen_string_literal: true
# Les constantes d'erreurs générales sur l'atelier
require './_lib/required/__first/constants/errs_n_mess'
# Tous les supports requis (le moins possible)
require './_lib/required/__first/ContainerClass_definition' # => ContainerClass
require './_lib/required/__first/handies/string' # par exemple 'safe'
require './_lib/required/__first/extensions/Integer' # par exemple X.days
require './_lib/required/__first/extensions/Formate_helpers' # par exemple pour formate_date
require './_lib/required/__first/extensions/String'

require_relative './lib/constantes'
require_relative './spec_modules/module_navigation'
require_relative './handies/handies'
require_relative './handies/db'
require_relative './handies/user'

require_folder('./spec/support/lib/extensions')

module MethodMissionModule
  def method_missing(method_name, *args, &block)
    unless self.respond_to?(:loaded)
      require_relative './optional_classes/TMails'
    end
  end #/ missing_method
end
class TMails
  extend MethodMissionModule
end
class TUser
  extend MethodMissionModule
end
