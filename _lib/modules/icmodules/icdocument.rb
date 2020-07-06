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

def shared?(fordoc)
  option(fordoc == :original ? 1 : 9) == 1
end #/ shared?

def icetape
  @icetape ||= IcEtape.get(icetape_id)
end #/ icetape

end #/IcDocument < ContainerClass
