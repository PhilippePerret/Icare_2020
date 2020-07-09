# encoding: UTF-8
require_module('form')
class HTML
  def titre
    "Console d’administration".freeze
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    admin_required
    if param(:op) == 'evaluate'
      send("evaluate_as_#{param(:language)}")
    end
  end # /exec

  def evaluate_as_ruby
    @resultat = eval(param(:code).strip).to_s
  end #/ evaluate
  def evaluate_as_bash
    @resultat = `#{param(:code).strip}`
  end #/ evaluate_as_bash
  def evaluate_as_sql
    @resultat = db_exec(param(:code).strip).inspect
  end #/ evaluate_as_sql

  # Retourne le résultat de l'évaluation
  def resultat
    @resultat
  end #/ resultat

  # Fabrication du body
  def build_body
    @body = deserb(STRINGS[:body], self)
  end # /build_body

end #/HTML
