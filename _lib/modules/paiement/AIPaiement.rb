# encoding: UTF-8
=begin
  Class AIPaiement
  -----------------
  Pour le paiement au sein de l'atelier Icare
=end
SANDBOX = TESTS || OFFLINE

require './_lib/data/secret/paypal' # => PAYPAL

class AIPaiement < ContainerClass

unless SANDBOX
  URL_PAYPAL = 'https://www.paypal.com/cgi-bin/webscr'.freeze
  URL_PAYPAL_NVP = 'https://api-3t.paypal.com/nvp'.freeze
  URL_PAYPAL_RETURN = "#{App::FULL_URL_ONLINE}/modules/paiement?op=ok"
  URL_PAYPAL_CANCEL = "#{App::FULL_URL_ONLINE}/modules/paiement?op=cancel"
  DATA_ACCOUNT = PAYPAL[:live_account]
else
  # Sandbox (offline ou tests)
  URL_PAYPAL_NVP = 'https://api-3t.sandbox.paypal.com/nvp'.freeze
  URL_PAYPAL = 'https://www.sandbox.paypal.com/cgi-bin/webscr'.freeze
  URL_PAYPAL_RETURN = "#{App::FULL_URL_OFFLINE}/modules/paiement?op=ok"
  URL_PAYPAL_CANCEL = "#{App::FULL_URL_OFFLINE}/modules/paiement?op=cancel"
  DATA_ACCOUNT = PAYPAL[:sandbox_account]
end
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  attr_reader :current
  def table
    @table = 'paiements'
  end #/ table

  # Toute première méthode appelée quand on arrive sur la page et que rien
  # n'est encore fait.
  def init_paiement
    message "-> page de paiement."
    @current = new()
    @current.init
  rescue Exception => e
    erreur(e.message)
    log(e)
  end #/ init_paiement


end # /<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_writer :token

def initialize id = nil # contrairement à ContainerClass
  @id = nil
end #/ initialize

# raccourci
def absmodule
  @absmodule ||= user.icmodule.absmodule
end #/ absmodule

# Appelée par class::init_paiement, la méthode initiale qui reçoit
# l'arrivée sur la page de paiement
def init
  # avant : @paiement_montant
  @montant  = "#{absmodule.tarif}.00".freeze
  # avant : @paiement_description
  @objet = MESSAGES[:objet_paiement] % [absmodule.name]

  # === SOUMISSION DE LA REQUÊTE CURL ===
  # C'est la requête qui initie le paiement
  curl_response = `#{request_express_checkout}`

  # On analyse/décompose le retour pour obtenir une table
  # de hashage avec clés symboliques.
  curl_response = reponse_paypal_to_hash(curl_response)
  log("--- curl_response: #{curl_response.inspect}")

  # Succès ou failure ?
  curl_response[:ack] != "Failure" || raise(ERRORS[:express_checkout_failure])

  # En cas de succès, on mémorise le token
  @token = curl_response[:token]

end #/ init

# Construction de la requête qui va permettre d'initier le paiement
def request_express_checkout
  data_paiement = {}
  data_paiement.merge!(params_authentification_paiement)
  data_paiement.merge!(data_key)
  data_paiement.merge!(
    method:                 "SetExpressCheckout",
    localecode:             "FR",
    cartbordercolor:        "008080",
    paymentrequest_0_amt:   montant,
    paymentrequest_0_qty:   "1"
  )
  querystring= data_paiement.collect do |name, value|
    "#{name.to_s.upcase}=#{CGI::escape(value)}"
  end.join('&').freeze

  log("--- querystring: #{querystring}")

  # Finalisation de la commande initisant le paiement
  #
  # En mode Sandbox, on utilise l'option '--insecure' (requête non
  # sécurisée) pour contourner la recherche de certificat. En mode
  # live, on utilise l'adresse sécurisée, avec le certificat.
  #
  "curl -s#{SANDBOX ? ' --insecure' : ''} #{URL_PAYPAL_NVP} -d \"#{querystring}\"".freeze
end #/ request_express_checkout

def montant ; @montant  end
def objet   ; @objet    end

# Le token de paiement. La première fois, il est défini explicitement
# par la méthode #init. Ensuite il est mis dans le formulaire et
# retourné par les paramètres.
def token
  @token ||= param(:token)
end
# L'ID de paiement, n'est défini que lorsqu'on revient de l'instanciation
# du paiement.
def payer_id
  @payer_id ||= param(:PayerID)
end

def data_key
  {
    PAYMENTREQUEST_0_CURRENCYCODE:    "EUR",
    PAYMENTREQUEST_0_PAYMENTACTION:   "SALE",
    cancelUrl:                        URL_PAYPAL_CANCEL,
    returnurl:                        URL_PAYPAL_RETURN
  }
end

def params_authentification_paiement
  @params_authentification_paiement ||= begin
    {
      'USER'      => CGI::escape(DATA_ACCOUNT[:username]),
      'PWD'       => DATA_ACCOUNT[:password],
      'SIGNATURE' => DATA_ACCOUNT[:signature],
      'VERSION'   => "119"
    }
  end
end

# Méthode décomposant la réponse de CURL en la transformant en
# un Hash avec des clés symboliques.
#
def reponse_paypal_to_hash reponse
  CGI.parse(reponse).inject({}) do |res, (k, v)|
    res.merge!(k.downcase.to_sym => v.first)
  end
end

end #/AIPaiement
