# encoding: UTF-8
=begin
  class Actualite
  ---------------
  Gestion des actualités de l'atelier
=end
class Actualite

LASTS_COUNT = 20
REQUEST_LASTS   = "SELECT * FROM actualites ORDER BY created_at LIMIT #{LASTS_COUNT}".freeze
REQUEST_CREATE  = "INSERT INTO actualites (type, user_id, message, created_at, updated_at) VALUES (?, ?, ?, ?, ?)".freeze
DIV_ACTU = '<div class="actu"><span class="date">%{date}</span><span class="message">%{message}</span></div>'.freeze

# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  # Sort la liste des LASTS_COUNT actualités formatées
  def out(from = nil, to = nil)
    if from == :lasts
      liste = lasts
    else
      # TODO il faut filtrer depuis la date from
      liste = all
    end
    lasts.reverse.collect(&:out).join
  end #/ out

  # Pour ajouter une actualité
  # --------------------------
  # +type+      String          Le type de l'actualité (pour le moment, aucune table ne le définit)
  # +user_id+   Integer|User    L'icarien ou son identifiant
  # +message+   String          Le message à enregistrer
  def add(type, user_id, message)
    user_id = user_id.id if user_id.is_a?(User)
    valeurs = [type, user_id, message, now = Time.now.to_i, now]
    db_exec(REQUEST_CREATE, valeurs)
  end #/ add
  alias :create :add

  # Retourne les LASTS_COUNT dernières instances
  def lasts
    db_exec(REQUEST_LASTS).collect { |dactu| new(dactu) }
  end #/ lasts
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :data
def initialize data
  @data = data
end #/ initialize
def out
  DIV_ACTU % {message: data[:message], date:date}
end #/ out
def date
  @date ||= formate_date(data[:created_at], {time:true})
end #/ date
end #/Actualite
