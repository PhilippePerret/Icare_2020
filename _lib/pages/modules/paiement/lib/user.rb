# encoding: UTF-8
class User
  def has_paiement?
    true
  end #/ has_paiement?
  def paiement_overcomen?
    true
  end #/ paiement_overcomen?
end #/User

class IcModule < ContainerClass
  def montant_humain
    @montant_humain ||= "#{absmodule.tarif}#{ISPACE}€"
  end #/ montant_humain
end #/IcModule
