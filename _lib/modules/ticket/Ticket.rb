# encoding: UTF-8
=begin
  class Ticket
  ------------
  Pour la gestion des tickets
=end
class Ticket
class << self
  def get tid
    new(db_get('tickets', {id: tid.to_i}))
  end #/ get
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
  data.merge!(created_at: now, updated_at:now)
  request = "INSERT INTO tickets (#{columns}) VALUES (#{interro})"
  db_exec(request, valeurs)
  @data.merge!(id: db_last_id)
end #/ save

def owner
  @owner ||= User.get(data[:user_id])
end #/ owner

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
