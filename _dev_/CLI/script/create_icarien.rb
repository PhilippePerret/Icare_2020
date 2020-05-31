# encoding: UTF-8
=begin
  Module pour créer de toutes pièces un icarien pour faire des essais
  en direct.
=end
require 'yaml'
require 'digest/md5'

DATA_ICARIEN_YAML = <<-YAML
---
:pseudo:          Ella
:patronyme:       Ella Fitz
:naissance:       null
:mail:            pourvoir@gmail.com
:pwd:             motdepasse # pas grave only offline
:femme:           true
:real:            true # quand il a payé
:actif:           true # si false, est inactif, pas candidat
:module:
  :id:              Structure # ou null pour au hasard
  :depuis:          5  # nombre de jours depuis le début du module
  :etape:           10 # ou null pour au hasard
  :etape_depuis:    2 # nombre de jours depuis le début de l'étape
  :autres_etapes:   [1]
:en_pause:        false
:depuis:          10 # nombre de jours à l'atelier
:sortie_depuis:   null # mettre un nombre de jour si a quitté
:candidat:        false # si true, mettra :actif à nil
:after_login:     1
:destroyed:       false
:mail_confirmed:  true

YAML

DATA_ICARIEN = YAML.load(DATA_ICARIEN_YAML)

puts DATA_ICARIEN.inspect

JOUR = 3600 * 24

class NewUser
class << self
  def create(data)
    icarien = new(data)
    if data[:actif]
      # Si l'user est actif, il faut lui créer un module
      icarien.create_module(data[:module])
    end
  end #/ create
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :data
attr_accessor :id
def initialize data
  @data = data
  if data[:candidat]
    data[:actif] = nil
  end
end #/ initialize

# Méthode qui crée l'utilisateur dans la table users
def create_user
  now = Time.now.to_i
  columns = []
  values  = []
  interro = []
  [:pseudo, :patronyme, :sexe, :naissance, :cpassword, :options,
    :salt, :date_sortie
  ].each do |property|
    interro << '?'
    columns << property.to_s
    values << send(property)
  end
  columns << 'created_at'
  values << now - (JOUR * data[:depuis])
  columns << 'updated_at'
  values << now
  request = "INSERT users (#{columns.join(', ')}) VALUES (#{interro.join(', ')})"
  db_exec(request, values)
  self.id = db_last_id()
  puts "ID du nouvel utilisateur : ##{id}"

end #/ create_user

# ---------------------------------------------------------------------
#   PROPERTIES FOR CREATE

def pseudo
  @pseudo ||= data[:pseudo]
end #/ pseudo
def patronyme
  @patronyme ||= data[:patronyme]
end #/ patronyme
def sexe
  @sexe ||= data[:sexe] || ('F' if data[:femme]) || 'H'
end #/ sexe
def naissance
  @naissance ||= 1960 + rand(40)
end #/ naissance
def mail
  @mail ||= data[:mail]
end #/ mail
def cpassword
  @cpassword ||= Digest::MD5.hexdigest("#{data[:pwd]}#{mail}#{salt}")
end #/ cpassword
def options
  @options ||= build_options
end #/ options
def icmodule_id
  @icmodule_id ||= begin
    # il sera créé après que l'utilisateur a été créé
  end
end #/ icmodule_id
def salt
  @salt ||= data[:sel]
end #/ salt
def date_sortie
  @date_sortie ||= begin
    if data[:sortie_depuis]
      Time.now.to_i - (data[:sortie_depuis] * JOUR)
    else
      nil
    end
  end
end #/ date_sortie
# /PROPERTIES FOR CREATE
# ---------------------------------------------------------------------

# Pour créer le module
def create_module dmodule
  puts "Je dois créer le module."
end #/ create_module


private
  def build_options
    options = "0" * 32

    options[0]  = if data[:admin]
                    "1"
                  else
                    "0"
                  end
    options[1]  = "0" # grade
    options[2]  = "1" if data[:mail_confirmed]
    options[3]  = "1" if data[:destroyed]
    options[4]  = "0" # fréquence mail (0 = tous les jours)
    options[16] = if data[:actif] === true
                    "2"
                  elsif data[:actif] === false
                    "4"
                  elsif data[:en_pause]
                    "3"
                  else
                    "1"
                  end
    options[18] = data[:after_login]
    options[20] = "0" # mode sans entête
    options[21] = "1" # partage son historique
    options[22] = "1" # notifié si messages
    options[24] = "2" if data[:real]
  end #/ build_options
end #/NewUser

NewUser.create(DATA_ICARIEN)
