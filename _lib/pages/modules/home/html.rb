# encoding: UTF-8
class HTML
  def titre
    "📚 Les Modules pédagogiques".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    require_module('absmodules')
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
      AbsModule.get_all
      liens_tdm = []
      listing = [7,12,6,4,2,10,11,3,5,8,9,1].collect do |module_id|
        absmod = AbsModule.get(module_id)
        liens_tdm << absmod.as_data_tdm
        absmod.out
      end.join
      tdm = FloatTdm.new(liens_tdm, {titre:"Tous les modules".freeze})
      {listing: listing, tdm:tdm.out}
    end
  end #/ listing_modules
end #/HTML
