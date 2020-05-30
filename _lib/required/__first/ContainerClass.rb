# encoding: UTF-8
=begin
  Class ContainerClass
  --------------------
  La classe abstraite des Icmodules, AbsModules, IcEtapes, etc.
=end
class ContainerClass
  class << self
    def get item_id
      item_id || raise("Il faut fournir l'ID".freeze)
      item_id = item_id.to_i
      @items ||= {}
      @items.key?(item_id) || @items.merge!(item_id => new(item_id))
      @items[item_id]
    end #/ get
  end # /<< self

  # ---------------------------------------------------------------------
  #
  #   INSTANCE
  #
  # ---------------------------------------------------------------------
  attr_reader :id
  attr_reader :data
  def initialize id
    @id = id
  end #/ initialize

  def bind
    binding()
  end #/ bind

  def method_missing method_name, *args, &block
    return data[method_name] if data.key?(method_name)
    raise "Méthode manquante : #{self}##{method_name}"
  end #/ method_missing

  def data
    @data ||= db_get(self.class.table, {id: id})
  end #/ data

  # Pour certaines classes comme les travaux-type
  def data= values
    @data = values
  end #/ data=

  def get(key)
    return data[key.to_sym]
  end #/ get

  def save(new_data)
    columns = new_data.keys.collect{|c| "#{c} = ?"}.join(VG)
    values  = new_data.values << id
    request = "UPDATE #{self.class.table} SET #{columns} WHERE id = ?"
    db_exec(request, values)
    # On peut affecter les nouvelles valeurs à l'instance
    new_data.each { |k, v| self.data[k] = v }
  end #/ save

  # Date formatée de démarrage
  def f_started_at
    @f_started_at ||= formate_date(data[:started_at])
  end #/ f_started_at

  # Date formatée de fin
  def f_ended_at
    @f_ended_at ||= formate_date(data[:ended_at])
  end #/ f_started_at
end #/ContainerClass
