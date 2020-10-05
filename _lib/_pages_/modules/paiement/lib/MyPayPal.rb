# encoding: UTF-8
# frozen_string_literal: true
require 'json'
require './_lib/data/secret/paypal'

class MyPayPal
class << self

  attr_reader :access_token

  # L'ordre émis, qui est l'objet qui sert au départ à initier le paiement
  # pour récupérer l'url du lien du bouton qui permettra de payer et
  # ensuite ???
  attr_reader :order

  # Exécute la command CURL (complète) +curl_command+ et retourne le
  # résultat déjonsonné
  def exec_and_return(curl_command)
    # log "\n\n--- REQUEST:\n#{curl_command}\n-------------------------/CURL"
    JSON.parse(`#{curl_command} 2>&1`)
  end #/ exec_and_return

  def exec_request(data_request)
    href =
    if data_request.key?(:href)
      data_request[:href]
    elsif data_request.key?(:route)
      "#{data_request[:base]||base_api}/#{data_request[:route]}"
    end
    cmd = "CURL -s \"#{href}\"#{" #{data_request[:param]}" if data_request[:param]} -H \"Content-Type: application/json\" -H \"Authorization: Bearer #{access_token}\""
    exec_and_return(cmd)
  end #/ exec_request

  def get_access_token
    command = <<-CURL
curl -s #{base_api}/v1/oauth2/token \\
   -H "Accept: application/json" \\
   -H "Accept-Language: en_US" \\
   -u "#{client_id}:#{client_secret}" \\
   -d "grant_type=client_credentials"
    CURL
    result = exec_and_return(command)
    # log "++++ RESULT: #{result.inspect}"
    @access_token = result['access_token']
  end #/ get_access_token

  def montant_paiement
    @montant_paiement ||= sandbox? ? "0.01" : "#{user.icmodule.absmodule.tarif}.00"
  end #/ montant_paiement

  def source_script
    @source_script ||= "https://www.paypal.com/sdk/js"
  end #/ source_script

  def base_api
    @base_api ||= begin
      sandbox? ? 'https://api.sandbox.paypal.com' : 'https://api.paypal.com'
    end
  end #/ base_api

  def sandbox?
    @is_sandbox = TESTS||OFFLINE if @is_sandbox === nil
    @is_sandbox
  end #/ sandbox?

  def sandbox=(value)
    @is_sandbox = value
  end #/ sandbox=

  def client_id
    @client_id ||= compte[:client_id]
  end #/ client_id
  def client_secret
    @client_secret ||= compte[:secret]
  end #/ client_secret
  def compte
    @compte ||= PAYPAL[sandbox? ? :sandbox_account : :live_account]
  end #/ compte
end # /<< self
end #/MyPayPal
