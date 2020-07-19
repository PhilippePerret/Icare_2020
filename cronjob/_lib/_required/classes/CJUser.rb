# encoding: UTF-8
=begin
  Classe CJUser
  -------------
  Gestion d'un utilisateur pour le cronjob
=end
class CJUser
class << self

  def get(uid)
    uid = uid&.to_i
    uid || raise("Il faut fournir l'identifiant de l'user")
    @items || get_all
    @items[uid]
  end #/ get

  # Méthode qui permet de tourner une boucle sur tous les users (tous)
  def each &block
    if block_given?
      all.each do |u| yield u end
    end
  end #/ each

  def all
    @all ||= get_all
  end #/ all

  # Méthode qui relève tous les users (sans aucun filtre mais à partir de 10)
  def get_all
    request = "SELECT id, pseudo, mail, options FROM users WHERE id > 9"
    all_users = db_exec(request)
    @items = {}
    unless all_users.nil?
      all_users.collect do |duser|
        new(duser).tap do |u|
          @items.merge!(u.id => u)
        end
      end
    else
      puts "MYSQL_ERROR: #{MyDB.error.inspect}"
      []
    end
  end #/ get_all

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :id, :pseudo, :mail, :options
def initialize data
  data.each { |k,v| instance_variable_set("@#{k}", v) }
end #/ initialize

def destroyed?
  @is_destroyed = (option(3) == 1) if @is_destroyed.nil?
  @is_destroyed
end #/ destroyed?

def mail_quotidien?
  @want_mail_quotidien = (option(4) == 0) if @want_mail_quotidien.nil?
  @want_mail_quotidien
end #/ mail_quotidien?

def mail_hebdomadaire?
  @want_mail_hebdo = (option(4) == 1) if @want_mail_hebdo.nil?
  @want_mail_hebdo
end #/ mail_hebdomadaire?

def option(idx)
  options[idx].to_i
end #/ option

# Ajoute une actualité (instance CJActualite) de la veille
def add_actualite_veille actu
  @actualites_veille ||= []
  @actualites_veille << actu
end #/ add_actualite

# Ajoute une actualité (instance CJActualite) de la veille
def add_actualite_hebdo actu
  @actualites_hebdo ||= []
  @actualites_hebdo << actu
end #/ add_actualite

end #/CJUser
