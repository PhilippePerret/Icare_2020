# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class TTicket (Test-Ticket)
  Pour le test des tickets
=end
class TTicket
class << self
  # OUT   TRUE si le ticket définit par les paramètres +params+ existe
  # IN    {Hash} +params+ Paramètres du ticket qu'on doit trouver dans la
  #       base de données
  def exists?(params)
    db_count('tickets', params) > 0
  end #/ exists?

  # OUT   Instance TTicket d'identifiant +tid+
  def get(tid)
    new(db_get("tickets", tid.to_i))
  end #/ get
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :data
def initialize(data)
  @data = data
end #/ initialize

# Pour expect(TTicket.get(id)).to have_properties(params)
def has_properties?(params)
  params.each do |k, v|
    return false if data[k] != v
  end
  return true
end #/ has_properties?
end #/TTicket
