# encoding: UTF-8
require_modules(['absmodules','form', 'user/helpers','icmodules'])
class HTML
  def titre
    "🗃️ Le Quai des Docs".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    log('-> exec')
    icarien_required
    if param(:form_id)
      form = Form.new
      traite_formulaire_search(form) if form.conform?
    else
      log(' pas de formulaire (dans exec)')
    end
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end

  def listing
    @listing # Peut être défini par `traite_formulaire_search`
  end #/ listing

  def traite_formulaire_search(form)
    require_folder('./_lib/pages/qdd/xrequired/Qdd')
    wheres = []
    values = []
    if param(:qdd_auteur)
      wheres << 'doc.user_id = ?'
      values << param(:qdd_auteur).to_i
    end
    if param(:qdd_module)
      wheres << 'absmod.id = ?'
      values << param(:qdd_module).to_i
    end
    after_date  = form.get_date('qdd_after').to_i
    wheres << 'doc.created_at >= ?'
    values << after_date
    before_date = form.get_date('qdd_before').to_i
    wheres << "doc.created_at < ?"
    values << before_date
    # IL faut forcément que le document soit partagé
    wheres << "( SUBSTRING(doc.options,2,1) = '1' OR SUBSTRING(doc.options,10,1) = '1' )"

    # Pour la clé de classement
    sortedkey = case param(:qdd_key_order)
    when 'name'       then 'doc.original_name'
    when 'created_at' then 'doc.created_at'
    when 'pertinence' then 'pertinence'
    end

    MyDB.DBNAME = 'icare' if OFFLINE

    # On fabrique la requête
    request = <<-SQL
SELECT
  doc.id, doc.original_name, doc.user_id, doc.options,
  doc.updated_at, doc.time_original, doc.time_comments,
  doc.icetape_id,
  abset.id AS absetape_id,
  lect.icdocument_id,
  AVG(lect.cote_original) + AVG(lect.cote_comments) AS pertinence
  FROM icdocuments AS doc
  INNER JOIN icetapes AS icet ON doc.icetape_id = icet.id
  INNER JOIN absetapes AS abset ON abset.id = icet.absetape_id
  INNER JOIN absmodules AS absmod ON absmod.id = abset.absmodule_id
  INNER JOIN lectures_qdd AS lect ON lect.icdocument_id = doc.id
  WHERE #{wheres.join(' AND ')}
  GROUP BY lect.icdocument_id
  ORDER BY #{sortedkey}
    SQL
    log("+++ request: #{request}")
    founds = db_exec(request, values)
    if MyDB.error
      log(MyDB.error)
      erreur("ERREUR SQL: #{MyDB.error[:error]}")
    else
      log("+++ founds: #{founds.inspect}")
      message "Nombre de documents correspond à la recherche : #{founds&.count}"
      @listing = founds.collect do |found|
        # doc = IcDocument.instantiate(found)
        doc = QddDoc.new(found)
        doc.cards
      end.join
    end
    MyDB.DBNAME = 'icare_test' if OFFLINE

  end #/ traite_formulaire_search


end #/HTML
