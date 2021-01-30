# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML
  attr_reader :concours
  def titre
    "Administration du concours"
  end #/titre

  def usefull_links
    ADMIN_USEFULL_LINKS
  end #/ usefull_links

  # Code à exécuter avant la construction de la page
  def exec
    admin_required
    require_xmodule('admin/constants')
    @concours = Concours.new(ANNEE_CONCOURS_COURANTE)
    run_operation(param(:op)) if param(:op)
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb("partials/#{param(:section)||'home'}", self)
  end # /build_body

  # IN    Opération à jouer
  # OUT   void
  def run_operation(op)
    if File.exists?(File.expand_path("#{__dir__}/operations/#{op}"))
      Dir["#{__dir__}/operations/#{op}/**/*.rb"].each{|m|require m}
      send(op.to_sym)
    else
      require_relative "../xmodules/admin/operations/#{op}"
      concours.send(op.to_sym)
    end
  end #/ run_operation

  def res
    @res ||= []
  end #/ res

  def resultat
    return nil if res.empty?
    <<-HTML
<form class="noform" method="POST">
  <input type="hidden" name="route" value="#{route}" />
#{res.join(BR)}
</form>
    HTML
  end #/ resultat

end #/HTML
