# encoding: UTF-8
# frozen_string_literal: true
=begin
  class Actualite
  ---------------
  Gestion des actualités de l'atelier
=end
require './_lib/required/__first/ContainerClass'

class Actualite < ContainerClass

LASTS_COUNT = 20
REQUEST_LASTS   = "SELECT * FROM actualites ORDER BY created_at DESC LIMIT #{LASTS_COUNT}"
REQUEST_CREATE  = "INSERT INTO actualites (type, user_id, message, created_at, updated_at) VALUES (?, ?, ?, ?, ?)"
DIV_ACTU = '<div class="actu"><span class="date">%{date}</span><span class="message">%{message}</span></div>'

DATA_ACTU = {
  'SIMPLEMESS'  => {name:'Simple message'},
  'FIRSTPAIE'   => {name:'Premier paiement'},
  'SIGNUP'      => {name:'Nouvelle inscription'},
  'SENDWORK'    => {name:'Envoi de travail'},
  'REALICARIEN' => {name:'Vrai icarien/icarienne'},
  'STARTMOD'    => {name:'Démarrage de module'},
  'QDDDEPOT'    => {name:'Dépôt sur le Quai des docs'},
  'COMMENTS'    => {name:'Envoi des commentaires sur documents'},
  'CHGETAPE'    => {name:'Changement d’étape'},
  'ENDMODULE'   => {name:'Fin de module'},
}

# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  # Les types d'actualité
  def types
    @types ||= DATA_ACTU.keys
  end #/ types

  def types_explained
    @types_explained ||= DATA_ACTU.collect{|k,d|"#{k} <span class=\"small\">(#{d[:name].downcase})</span>"}.join(VG)
  end #/ types_explained

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
  #             ou Hash         Si c'est une table, elle doit contenir :type, :user, :message
  # +user_id+   Integer|User    L'icarien ou son identifiant
  # +message+   String          Le message à enregistrer
  # +date+      Time            La date de l'actualité, si autre que maintenant
  def add(type, user_id = nil, message = nil, date = Time.now)
    if type.is_a?(Hash)
      user_id = type[:user]||type[:user_id]
      message = type[:message]
      date    = type[:date]
      type    = type[:type]
    else
      user_id = user_id.id if user_id.is_a?(User)
    end
    date = date.to_i.to_s
    valeurs = [type, user_id, message, date, date]
    # log("Valeurs pour création : #{valeurs}")
    db_exec(REQUEST_CREATE, valeurs)
  end #/ add
  alias :create :add

  # Retourne les LASTS_COUNT dernières instances
  def lasts
    begin
      lasts_in_db = db_exec(REQUEST_LASTS)
      lasts_in_db.reverse.collect { |dactu| new(dactu) }
    rescue MyDBError => e
      []
    end
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
