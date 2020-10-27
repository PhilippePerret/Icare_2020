# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class Icarien
  -------------
  Pour le cronjob. Pour le moment, on se contente de cette classe, sans
  charger la classe User du site. Mais si vraiment on voit que ça n'est pas
  "rentable" on chargera la classe du site.
=end
class Icarien
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  # = main =
  #
  # Méthode qui sélectionne les icariens voulus
  #
  # IN    Filtre {Hash} de recherche
  #       :contactable    Si true, seulement les icariens contactables par mail
  #       :contact_hebdomadaire   True si on veut seulement ceux qui cherchent un
  #                               contact hebdomadaire
  #       :contact_quotidien      TRUE si on veut seulement ceux qui cherchent
  #                               un contact quotidien
  #       :even_destroyed         Si true, on renvoie même les détruit, alors
  #                               que par défaut on ne les prend pas.
  def select(filtre)
    where_clause = []

    # Simple icarien
    if filtre[:admins]
      where_clause << "SUBSTRING(options,1,1) <> '0'"
    else
      where_clause << "SUBSTRING(options,1,1) = '0'"
    end

    # Contactables par mail
    if filtre[:contactable]
      where_clause << "SUBSTRING(options,27,1) IN ('1','3')"
    end

    # Non détruits (4e bit <> 1)
    if not(filtre[:even_destroyed])
      where_clause << "SUBSTRING(options,4,1) = '0'"
    end

    # Mails hebdomadaire
    if filtre[:contact_hebdomadaire]
      where_clause << "SUBSTRING(options,5,1) = '1'"
    elsif filtre[:contact_quotidien]
      where_clause << "SUBSTRING(options,5,1) = '0'"
    end

    where_clause = where_clause.join(' AND ')

    request = "SELECT id, pseudo, mail, options FROM users WHERE #{where_clause}"
    db_exec(request).collect do |di|
      new(di)
    end
  end #/ select

  # OUT   Liste d'instances {Icarien} est icarien contactables qui veulent les
  #       informations hebdomadaires
  def who_want_hebdo_news
    @who_want_hebdo_news ||= select(contactable: true, contact_hebdomadaire: true)
  end #/ who_want_hebdo_news

  # OUT   Liste d'instances {Icarien} est icarien contactables qui veulent les
  #       informations quotidiennes
  def who_want_quotidien_news
    @who_want_quotidien_news ||= select(contactable: true, contact_quotidien: true)
  end #/ who_want_quotidien_news

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
def id; @id ||= data[:id] end
def pseudo; @pseudo ||= data[:pseudo] end
def mail; @mail ||= data[:mail] end
def options; @options ||= data[:options] end

end #/Icarien
