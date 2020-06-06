# encoding: UTF-8
=begin
  class Actualite
  ---------------
  Gestion des actualités de l'atelier
=end
class Actualite
LASTS_COUNT = 20
REQUEST_LASTS   = "SELECT * FROM actualites ORDER BY created_at LIMIT #{LASTS_COUNT}".freeze
REQUEST_CREATE  = "INSERT INTO actualites (user_id, message, created_at, updated_at) VALUES (?, ?, ?, ?)".freeze
DIV_ACTU = '<div class="actu"><span class="date">%{date}</span><span class="message">%{message}</span></div>'
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  # Sort la liste des LASTS_COUNT actualités formatées
  def out
    lasts.collect(&:out).join
  end #/ out

  # Pour ajouter une actualit
  # +valeurs+ doit être absolument [user_id, message]
  def add(user_id, message)
    valeurs = [user_id, message, now = Time.now.to_i, now]
    db_exec(REQUEST_CREATE, valeurs)
  end #/ add

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
  @date ||= formate_date(data[:created_at])
end #/ date
end #/Actualite
