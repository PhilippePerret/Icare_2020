# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
require_js_module(['flash','jquery'])
class HTML
  def titre
    "Estimation des synopsis"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    admin_required # TODO evaluators_required
    add_js('./js/modules/ajax')
    require_xmodule('evaluation/module_calculs')
    check_up_to_date
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

  # Méthode qui s'assure que tout soit à jour (pour ne pas tout refaire
  # chaque fois, à commencer par la check list)
  def check_up_to_date
    if not File.uptodate?(PARTIAL_CHECKLIST, [CHECKLIST_TEMPLATE, DATA_CHECK_LIST_FILE, REBUILDER_CHECK_LIST])
      require_xmodule('evaluation/rebuild_checklist.rb')
      CheckList.rebuild_checklist
    end
  end #/ check_up_to_date

end #/HTML