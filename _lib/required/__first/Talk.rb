# encoding: UTF-8
# frozen_string_literal: true
=begin

  Module de discussion en direct sur l'atelier

  Ce module doit permettre de parler directement à quelqu'un qui est en
  train de visiter l'atelier.
  Deux utilisations différentes :
    - lorsque je suis "accessible" le visiteur trouve un petit interface qui
      lui permet de me contacter directement (marqué "Phil est en ligne")
    - Je vise un visiteur par son début d'IP (relevé dans le traceur) et un
      message apparait juste pour lui, avec un champ pour répondre.


  Chaque discussion est caractérisée par un nombre aléatoire (securerandom) qui
  relie un fichier à une IP et une session. Ce nombre sécurisé est enregistré
  dans la session (talk_id)
=end
class AITalk
class << self

  # On retourne l'instance de discussion correspondant à talk_id, l'identifiant
  # de discussion enregistrée dans la session du visiteur
  def get
    if session['talk_id'].nil?
      raise "Vous n'avez pas de session de discussion avec Phil."
    end
    talk = new(id: session['talk_id'])
    talk.exists? || raise("Vous n'avez pas ou plus de discussion avec Phil.")
    return talk
  end #/ get
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# Une instance de Talk est une discussion que j'ai avec quelqu'un en
# direct.
# ---------------------------------------------------------------------
def initialize(data)
  if data.key?(:id)
    @id = data[:id]
  else
    start
  end
end #/ initialize

# initialisation d'une conversation (au tout départ)
def start
  # On prend l'IP, la Session du visiteur et on les associe à un nombre
  # aléatoire qui sera mis en session pour l'user

end #/ init

# Pour mettre fin à la session de discussion
def stop

end #/ stop

def exists?

end #/ exists?

def id
  @id ||= begin
    require 'securerandom'
    SecureRandom.hex(10)
  end
end #/ id
end #/AITalk
