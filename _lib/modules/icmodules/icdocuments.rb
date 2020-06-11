# encoding: UTF-8
=begin
  Class IcDocument
  ----------------
  Gestion des documents
=end
class IcDocument < ContainerClass
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  def table
    @table ||= 'icdocuments'.freeze
  end #/ table
end # /<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
def name
  @name ||= data[:original_name]
end #/ name

end #/IcDocument < ContainerClass
