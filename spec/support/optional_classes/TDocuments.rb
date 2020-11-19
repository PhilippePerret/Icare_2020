# encoding: UTF-8
# frozen_string_literal: true
require_relative './TDocument'
class TDocuments
class << self
  attr_accessor :founds
  attr_accessor :error
  attr_accessor :raison_exclusion

  # Retourne tous les documents (icdocument, mais en tant que TDocument) qui
  # remplissent les documents +specs+
  # +specs+ Table Hash définissant les documents qu'on cherche
  # +options+
  #   :as_instances   Si true, on retourne la liste d'instances.
  #
  def find_all(specs, options = nil)
    options ||= {}
    wheres = []
    values = []
    if specs.key?(:after)
      wheres << "created_at > ?"
      values << specs.delete(:after)
    end
    if specs.key?(:before)
      wheres << "created_at < ?"
      values << specs.delete(:before)
    end
    # *** Toutes les autres specs doivent être des propriétés ***
    specs.each do |key, value|
      wheres << "#{key} = ?"
      values << value
    end

    request = "SELECT * FROM icdocuments WHERE #{wheres.join(AND)}"
    resultat = db_exec(request, values)
    if options[:as_instances]
      resultat.collect { |dd| TDocument.instantiate(dd) }
    else
      resultat
    end
  end #/ find_all

  def has_one?(specs)
    find_all(specs).count == 1
  end #/ has_one?

  def has?(specs)
    find_all(specs).count > 0
  end #/ has_document?
  alias :exists? :has?
  alias :has_item? :has?

end # /<< self
end #/TDocuments
