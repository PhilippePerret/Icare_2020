# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
require_js_module(['flash','jquery'])
class HTML
  # Pour pouvoir définir le titre dans la fiche
  attr_accessor :titre
  # Juste pour que ce soit plus cours que ANNEE_CONCOURS_COURANTE
  attr_reader :annee
  # Instance du concurrent courant (if any — if param(:cid))
  attr_reader :concurrent
  # Instance du synopsis courant (if any - if param(:syno_id))
  attr_reader :synopsis

  def usefull_links
    if Evaluator.current?
      ADMIN_USEFULL_LINKS
    end
  end #/ usefull_links

  # Code à exécuter avant la construction de la page
  def exec
    if param(:view) == 'login'
      if param(:op) == 'login'
        Evaluator.authentify_evaluator
      end
    elsif param(:op) == 'logout'
      Evaluator.deconnect_evaluator
    elsif Evaluator.try_reconnect_evaluator
      add_js('./js/modules/ajax')
      require_xmodule('synopsis')
      require_xmodule('admin/constants')
      @annee      = ANNEE_CONCOURS_COURANTE
      @concurrent = Concurrent.get(param(:cid)) if param(:cid)
      if @concurrent && not(param(:synoid))
        param(:synoid, "#{@concurrent.id}-#{annee}")
      end
      @synopsis   = Synopsis.get(param(:synoid)) if param(:synoid)
      if @synopsis and not(@oncurrent)
        @concurrent = @synopsis.concurrent
      end

      case param(:view)
      when "synopsis_form"
        admin_required
        if param(:op) == 'save_synopsis'
          if param(:form_id) && Form.new.conform?
            synopsis.save(titre: param(:syno_titre), auteurs:param(:syno_auteurs), keywords:param(:syno_keywords))
            message("Données enregistrées avec succès.")
          end
        elsif param(:op) == 'set_non_conforme'
          synopsis.set_non_conforme(param(:motif), param(:motif_detailled))
        end
      else
        case param(:op)
        when 'mark_conforme'
          require_xmodule('admin/mark_fichier_conforme')
          synopsis.cfile.confirme_validite
        when 'exportfiches'
          require_xmodule('evaluation/export_fiches')
          message("Exportation des fiches…")
          Synopsis.exporter_les_fiches
        end
        check_up_to_date
      end
    end #/si c'est bien un évaluateur
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb("body/#{param(:view) || 'cartes_synopsis'}", self)
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
