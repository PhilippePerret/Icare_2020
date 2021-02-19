# encoding: UTF-8
# frozen_string_literal: true
=begin

  Helper pour générer les balises HTML
  ------------------------------------
  tbl = HTMLHelper::Table.new(id: 'ma-table')
  tbl << ['titre col 1', 'titre col 2'] # 1ère ligne => titre
  tbl << ['valeur 1', 'valeur 2']
  ...
  tbl.output

=end
module HTMLHelper

  class HTMLTag
    attr_reader :attrs, :inner
    def initialize(attrs = nil)
      @attrs = attrs
    end #/ initialize

    # La sortie
    def output
      "<#{tag}#{attributes}>#{inner.join}#{close_tag}"
    end
    def attributes
      ' ' + attrs.collect { |k,v| "#{k}='#{v}'" }.join(' ') if attrs
    end #/ attributes
    def close_tag ; "</#{tag}>" end
  end

  class Table < HTMLTag
    def initialize(data = nil)
      super(data)
    end
    def tag ; 'table' end
    def close_tag ; '</tbody></table>' end
    # Pour ajouter des rangées (ou la ligne de titre si première)
    def <<(cells)
      is_titre = @inner.nil?
      tdtag = is_titre ? 'th' : 'td'
      @inner ||= []
      @inner << '<thead>' if is_titre
      @inner << "<tr>#{cells.collect{|c| "<#{tdtag}>#{c}</#{tdtag}>"}.join}</tr>"
      @inner << '</thead><tbody>' if is_titre
    end
  end #/Table
end
