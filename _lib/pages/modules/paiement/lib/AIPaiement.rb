# encoding: UTF-8
=begin
  Class AIPaiement
  -----------------
  Pour le paiement au sein de l'atelier Icare
=end
SANDBOX = TESTS || OFFLINE

require './_lib/data/secret/paypal' # => PAYPAL

class AIPaiement < ContainerClass
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  def table
    @table = 'paiements'
  end #/ table

end # /<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

end #/AIPaiement
