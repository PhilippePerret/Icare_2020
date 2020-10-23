# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
require_js_module(['flash','jquery'])
class HTML
  attr_reader :synopsis
  def titre
    titre = case param(:view)
    when "body_fiches_lecture"
      "Fiches de lecture"
    when "body_form_synopsis"
      "Édition du synopsis"
    else
      "Évaluation des synopsis"
    end
    "<span class='fright small'>#{opposite_link}</span>#{titre}"
  end #/titre

  def opposite_link
    case param(:view)
    when "body_fiches_lecture", "body_form_synopsis"
      Tag.link(route:"concours/evaluation", text:"➵ Évaluation des fiches", class:"discret")
    else
      Tag.link(route:"concours/evaluation?view=body_fiches_lecture", text:"➵ Fiches de lecture", class:"discret")
    end
  end #/ opposite_link


  # Code à exécuter avant la construction de la page
  def exec
    admin_required # TODO evaluators_required
    add_js('./js/modules/ajax')
    case param(:view)
    when "body_form_synopsis"
      args = param(:synoid).split('-')
      args << db_exec(Synopsis::REQUEST_SYNOPSIS, args).first
      @synopsis = Synopsis.new(*args)
      if param(:op) == 'save_synopsis' && user.admin?
        if param(:form_id) && Form.new.conform?
          synopsis.save(titre: param(:syno_titre), auteurs:param(:syno_auteurs), keywords:param(:syno_keywords))
          message("Données enregistrées avec succès.")
        end
      end
    else
      require_xmodule('evaluation/module_calculs')
      check_up_to_date
    end
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb(param(:view) || 'body_evaluation', self)
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
