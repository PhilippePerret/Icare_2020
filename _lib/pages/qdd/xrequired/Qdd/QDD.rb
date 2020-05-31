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
    if filtre.key?(:abs_etape_id)
      where << "abs_etape_id = #{filtre[:abs_etape_id]}".freeze
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
  if filtre.key?(:abs_etape_id)
    absetape = QddAbsEtape.get(filtre[:abs_etape_id])
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



# ---------------------------------------------------------------------
#   classe QddAbsEtape
#   -------------
#   Pour les étapes absolues
# ---------------------------------------------------------------------
class QddAbsEtape
class << self
  def get(id)
    id = id.to_i
    @items ||= {}
    @items[id] ||= begin
      new(db_get('absetapes', id, ['id', 'numero', 'titre', 'module_id']))
    end
  end #/ get
end
  attr_reader :id, :numero, :titre, :module_id
  def initialize data
    data.each {|k,v| self.instance_variable_set("@#{k}", v)}
  end #/ initialize
  def ref
    @ref ||= "#{titre} (n°#{numero})"
  end #/ ref
  def module
    @module ||= QddAbsModule.get(module_id)
  end #/ absmodule
end #/QddAbsEtape


class QddAbsModule
class << self
  def get(id)
    id = id.to_i
    @items ||= {}
    @items[id] ||= begin
      new(db_get('absmodules', id, ['id','name']))
    end
  end #/ get
end
  attr_reader :id, :name
  def initialize data
    @data = data
    data.each {|k,v| self.instance_variable_set("@#{k}", v)}
  end #/ initialize
end #/QddAbsModule
