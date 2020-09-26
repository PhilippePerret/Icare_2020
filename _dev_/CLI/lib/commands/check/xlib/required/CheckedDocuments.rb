# encoding: UTF-8
# frozen_string_literal: true
require_relative 'module_helpers'

class CheckedDocuments < ContainerClass
  include HelpersWritingMethods
class << self

  # = main =
  #
  # Check des documents
  #
  def check
    puts "=== Check des Documents ==="

  end #/ check


end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------


def la_chose
  @la_chose ||= "le document"
end #/ la_chose

end #/CheckedDocuments
