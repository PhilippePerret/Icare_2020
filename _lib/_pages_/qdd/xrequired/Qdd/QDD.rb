# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class QDD
  ---------
  Pour la gestion du Quai des docs
=end
class QDD
  class << self

  end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :filtre
def filtre= filtre
  @filtre = filtre
end #/ filtre=

# Retourne l'affichage des documents filtrés
def documents_filtred_formated
  cards = []
  documents_filtred.each do |ddoc|
    doc, doctype = ddoc
    cards << doc.card(doctype)
  end
  cards.join
end #/ documents_filtred_formated

# Liste des documents (instances {QddDoc}) filtrés
#
# Note : cette méthode est très stricte : elle ne tient compte que
# des documents qui existent vraiment et ne présente jamais de documents
# qui n'ont pas de fichier PDF. La seule exception concerne le cas où le
# document commentaire n'existe pas (!pdf_exists?(:comments)), que l'original
# existe mais qu'il n'est pas partagé.
def documents_filtred
  @documents_filtred ||= begin
    # On commence par faire une liste des documents qui sont partagés,
    # originaux ou commentaires.
    where = ['( SUBSTRING(doc.options,1,1) = "1" OR SUBSTRING(doc.options,9,1) = "1")']
    if filtre.key?(:absetape_id)
      where << "eta.id = #{filtre[:absetape_id]}"
    end
    where = where.join(AND)
    request = <<-SQL
SELECT *
FROM icdocuments doc
INNER JOIN icetapes eta ON doc.icetape_id = eta.id
WHERE #{where}
    SQL
    log("request: #{request.inspect}")
    candidats = db_exec(request)
    liste_qdocs_ok = []
    candidats.each do |ddoc|
      qdoc = QddDoc.new(ddoc)
      # On vérifie que les fichiers PDF existent, au moins un
      original_existe = qdoc.pdf_exists?(:original)
      comments_existe = qdoc.pdf_exists?(:comments)
      original_shared = qdoc.shared?(:original)
      comments_shared = qdoc.shared?(:comments)
      if original_existe && (original_shared || !comments_existe)
        liste_qdocs_ok << [qdoc, :original]
      end
      if comments_existe && comments_shared
        liste_qdocs_ok << [qdoc, :comments]
      end
    end
    liste_qdocs_ok
  end
end #/ documents_filtred

# Retourne le filtre appliqué formaté
def filtre_formated
  f = []
  if filtre.key?(:absetape_id)
    absetape = QddAbsEtape.get(filtre[:absetape_id])
    f << "Étape « #{absetape.titre} » (n°#{absetape.numero})  du module #{absetape.module.name}."
  end

  data =  if f.empty?
            {text:"Aucun filtre appliqué", class:'small italic'}
          else
            {text:divRow('Filtre appliqué', f.join(VG)), class:'mb2'}
          end
  Tag.div(data)
end #/ filtre_formated
end #/QDD
