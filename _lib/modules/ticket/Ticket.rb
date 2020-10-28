# encoding: UTF-8
# frozen_string_literal: true
=begin
  class Ticket
  ------------
  Pour la gestion des tickets
=end
class Ticket
class << self

  # Return l'instance {Ticket} du ticket d'identifiant +tid+
  # Retourne NIL si le ticket n'existe pas/plus
  def get tid
    tid = tid.to_i
    dticket = db_get('tickets', tid)
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
  @data.merge!(created_at: now.to_s, updated_at:now.to_s)
  if @data.delete(:authentified) === false
    # (cf. ci-dessous la méthode get_uniq_id)
    @data.merge!(id: get_uniq_id, authentif: authentif_code_genered)
  end
  db_compose_insert('tickets', data)
  @data.merge!(id: db_last_id) unless data.key?(:id)
end #/ save


def owner
  @owner ||= User.get(data[:user_id])
end #/ owner

# Retourne TRUE si le ticket appartient à l'utilisateur +u+
def belongs_to?(u)
  return u.id === owner.id
end #/ belongs_to?

# OUT   True si le ticket possède un code d'authentification
def auto_authentified?
  not(authentif.nil?)
end #/ auto_authenfied?

def delete
  db_exec("DELETE FROM tickets WHERE id = #{id}")
end #/ delete

def id
  @id ||= data[:id]
end #/ id

def authentif
  @authentif ||= data[:authentif]
end #/ authentif

private
  def self.get_all_tickets_ids
    h = {}
    db_exec("SELECT id FROM tickets").collect { |d| h.merge!(d[:id]=>true) }
    h
  end #/ self.get_all_tickets_ids

  # Retourne une nombre aléatoire unique de 10 caractères qui permettra
  # d'authentifier un ticket sans authentification manuelle requise
  def authentif_code_genered
    @authentif_code_genered ||= begin
      require 'securerandom'
      SecureRandom.hex(10)[0..9]
    end
  end #/ get_authentif_code

  # Si on ajoute la donnée 'authentified: false' dans les données pour dire
  # que le ticket n'a pas besoin d'être certifié, il faut générer un ID assez
  # long pour qu'il ne soit pas utilisé à des fins pirates.
  def get_uniq_id
    @tickets_ids ||= self.class.get_all_tickets_ids
    begin
      checked_id = 10000000+rand(100000000)
    end while @tickets_ids.key?(checked_id)
    @tickets_ids.merge!(checked_id => true)
    return checked_id
  end #/ get_uniq_id

end #/Ticket
