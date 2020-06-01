# encoding: UTF-8
class HTML
  def titre
    "Les Modules pédagogiques".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    require_module('absmodules')
  end
  def build_body
    # Construction du body
    @body = <<-HTML
#{listing_modules}
    HTML
  end

  def listing_modules
    AbsModule.collect do |absmodule|
      absmodule.out
    end.join
  end #/ listing_modules
end #/HTML
