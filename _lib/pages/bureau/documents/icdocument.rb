# encoding: UTF-8
=begin
  Gestion d'UN document
  Voir le module 'documents.rb' pour la gestion des listes de documents
=end
class IcDocument
  attr_reader :data
  def initialize data
    @data = data
  end

  # ---------------------------------------------------------------------
  #   HELPERS
  # ---------------------------------------------------------------------
  def as_card
    <<-HTML
<div class="icdocument">
  <div class="original-name">
    #{data[:original_name]}
  </div>
</div>
    HTML
  end
end
