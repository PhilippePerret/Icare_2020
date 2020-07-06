# encoding: UTF-8
class QddAbsModule
class << self
  def get(id)
    id = id.to_i
    @items ||= {}
    @items[id] ||= begin
      new(db_get('absmodules', id, ['id','name','module_id']))
    end
  end #/ get
end
  # [1] Si on veut obtenir plus de données, il faut les ajouter aussi ci-dessus
  # dans la méthode ::get (mais si au final il les faut presque toutes, les
  # prendre presque toutes)
  attr_reader :id, :name, :module_id # ATTENTION => [1]
  def initialize data
    @data = data
    data.each {|k,v| self.instance_variable_set("@#{k}", v)}
  end #/ initialize
end #/QddAbsModule
