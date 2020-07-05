# encoding: UTF-8
=begin
  Gestion d'UN document
  Voir le module 'documents.rb' pour la gestion des listes de documents
=end
class IcDocument < ContainerClass
  attr_reader :data
  def initialize data
    @data = data
  end

  # ---------------------------------------------------------------------
  #   HELPERS
  # ---------------------------------------------------------------------
  def as_card
    <<-HTML.strip.freeze
<div id="document-#{id}" class="document">
  <img src="./img/icones/pdf.jpg" alt="Document original">
  #{block_comments if has_comments?}
  <div class="original-name">#{data[:original_name]}</div>

  <div class="tools">
    <div>
      [Pour redéfinir le partage]
    </div>
  </div>
</div>
    HTML
  end

  def block_comments
    <<-HTML.strip.freeze
<img src="./img/icones/pdf-comments.jpg" alt="Document commentaires">
    HTML
  end #/ block_comments
end
