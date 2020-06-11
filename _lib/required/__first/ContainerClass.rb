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

    # Permet d'instancier un objet avec les données (entendu qu'avec les
    # ContainerClass on les instancie avec l'identifiant seulement)
    def instantiate data
      obj = new(data[:id])
      obj.data = data
      return obj
    end #/ instantiate

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
    # log("-> method_missing(#{method_name.inspect})")
    # log("   data : #{data.inspect}")
    return data[method_name] if data.key?(method_name)
    if self.respond_to?(:absdata) && method_name.to_s == objet_class&.downcase
      @objet = Object.const_get(objet_class).get(data[:objet_id])
    else
      raise "Méthode manquante : #{self}##{method_name}"
    end
  end #/ method_missing

  def f_id
    @f_id ||= user.admin? ? "<span class='small'>(##{id})</span>".freeze : EMPTY_STRING
  end #/ f_id

  def data
    @data ||= db_get(self.class.table, {id: id})
  end #/ data

  def exists?
    @data != nil || db_count(self.class.table, {id: id}) == 1
  end #/ exists?

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
  alias :set :save # def set

  # Date formatée de démarrage
  def f_started_at
    @f_started_at ||= formate_date(data[:started_at])
  end #/ f_started_at

  # Date formatée de fin
  def f_ended_at
    @f_ended_at ||= formate_date(data[:ended_at])
  end #/ f_started_at

  # Les objets ont souvent des options, on leur offre des méthodes qui
  # permettent de les gérer

  # Retourne {Integer} la valeur du bit +bit+ des options
  def option(bit)
    data[:options][bit].to_i
  end #/ option
  alias :get_option :option # pour être cohérent avec :set_option

  # Définit la valeur de bit de l'option et l'enregistre si nécessaire
  def set_option(bit, value, saving = false)
    data[:options][bit] = value.to_s
    save(options: data[:options]) if saving
  end #/ set_option
end #/ContainerClass
