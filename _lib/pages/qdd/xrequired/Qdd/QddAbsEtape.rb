# encoding: UTF-8
# ---------------------------------------------------------------------
#   classe QddAbsEtape
#   -------------
#   Pour les étapes absolues
# ---------------------------------------------------------------------
class QddAbsEtape
class << self
  def get(id)
    raise "ID d'AbsEtape indéfini" if id.nil? || id == 0
    id = id.to_i
    @items ||= {}
    @items[id] ||= begin
      new(db_get('absetapes', id, ['id', 'numero', 'titre', 'absmodule_id']))
    end
  end #/ get
end
  attr_reader :id, :numero, :titre, :absmodule_id
  def initialize data
    data.each {|k,v| self.instance_variable_set("@#{k}", v)}
  end #/ initialize
  def ref
    @ref ||= "#{titre} (n°#{numero})"
  end #/ ref
  def module
    @module ||= QddAbsModule.get(absmodule_id)
  end #/ absmodule
end #/QddAbsEtape
