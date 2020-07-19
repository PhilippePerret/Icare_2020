# encoding: UTF-8
=begin
  Class CJActualites
  ------------------
  Gestion des actualités
=end
class CJActualites
class << self

  def mail_quotidien
    puts "* Production et envoi du mail quotidien"
    if actualites_veille.count == 0
      return rapport("Pas d'actualité de la veille => Pas de mail quotidien d'actualité")
    else
      rapport("Nombre d'actualités pour la veille : #{actualites_veille.count}")
    end
    # Y a-t-il de nouvelles actualités ?
    # TODO
    # Construire le mail d'actualités
    # TODO
    # Envoyer le mail à l'administrateur
    # TODO
    CJUser.each do |cuser|
      next if cuser.destroyed?
      next unless cuser.mail_quotidien?
      # puts "Je vais envoyer le mail quotidien à #{cuser.pseudo}"
    end
  end #/ mail_quotidien

  def mail_hebdomadaire
    rapport "* Production et envoi du mail hebdomadaire"
    if actualites_semaine.count == 0
      return rapport("Aucune actualité pour la semaine passée")
    else
      rapport("Nombre d'actualités pour la semaine passée : #{actualites_semaine.count}")
    end
    # TODO Il m'est toujours envoyé
    CJUser.each do |cuser|
      next if cuser.destroyed?
      next unless cuser.mail_hebdomadaire?
    end
  end #/ mail_hebdomadaire

  # Tous les users qui possèdent des actualités de la veille
  def owners_veille
    @owners_veille ||= {}
  end #/ owners_veille

  def add_owners_veille(owner)
    return if owners_veille.key?(owner.id)
    owners_veille.merge!(owner.id => owner)
  end #/ add_owners_veille

  # Tous les users qui possèdent des actualités de la semaine passée
  def owners_hebdo
    @owners_hebdo ||= {}
  end #/ owners_hebdo
  def add_owners_hebdo(owner)
    return if owners_hebdo.key?(owner.id)
    owners_hebdo.merge!(owner.id => owner)
  end #/ add_owners_hebdo

  # Retourne les actualités de la veille
  def actualites_veille
    @actualites_veille ||= begin
      request = <<-SQL.strip.freeze
  SELECT id, user_id, message, type, created_at
    FROM actualites
    WHERE created_at > #{Time.veille.to_i}
    ORDER BY user_id
      SQL
      db_exec(request).collect { |dactu| new(dactu, :veille) }
    end
  end #/ actualites_veille

  def actualites_semaine
    @actualites_semaine ||= begin
      from_time = NOW_S - 7.days
      request = <<-SQL.strip.freeze
  SELECT user_id, message, type, created_at
    FROM actualites
    WHERE created_at > #{from_time}
    ORDER BY user_id
      SQL
      db_exec(request).collect { |dactu| new(dactu, :hebdo) }
    end
  end #/ actualites_semaine


  # Retourne

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :id, :user_id, :type, :message, :created_at
def initialize data, ttype # ttype = :veille ou :hebdo
  data.each { |k,v| instance_variable_set("@#{k}",v) }
  # On ajoute l'actualité à l'user
  @ttype = ttype
  owner.send("add_actualite_#{ttype}".to_sym, self)
  self.class.send("add_owners_#{ttype}".to_sym, owner)
  # On ajoute ce propriétaire à la liste des propriétaires qui ont des
  # actulités

end #/ initialize
def owner
  @owner ||= CJUser.get(user_id)
end #/ owner
end #/CJActualites
