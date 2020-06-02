# encoding: UTF-8
=begin
  class Mail
  ----------
  Envoi de mails
=end
require 'net/smtp'

class Mail
class << self

  # = main =
  # Méthode principale d'envoi du message
  # @usage
  #     Mail.send({<data>})
  #
  # +data+
  #   :to       Mail du destinataire
  #   :from     Mail de l'expéditeur
  #   :message  Le message, au format HTML (toujours, sur l'atelier)
  #   :force    Si on est en OFFLINE, force l'envoi du mail
  #
  def send(data)
    new(data).send
  end #/ send
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

# Envoi du message
def send
  Net::SMTP.start(server, port, host, user_smtp, password) do |smtp|
    smtp.send_message( full_mail, data[:from], data[:to])
  end
end #/ send

def full_mail
  deserb('full', self)
end #/ full_mail

# Construction du message final
def build

end #/ build

# Le message formaté
# ------------------
# Note: normalement, il est déjà mis en forme
def formated_message
  @formated_message ||= begin
    data[:message]
  end
end #/ formated_message

def formated_subject
  @formated_subject ||= begin
    data[:subject]
  end
end #/ formated_subject

# Retourne l'entête du mail
def header
  deserb('partials/header', self)
end #/ header

# Retourne le pied de page
def footer
  deserb('partials/footer', self)
end #/ footer

# Retourne une instance citation
def citation
  @citation ||= begin
    require_module('citation')
    Citation.rand()
  end
end #/ citation

def bind
  binding()
end #/ bind

private
  def server
    @server ||= smtp_data[:server]
  end #/ server
  def port
    @port ||= smtp_data[:port]
  end #/ port
  def host
    @host ||= 'localhost'
  end #/ host
  def user_smtp
    @user_smtp ||= smtp_data[:user]
  end #/ user_smtp
  def password
    @password ||= smtp_data[:password]
  end #/ password
  def smtp_data
    @smtp_data ||= begin
      require File.join(DATA_FOLDER,'secret','smtp') # => MY_SMTP, MAIL_DATA
      MY_SMTP
    end
  end #/ smtp_data
end #/Mail
