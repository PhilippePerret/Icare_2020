# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class ContainerClass
  --------------------
  La classe abstraite des Icmodules, AbsModules, IcEtapes, etc.
=end
require_relative 'helpers/string_helpers_module' # => StringHelpersMethods
class ContainerClass

  # Les méthodes d'helpers
  include StringHelpersMethods

  DEFAULT_DATA = {id:nil}

  class << self
    def get item_id
      item_id || raise("Il faut fournir l'ID")
      item_id = item_id.to_i
      @items ||= {}
      @items.key?(item_id) || @items.merge!(item_id => new(item_id))
      @items[item_id]
    end #/ get

    # Permet d'instancier un objet avec les données (entendu qu'avec les
    # ContainerClass on les instancie avec l'identifiant seulement)
    # Note : si l'item est déjà connu, c'est lui qu'on prend (on utilise `get`
    # plutôt que `new`, maintenant)
    def instantiate data
      unless data[:id].nil? # création d'une instance
        if @items&.key?(data[:id])
          return @items[data[:id]]
        else
          obj = get(data[:id])
        end
      else
        obj = new(nil)
      end
      obj.data = data
      return obj
    end #/ instantiate

    # Création d'une nouvelle donnée avec les données fournies
    # Retourne l'instance créée.
    def create_with_data(data)
      log("-> ContainerClass::create_with_data(#{data.inspect})")
      now = Time.now.to_i
      data.merge!({created_at:now.to_s, updated_at:now.to_s})
      new_id = db_compose_insert(table, data)
      return get(new_id)
    end #/ create_with_data

    # Charge tous les items en appliquant le filtre +filtre+ si défini
    # Les mets dans @items en réinitialisant la liste si +reset_items+ est
    # true et la renvoie.
    # @alias : find
    # @retourne : Table Hash avec l'identifiant en clé
    def find(filtre = nil, reset_items = false)
      @items = {} if reset_items
      @items ||= {}
      where = where_clausize(filtre)
      cmd   = "SELECT * FROM #{table}#{where}"
      db_exec(cmd).each do |ditem|
        item = new(ditem[:id])
        item.data= ditem
        @items.merge!(item.id => item)
      end
      return @items
    end #/ get_all
    alias :get_all :find

    # Pour pouvoir utiliser la méthode <classe>.collect qui va boucler
    # sur tous les éléments. Noter que cette méthode instancie TOUS les
    # éléments de la base de données, donc il faut y aller mollo.
    # IN    options   Table d'options
    #                 :raw      Si true, on ne renvoie pas des instances mais
    #                           des tables de données telles que renvoyées par
    #                           db_exec
    def collect(filtre = nil, options = nil)
      order_by = filtre && (filtre.delete(:order) || filtre.delete(:order_by))
      where = where_clausize(filtre)
      where = "#{where} ORDER BY #{order_by}" unless order_by.nil?
      begin
        allcollect = db_exec("SELECT * FROM #{table}#{where}")
      rescue MyDBError => e
        erreur(e.message)
        return []
      end
      if options && options[:raw]
        allcollect.collect do |ditem|
          yield ditem
        end
      else
        allcollect.collect do |ditem|
          item = new(ditem[:id])
          item.data = ditem
          yield item
        end
      end
    end #/ collect

    def get_instances(filtre = nil)
      self.collect(filtre) { |item| item }
    end #/ get_instances

    # Retourne le nombre d'éléments répondant au filtre +filtre+. Si +filtre+
    # est nil, retourne le nombre total d'éléments.
    def count(filtre = nil)
      return db_count(table, filtre)
    end #/ count

    def each(filtre = nil)
      where = where_clausize(filtre)
      request = "SELECT * FROM #{table}#{where}"
      begin
        alleach = db_exec(request)
      rescue MyDBError => e
        erreur(e.message)
        return []
      end
      alleach.each do |ditem|
        item = new(ditem[:id])
        item.data = ditem
        yield item
      end
    end #/ each

    def each_with_index(filtre = nil)
      where = where_clausize(filtre)
      request = "SELECT * FROM #{table}#{where}"
      begin
        result = db_exec(request)
      rescue MyDBError => e
        erreur(e.message)
        return
      end
      result.each_with_index do |ditem, idx|
        item = new(ditem[:id])
        item.data = ditem
        yield item, idx
      end
    end #/ each

    private

      def where_clausize filtre
        return '' if filtre.nil? || filtre.empty?
        if filtre.is_a?(Hash)
          if filtre.key?(:where)
            filtre = filtre[:where]
          else
            # Étude complexe du filtre
            filtre = filtre.collect do |k,v|
              case k
              when :created_after
                "created_at > #{v}"
              when :created_before
                "created_at < #{v}"
              when :updated_after
                "updated_at > #{v}"
              when :updated_before
                "updated_at < #{v}"
              when :ended_after
                "ended_at > #{v}"
              when :ended_before
                "ended_at < #{v}"
              else
                "#{k} = #{v.inspect}"
              end
            end.join(AND)
          end
        end
        return " WHERE #{filtre}"
      end #/ where_clausize

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
    return data[method_name] if data&.key?(method_name)
    if self.respond_to?(:absdata) && method_name.to_s == objet_class&.downcase
      @objet = Object.const_get(objet_class).get(data[:objet_id])
    else
      log("-- [method_missing (#{self.class.name}##{method_name})] data vaut: #{data.inspect}")
      raise "Méthode manquante : #{self.class.name}##{method_name} (voir data dans le journal)"
    end
  end #/ method_missing

  def f_id
    @f_id ||= user.admin? ? "#{ISPACE}<span class='small'>(##{id})</span>" : EMPTY_STRING
  end #/ f_id

  def data
    @data ||= db_get(self.class.table, {id: id})
  end #/ data

  # Pour certaines classes comme les travaux-type ou quand on utilise
  # les méthodes de classe collect ou each
  def data= values
    @data = values
  end #/ data=


  def exists?
    @data != nil || db_count(self.class.table, {id: id}) == 1
  end #/ exists?

  # Retourne le propriétaire ({User}) si user_id est défini
  def owner
    @owner ||= begin
      User.get(user_id) if data.key?(:user_id)
    end
  end #/ owner
  def owner= u
    @owner = u
  end #/ owner=

  def get(key)
    return data[key.to_sym]
  end #/ get

  def save(new_data)
    new_data = {new_data => get(new_data)} if new_data.is_a?(Symbol)
    begin
      db_compose_update(self.class.table, id, new_data)
    rescue MyDBError => e
      raise e
    end
    # On peut affecter les nouvelles valeurs à l'instance
    new_data.each { |k, v| self.data[k] = v }
  end #/ save
  alias :set :save # def set

  # Pour détruire la donnée dans la base de données
  def destroy
    db_exec("DELETE FROM `#{self.class.table}` WHERE id = #{id}")
  end #/ destroy

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
    data || begin
      erreur("Les data ne sont pas définies pour #{self.class}##{id}, je renvoie 0 mais il faudra résoudre ce problème.")
      # TODO Envoyer un mail d'erreur à l'administrateur
      return 0
    end
    data[:options] ||= begin
      erreur("Les options sont indéfinies pour #{self.class}##{id}. Je les mets à 0 mais le problème est à résoudre.")
      # TODO Envoyer un mail d'erreur à l'administrateur
      '0'.ljust(bit,'0')
    end
    data[:options][bit].to_i
  end #/ option
  alias :get_option :option # pour être cohérent avec :set_option

  # Retourne true si le bit +bit+ est à 1 (et seulement à 1)
  def option?(bit)
    option(bit) === 1
  end #/ option?

  # Définit la valeur de bit de l'option et l'enregistre si nécessaire
  # +params+
  #   :save     true/false      default: true
  def set_option(bit, value, params = nil)
    params ||= {}
    params.key?(:save) || params.merge!(save: true)
    data[:options] = data[:options].ljust(bit+1,'0') unless data[:options].length > bit
    data[:options][bit] = value.to_s
    save(options: data[:options]) if params[:save]
    @options = nil
  end #/ set_option
end #/ContainerClass
