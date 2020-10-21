# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML
  def titre
    "Estimation des synopsis"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    admin_required # TODO evaluators_required
    check_up_to_date
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

  # Méthode qui s'assure que tout soit à jour (pour ne pas tout refaire
  # chaque fois, à commencer par la check list)
  def check_up_to_date
    if not File.uptodate?(PARTIAL_CHECK_LIST, [DATA_CHECK_LIST_FILE, REBUILDER_CHECK_LIST])
      require_xmodule('evaluation/rebuild_checklist.rb')
      FicheLecture.rebuild_checklist
    end
  end #/ check_up_to_date

end #/HTML
