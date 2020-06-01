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

    # Charge tous les items en appliquant le filtre +filtre+ si défini
    # Les mets dans @items en réinitialisant la liste si +reset_items+ est
    # true et la renvoie.
    def get_all(filtre = nil, reset_items = false)
      @items = {} if reset_items
      @items ||= {}
      filtre = " WHERE #{filtre}".freeze unless filtre.nil?
      db_exec("SELECT * FROM #{table}#{filtre}".freeze).each do |ditem|
        item = new(ditem[:id])
        item.data = ditem
        @items.merge!(item.id => item)
      end
      return @items
    end #/ get_all

    # Pour pouvoir utiliser la méthode <classe>.collect qui va boucler
    # sur tous les éléments. Noter que cette méthode instancie TOUS les
    # éléments de la base de données, donc il faut y aller mollo.
    def collect(filtre = nil)
      filtre = " WHERE #{filtre}".freeze unless filtre.nil?
      db_exec("SELECT * FROM #{table}#{filtre}".freeze).collect do |ditem|
        item = new(ditem[:id])
        item.data = ditem
        yield item
      end
    end #/ collect

    def each(filtre)
      filtre = " WHERE #{filtre}".freeze unless filtre.nil?
      db_exec("SELECT * FROM #{table}#{filtre}".freeze).each do |ditem|
        item = new(ditem[:id])
        item.data = ditem
        yield item
      end
    end #/ each

    def each_with_index(filtre)
      filtre = " WHERE #{filtre}".freeze unless filtre.nil?
      db_exec("SELECT * FROM #{table}#{filtre}".freeze).each_with_index do |ditem, idx|
        item = new(ditem[:id])
        item.data = ditem
        yield item, idx
      end
    end #/ each

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

  # Pour certaines classes comme les travaux-type ou quand on utilise
  # les méthodes de classe collect ou each
  def data= values
    @data = values
  end #/ data=

  # Retourne le propriétaire ({User}) si user_id est défini
  def owner
    @owner ||= begin
      User.get(user_id) if data.key?(:user_id)
    end
  end #/ owner

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
