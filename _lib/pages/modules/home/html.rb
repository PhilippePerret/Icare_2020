# encoding: UTF-8
class HTML
  def titre
    "📚 Les Modules pédagogiques".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    require_modules(['absmodules', 'minifaq'])
    case param(:ope)
    when 'minifaq-add-question' then MiniFaq.add_question
    end
  end
  def build_body
    # Construction du body
    @body = <<-HTML
#{listing_modules[:tdm]}
#{listing_modules[:listing]}
    HTML
  end

  def listing_modules
    @listing_modules ||= begin
      pictos = ['📕', '📔', '📗', '📘', '📙', '📒']
      ipicto = 0
      nbpictos = pictos.count
      AbsModule.get_all
      liens_tdm = []
      listing   = []
      ordre_modules = [7,12,6,4,2,10,11,3,5,8,9,1]
      ordre_modules.each_with_index do |module_id, idx|
        absmod = AbsModule.get(module_id)
        liens_tdm << absmod.as_data_tdm
        picto = pictos[ipicto]
        ipicto += 1
        ipicto = 0 unless ipicto < nbpictos
        listing << absmod.out(picto: picto, next: ordre_modules[idx+1])
      end.join
      tdm = FloatTdm.new(liens_tdm, {titre:"Tous les modules".freeze})
      {listing: listing.join, tdm:tdm.out}
    end
  end #/ listing_modules
end #/HTML
