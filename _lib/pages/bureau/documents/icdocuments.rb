# encoding: UTF-8
=begin
  Gestion des LISTES de documents

  Voir le module 'document.rb' pour la gestion d'UN document
=end
class IcDocuments
  
  attr_reader :owner
  def initialize user
    @owner = user
  end

  # Pour pouvoir utiliser user.documents.collect ...
  def collect &block
    items.collect do |idoc|
      yield idoc
    end
  end

  # Pour pouvoir utiliser user.documents.each ...
  def each &block
    items.each do |idoc|
      yield idoc
    end
  end

  # Retourne la liste des instances IcDocument des documents de l'icarien
  def items
    @items ||= begin
      request = "SELECT * FROM icdocuments WHERE user_id = #{owner.id}"
      db_exec(request).collect do |ddoc|
        IcDocument.new(ddoc)
      end
    end
  end
end
