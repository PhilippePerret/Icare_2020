# encoding: UTF-8
=begin
  class Actualite
  ---------------
  Gestion des actualités de l'atelier
=end
require './_lib/required/__first/ContainerClass'

class Actualite < ContainerClass

LASTS_COUNT = 20
REQUEST_LASTS   = "SELECT * FROM actualites ORDER BY created_at LIMIT #{LASTS_COUNT}".freeze
REQUEST_CREATE  = "INSERT INTO actualites (type, user_id, message, created_at, updated_at) VALUES (?, ?, ?, ?, ?)".freeze
DIV_ACTU = '<div class="actu"><span class="date">%{date}</span><span class="message">%{message}</span></div>'.freeze

DATA_ACTU = {
  'SIMPLEMESS'  => {name:'Simple message'.freeze},
  'FIRSTPAIE'   => {name:'Premier paiement'.freeze},
  'SIGNUP'      => {name:'Nouvelle inscription'.freeze},
  'SENDWORK'    => {name:'Envoi de travail'.freeze},
  'REALICARIEN' => {name:'Vrai icarien/icarienne'.freeze},
  'STARTMOD'    => {name:'Démarrage de module'.freeze},
  'QDDDEPOT'    => {name:'Dépôt sur le Quai des docs'.freeze},
  'COMMENTS'    => {name:'Envoi des commentaires sur documents'.freeze},
  'CHGETAPE'    => {name:'Changement d’étape'.freeze},
  'ENDMODULE'   => {name:'Fin de module'.freeze},
}.freeze

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
  def add(type, user_id = nil, message = nil)
    if type.is_a?(Hash)
      user_id = type[:user]||type[:user_id]
      message = type[:message]
      type    = type[:type]
    else
      user_id = user_id.id if user_id.is_a?(User)
    end
    valeurs = [type, user_id, message, now = Time.now.to_i, now]
    db_exec(REQUEST_CREATE, valeurs)
  end #/ add
  alias :create :add

  # Retourne les LASTS_COUNT dernières instances
  def lasts
    lasts_in_db = db_exec(REQUEST_LASTS)
    if !lasts_in_db.nil?
      lasts_in_db.collect { |dactu| new(dactu) }
    elsif MyDB.error
      log(MyDB.error.inspect)
      []
    else
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
