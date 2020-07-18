# encoding: UTF-8
=begin
  Classe CJUser
  -------------
  Gestion d'un utilisateur pour le cronjob
=end
class CJUser
class << self

  # Méthode qui relève tous les users (sans aucun filtre mais à partir de 10)
  def get_all
    request = "SELECT id, pseudo, mail, options FROM users WHERE id > 9"
    db_exec(request).collect { |duser| new(duser) }
  end #/ get_all

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :id, :pseudo, :mail, :options
def initialize data
  data.each { |k,v| instance_variable_set("@#{k}", v)}
end #/ initialize

def destroyed?
  @is_destroyed = (option(3) == 1) if @is_destroyed.nil?
  @is_destroyed
end #/ destroyed?

def mail_quotidien?
  @want_mail_quotidien = (option(4) == 0) if @want_mail_quotidien.nil?
  @want_mail_quotidien
end #/ mail_quotidien?

def option(idx)
  options[idx].to_i
end #/ option

end #/CJUser
