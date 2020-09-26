# encoding: UTF-8
# frozen_string_literal: true
require_relative 'module_helpers'

class CheckedEtapes < ContainerClass
  include HelpersWritingMethods
class << self

  # = main =
  #
  # Check des IcEtapes
  #
  def check
    puts "=== Check des IcEtapes ==="

  end #/ check


end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

def la_chose
  @la_chose ||= "l'étape icarien"
end #/ la_chose

end #/CheckedEtapes
