# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class TTicket (Test-Ticket)
  Pour le test des tickets
=end
class TTicket
class << self
  # OUT   TRUE si le ticket définit par les paramètres +params+ existe
  # IN    {Hash} +params+ Paramètres du ticket qu'on doit trouver dans la
  #       base de données
  def exists?(params)
    db_count('tickets', params) > 0
  end #/ exists?

  # OUT   Instance TTicket d'identifiant +tid+
  def get(tid)
    new(db_get("tickets", tid.to_i))
  end #/ get

  def reset
    db_exec("TRUNCATE TABLE tickets")
  end #/ reset


  # IN    +data+
  #         :nombre     Le nombre à créer
  #         :between    {Range} Entre tel et tel jour.
  #
  def create(data)
    lines = []
    now = Time.now.to_i
    data[:nombre].times do
      nbjours = rand(data[:between])
      time = now + nbjours.days
      lines << "INSERT INTO tickets (id, user_id, code, created_at, updated_at) VALUES (#{get_uniq_id}, 1, 'User.get(1)', '#{time}', '#{time}');"
    end
    req = <<-SQL
START TRANSACTION;
#{lines.join("\n")}
COMMIT;
    SQL
    # puts "REQUEST:\n#{req}"
    res = db_exec(req)
    # puts "res sql: #{res.inspect}"
  end #/ create

  def get_new_authentif
    require 'securerandom'
    SecureRandom.hex(10)[0..9]
  end #/ get_new_authentif

  # Si on ajoute la donnée 'authentified: false' dans les données pour dire
  # que le ticket n'a pas besoin d'être certifié, il faut générer un ID assez
  # long pour qu'il ne soit pas utilisé à des fins pirates.
  def get_uniq_id
    @tickets_ids ||= get_all_tickets_ids
    begin
      checked_id = 10000000+rand(100000000)
    end while @tickets_ids.key?(checked_id)
    @tickets_ids.merge!(checked_id => true)
    return checked_id
  end #/ get_uniq_id

  def get_all_tickets_ids
    h = {}
    db_exec("SELECT id FROM tickets").collect { |d| h.merge!(d[:id]=>true) }
    h
  end #/ self.get_all_tickets_ids

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

# Pour expect(TTicket.get(id)).to have_properties(params)
def has_properties?(params)
  params.each do |k, v|
    return false if data[k] != v
  end
  return true
end #/ has_properties?
end #/TTicket
