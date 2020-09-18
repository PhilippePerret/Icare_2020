# encoding: UTF-8
# frozen_string_literal: true
require_module('qdd')

class HTML

  def traite_formulaire_search(form)
    require_folder("#{FOLD_REL_PAGES}/qdd/xrequired/Qdd")

    MyDB.DBNAME = 'icare' if OFFLINE

    # On fabrique la requête et on la soumet
    request, values, specs = build_request(form)
    begin
      founds = db_exec(request, values)
    rescue MyDBError => e
      raise e
    end

    @count = founds.count

    # Spécificités de la recherche (paramètres)
    message_nombre = if founds.count > 0
      Tag.div(text:"NOMBRE DE DOCUMENTS DIFFÉRENTS#{ISPACE}: #{founds.count}", class:'small mb2 blue bold')
    else
      Tag.div(text:'DÉSOLÉ, AUCUN DOCUMENT TROUVÉ.', class:'small mb2 red bold')
    end
    @specs =
    Tag.div(text:"SPÉCIFICITÉS DE LA RECHERCHE#{ISPACE}: #{specs.join(VG)}.", class:'small mt2 mb1') +
    Tag.div(text:"<a href='qdd/home'>Autre recherche</a>", class:'right')+
    message_nombre

    if founds.count == 0
      @listing = Tag.div(text:MESSAGES[:no_document_with_params], class:'explication')
    else
      @listing = founds.collect do |found|
        doc = QddDoc.new(found) # BUG
        doc.cards
      end.join
    end

    MyDB.DBNAME = 'icare_test' if OFFLINE

  end #/ traite_formulaire_search

  # Construction de la requête qui va retourner la liste des
  # documents
  def build_request(form)
    wheres = []
    values = []
    specs = [] # pour le message
    if param(:qdd_auteur)
      user_id = param(:qdd_auteur).to_i
      wheres << 'doc.user_id = ?'
      values << user_id
      specs << "documents de #{User.get(user_id).pseudo}"
    end
    if param(:qdd_module)
      absmodule_id = param(:qdd_module).to_i
      wheres << 'absmod.id = ?'
      values << absmodule_id
      specs << "documents du module #{AbsModule.get(absmodule_id).name}"
    end
    after_date  = form.get_date('qdd_after').to_i
    wheres << 'doc.created_at >= ?'
    values << after_date

    before_date = form.get_date('qdd_before').to_i
    wheres << "doc.created_at < ?"
    values << before_date

    specs << "créés après le #{formate_date(after_date)} et avant le #{formate_date(before_date)}"


    # IL faut forcément que le document soit partagé
    wheres << "( SUBSTRING(doc.options,2,1) = '1' OR SUBSTRING(doc.options,10,1) = '1' )"

    # Pour la clé de classement
    sortedkey = case param(:qdd_key_order)
    when 'name'
      specs << "classés par nom"
      'doc.original_name'
    when 'created_at'
      specs << "classés par date"
      'doc.created_at'
    when 'pertinence'
      specs << "classés par pertinence (notes attribués par les lecteurs)"
      'pertinence'
    end

    limit = case param(:qdd_limit)
    when 'all'
      specs << "tous les documents"
      ''
    else
      specs << "limiter la recherche à #{param(:qdd_limit)} documents"
      " LIMIT #{param(:qdd_limit)}"
    end

    request = <<-SQL
SELECT
  doc.id, doc.original_name, doc.user_id, doc.options,
  doc.updated_at, doc.time_original, doc.time_comments,
  doc.icetape_id,
  abset.id AS absetape_id,
  lect.icdocument_id,
  AVG(lect.cote_original) + AVG(lect.cote_comments) AS pertinence
  FROM `icdocuments` AS doc
  INNER JOIN `icetapes` AS icet ON doc.icetape_id = icet.id
  INNER JOIN `absetapes` AS abset ON abset.id = icet.absetape_id
  INNER JOIN `absmodules` AS absmod ON absmod.id = abset.absmodule_id
  INNER JOIN `lectures_qdd` AS lect ON lect.icdocument_id = doc.id
  WHERE #{wheres.join(' AND ')}
  GROUP BY lect.icdocument_id
  ORDER BY #{sortedkey}
    SQL

    return [request, values, specs]
  end #/ build_request

end #/HTML
