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

# Retourne le filtre appliqué formaté
def filtre_formated
  f = []
  if filtre.key?(:abs_etape_id)
    absetape = QddAbsEtape.get(filtre[:abs_etape_id])
    f << "Étape « #{absetape.titre} » (n°#{absetape.numero})  du module #{absetape.module.name}."
  end

  if f.empty?
    Tag.div(text:"Aucun filtre appliqué".freeze, class:'small italic')
  else
    Tag.div(divRow('Filtre appliqué', f.join(VG)))
  end
end #/ filtre_formated


end #/QDD

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
