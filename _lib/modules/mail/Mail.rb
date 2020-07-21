# encoding: UTF-8
=begin
  class Mail
  ----------
  Envoi de mails
=end
require 'net/smtp'
require './_lib/required/__first/Deserb'

TEMP_FOLDER = File.expand_path(File.join('.','tmp')) unless defined?(TEMP_FOLDER)
DATA_FOLDER = File.expand_path(File.join('.','_lib','data')) unless defined?(DATA_FOLDER)

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
  #   :subject  Sujet du message
  #   :message  Le message, au format HTML (toujours, sur l'atelier)
  #   :force    Si on est en OFFLINE, force l'envoi du mail
  #
  def send(data)
    new(data).send
  end #/ send

  # Dossier temporaire dans lequel sont enregistrés les messages
  def folder
    @folder ||= begin
      pd = File.join(TEMP_FOLDER,'mails')
      `mkdir -p "#{pd}"` unless File.exists?(pd)
      pd
    end
  end #/ folder
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
# ----------------
# Si on est en ligne ou que les données contiennent :force => true, alors
# on envoie le message. Sinon, on ne fait que l'enregistrer dans le dossier
# tmp/mails, ce qu'on fait toujours.
def send
  init_server
  save # On enregistre toujours le message
  if ONLINE || data[:force]
    Net::SMTP.start(server, port, host, user_smtp, password) do |smtp|
      smtp.send_message( full_mail, destinataire, expediteur)
    end
  end
end #/ send

# Enregistrement du message
def save
  fpath = File.join(self.class.folder, "#{destinataire}-#{Time.now.to_f}.html")
  File.open(fpath,'wb'){|f| f.write(full_mail)}
end #/ save

def destinataire
  @destinataire ||= data[:to]||DATA_MAIL[:mail]
end #/ destinataire

def expediteur
  @expediteur ||= data[:from]||DATA_MAIL[:mail]
end #/ expediteur

def full_mail
  @full_mail ||= deserb('full', self)
end #/ full_mail

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
    "🦋ICARE | #{data[:subject]}".freeze
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
  def init_server
    require File.join(DATA_FOLDER,'secret','smtp') # => MY_SMTP, MAIL_DATA
  end #/ init_server
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
    @smtp_data ||= MY_SMTP
  end #/ smtp_data
end #/Mail
