# encoding: UTF-8
# frozen_string_literal: true
=begin
  class Ticket
  ------------
  Pour la gestion des tickets
=end
class Ticket
class << self

  # Retourne NIL si le ticket n'existe pas/plus
  def get tid
    dticket = db_get('tickets', {id: tid.to_i})
    return if dticket.nil?
    new(dticket)
  end #/ get

  # Pour créer un ticket
  def create(data)
    ticket = new(data)
    ticket.save
    return ticket
  end #/ create
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

attr_reader :data
# Instanciation
def initialize(data)
  @data = data
end #/ initialize

def save
  now = Time.now.to_i
  data.merge!(created_at: now.to_s, updated_at:now.to_s)
  valeurs = data.values
  columns = data.keys.join(VG)
  interro = Array.new(valeurs.count,'?').join(VG)
  request = "INSERT INTO tickets (#{columns}) VALUES (#{interro})"
  db_exec(request, valeurs)
  @data.merge!(id: db_last_id)
end #/ save

def owner
  @owner ||= User.get(data[:user_id])
end #/ owner

# Retourne TRUE si le ticket appartient à l'utilisateur +u+
def belongs_to?(u)
  return u.id === owner.id
end #/ belongs_to?

def run
  begin
    eval(data[:code])
    delete # toujours, après son exécution réussie
  rescue Exception => e
    erreur(e)
    log(e)
  end
end #/ run

def delete
  db_exec("DELETE FROM tickets WHERE id = #{id}")
end #/ delete

def id
  @id ||= data[:id]
end #/ id
end #/Ticketa
