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

# Return TRUE si le document possède un fichier commentaire
def has_comments?
  get_option(8) == 1
end #/ has_comments?

end #/IcDocument < ContainerClass
