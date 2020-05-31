# encoding: UTF-8
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
  documents_filtred.collect do |doc|
    doc.cards
  end.join
end #/ documents_filtred_formated

# Liste des documents (instances {QddDoc}) filtrés
def documents_filtred
  @documents_filtred ||= begin
    where = ['( options LIKE \'2%\' OR options LIKE \'_________2%\' )'.freeze]
    if filtre.key?(:absetape_id)
      where << "absetape_id = #{filtre[:absetape_id]}".freeze
    end

    where = where.join(' AND ')
    request = "SELECT * FROM icdocuments WHERE #{where}"
    db_exec(request).collect do |ddoc|
      QddDoc.new(ddoc)
    end
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
            {text:"Aucun filtre appliqué".freeze, class:'small italic'}
          else
            {text:divRow('Filtre appliqué', f.join(VG)), class:'mb2'}
          end
  Tag.div(data)
end #/ filtre_formated
end #/QDD
