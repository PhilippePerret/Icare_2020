# encoding: UTF-8
require 'mysql2'

# L'erreur qui sera levée en cas d'erreur de la méthode db_exec, pour
# ne plus avoir à utiliser tout le temps if MyDB.error
class MyDBError < StandardError
  attr_reader :data

  def initialize(data)
    @data = data
    trace_db_error
  end #/ initialize

  def trace_db_error
    err_msg = <<-TXT
ERREUR MYSQL - Impossible d'exécuter la requête suivante :
############################################################
# MYSQL ERROR : #{data[:error]}
# REQUEST : #{data[:request]}
# VALUES : #{data[:values].inspect}
############################################################
    TXT
    log(err_msg)
    if defined?(user) && user.admin?
      erreur(err_msg)
    end
  end #/ trace_db_error

  # S'il faut vraiment afficher un message. Mais normalement,
  # on traitement simplement l'erreur, silencieusement (sauf
  # pour l'administrateur)
  def message
    "Une erreur SQL est survenue. Impossible d’exécuter la requête."
  end #/ message

end #/MyDBError < StandardError

SANDBOX = false unless defined?(SANDBOX)
# On line ou off line
# -------------------
# Par défaut, et pour éviter les erreurs, on considère que si ONLINE n'est
# pas défini, on est offline. Ajouter ONLINE = true dans le module utilisant
# ce module, avant le require, pour changer ce comportement.
ONLINE = false unless defined?(ONLINE)

unless defined?(DATA_MYSQL)
  require './_lib/data/secret/mysql'
end

# = main method =
#
# Méthode principale qui permet d'exécuter une requête, de retourner le
# résultat ou de lever une exception MyDBError
#
def db_exec request, values = nil
  request = request.strip
  while request.end_with?(';')
    request = request[0...-1]
  end
  if request =~ /;/
    request = request.split(PV).collect{|i|i.strip}.reject { |i| i.to_s.empty? }
  end
  begin
    res = MyDB.db.execute(request, values)
    raise MyDBError.new(MyDB.error) if MyDB.error
    return res
  rescue Exception => e
    raise MyDBError.new(error:e, request:request, values:values)
  end
end



# Pour insérer (INSERT) de façon simple (cf. le manuel)
REQUEST_INSERT = 'INSERT INTO %{table} (%{columns}) VALUES (%{interro})'.freeze
def db_compose_insert table, data
  data.merge!(created_at:Time.now.to_i.to_s) unless data.key?(:created_at)
  data.merge!(updated_at:Time.now.to_i.to_s) unless data.key?(:updated_at)
  valeurs = data.values
  columns = data.keys.join(VG)
  interro = Array.new(valeurs.count,'?').join(VG)
  request = REQUEST_INSERT % {table:table, columns: columns, interro: interro}
  db_exec(request, valeurs)
  return db_last_id
end #/ db_compose_insert

# Pour updater (UPDATE) de façon simple (cf. le manuel)
REQUEST_UPDATE = 'UPDATE %{table} SET %{columns} WHERE id = ?'.freeze
def db_compose_update table, id, data
  data.merge!(updated_at: Time.now.to_i)
  valeurs = data.values << id
  columns = data.keys.collect{|c|"#{c} = ?"}.join(VG)
  request = REQUEST_UPDATE % {table:table, columns:columns}
  db_exec(request, valeurs)
end #/ db_compose_update


# Retourne le dernier ID
def db_last_id
  MyDB.db.last_id_of(MyDB.DBNAME)
end

# Supprime une ou plusieurs valeurs
def db_delete(table, filter)
  filter = {id: filter} if filter.is_a?(Integer)
  where_clause, values = MyDB.db.treat_where_clause(filter, [])
  request = "DELETE FROM #{table}#{where_clause}".freeze
  db_exec(request, values)
end #/ db_delete

# Retourne les valeurs des colonnes des champs de +table+ correspondants à
# +filter+
# NOTE Retourne UNE SEULE valeur
def db_get(table, filter, params = {})
  filter = {id: filter} if filter.is_a?(Integer)
  params = {columns: params} if params.is_a?(Array)
  params.merge!(request_suffix: 'LIMIT 1')
  candidats = db_get_all(table, filter, params)
  if candidats.nil? || candidats.empty?
    nil
  else
    candidats.first
  end
end

# Retourne toutes les rangées de +table+ correspondants à +filter+
# +Params+
#   +table+::[String] La table dans laquelle il faut trouver les données
#   +filter+::[Hash]  La table des conditions, par exemple {id: 2}
#   +params+::[Hash]  Paramètres supplémentaires
#       :request_suffix [String]  À ajouter à la fin de la requête, par
#                                 exemple pour l'ordre ou la limite.
#       :columns [Nil|Array|String] Liste des colonnes à remonter (default: '*')
#
# +return+ [Array] Liste des données trouvées.
def db_get_all(table, filter, params = {})
  where_clause, values = MyDB.db.treat_where_clause(filter, [])
  params[:columns] ||= '*'
  params[:columns] = params[:columns].join(', ') if params[:columns].is_a?(Array)
  req = "SELECT #{params[:columns]||'*'} FROM #{table}#{where_clause} #{params[:request_suffix]}".strip.freeze
  db_exec(req, values)
end


# Retourne le nombre de rangées de +table+ correspondant à +filter+
# Le filtre peut être explicite : "id = 12 AND nom = 'mon prénom'"
#                  ou une table : {id: 12, nom: "mon prénom"}
def db_count(table, filter = nil)
  MyDB.db.count(nil, table, filter)
end

class MyDB
class << self
  attr_accessor :error

  # Pour définir à la volée si on doit jouer les requêtes sur la table locale
  # ou distante.
  # @usage      MyDB.online = true/false
  #
  attr_accessor :online

  def db
    @db ||= Database.new(self)
  end

  def online?
    if @online === nil
      ONLINE
    else
      @online === true
    end
  end #/ online?

  def online=(valeur)
    @online = valeur
    @data_client = nil # pour forcer la réinitialisation
  end #/ online=

  def DBNAME
    @dbname ||= SANDBOX ? DB_TEST_NAME : DB_NAME
  end
  def DBNAME= dbname
    @dbname = dbname
  end

  def reset
    @dbname = nil
    @db = nil
  end

  # Pour utiliser cette librairie dans un autre site, modifier
  # simplement les données `db_prefix` et `data_client` ci-dessous

  # Raccourci
  def db_prefix
    @db_prefix ||= ''
  end
  def data_client
    @data_client ||= DATA_MYSQL[online? ? :distant : :local]
  end
end # << self

  class Database
    attr_reader :site
    def initialize site
      @site = site
    end

    def use_database db_name
      client.query("use `#{db_name}`;")
    end
    alias :use_db :use_database

    # Méthode principale pour exécuter les requêtes
    #
    # Voir le manuel pour le détail de l'utilisation.
    #
    # @param {String|Array} requests
    #                       Requête ou liste de requêtes
    # @param {Array} values
    #                       Si défini, c'est une requête préparée.
    # @return {Array|Hash}
    #         La liste des résultats obtenus ou le résultat si une
    #         seule requête a été transmise.
    def execute requests, values = nil
      use_database(MyDB.DBNAME)
      only_one_request = false == requests.is_a?(Array)
      only_one_request && begin
        if values.nil?
          requests = [requests]
        else
          requests = [[requests, values]]
        end
      end
      all_res = []
      requests.each do |request|
        if request.is_a?(Array)
          preparation, arr_of_arr_values = request
          # Préparation de la requête
          statement = client.prepare(preparation)
          arr_of_arr_values[0].is_a?(Array) || arr_of_arr_values = [arr_of_arr_values]
          all_res << [] # On va y mettre tous ces résultats
          arr_of_arr_values.each do |arr_values|
            res = statement.execute(*arr_values)
            res || next
            res.each { |row| all_res.last << row }
          end
        else
          all_res << [] # Un liste dans la liste, pour les résultats
          begin
            res = client.query(request, {symbolized_keys: true})
            res.each { |row| all_res.last << row } if res
          rescue Mysql2::Error => e
            raise Mysql2::Error.new("PROBLÈME AVEC LA REQUÊTE : `#{request}` : #{e.message}")
          rescue Exception => e
            erreur ("PROBLÈME SQL: #{e.message}")
            log(e)
            raise Error.new("PROBLÈME AVEC LA REQUÊTE : `#{request}` : #{e.message}")
          end
        end
      end
      return only_one_request ? all_res[0] : all_res
    end
    alias :query :execute

    # Retourne le statement
    def prepare requete
      client.prepare(requete)
    end
    # Exécute le statement préparé avec les valeurs +values+ et
    # @return {Array} Le résultat
    def exec_statement statement, values
      res = statement.execute(*values)
      res ? res.map{|row|row} : nil
    end
    alias :execute_statement :exec_statement


    # Retourne le dernier identifiant employé pour la table
    # +db_table+ de la base de nom +db_name+ (non préfixé)
    # Noter que pour le moment, la table ne sert à rien, pour qu'il
    # semble que LAST_INSERT_ID fonctionne sans précision de table.
    def last_id_of db_name, db_table = nil
      use_database(db_name)
      client.query('SELECT LAST_INSERT_ID()').each do |row|
        return row.values.first
      end
    end

    # Raccourci pour insérer une valeur de façon simple
    # @param {String} db_name
    #                 Nom (suffixe) de la base de données. Par exemple ':hot'
    # @param {String} db_table
    #                 Table dans laquelle il faut insérer les données.
    # @param {Hash}   hdata
    #                 Les données à insérer.
    #
    # @return {Integer|Nil}
    #         Le LAST_INSERT_ID
    def insert db_name, db_table, hdata
      use_database( db_name )
      if hdata[:__strict]
        hdata.delete(:__strict)
      else
        now = Time.now.to_i
        hdata[:created_at] || hdata.merge!(created_at: now.to_s)
        hdata[:updated_at] || hdata.merge!(updated_at: now.to_s)
      end
      colonnes  = []
      values    = []
      interrs   = []
      hdata.each do |k,v|
        colonnes  << k.to_s
        values    << v
        interrs   << '?'
      end
      colonnes  = colonnes.join(',')
      interrs   = interrs.join(',')
      statement = client.prepare("INSERT INTO #{db_table} (#{colonnes}) VALUES (#{interrs})")
      res = statement.execute(*values)
      # res.map{|row|row} if res
      return last_id_of(db_name)
    end

    # Retourne des données
    def select db_name, db_table, where_clause = nil, colonnes = nil
      values = nil

      wclause =
        case where_clause
        when NilClass then nil
        when String   then where_clause
        when Hash
          values  = []
          wclause = []
          where_clause.each do |k, v|
            wclause << "#{k} = ?"
            values  << v
          end
          wclause.join(' AND ')
        else
          raise "La clause WHERE doit être définie par un Hash ou un String"
        end
      wclause && wclause = " WHERE #{wclause}"

      colonnes =
        case colonnes
        when String   then colonnes
        when Array    then colonnes.join(', ')
        when NilClass then '*'
        else
          raise "Les colonnes à retourner doivent être définies par un String ou un Array de String(s)."
        end

      request = "SELECT #{colonnes} FROM #{db_table}#{wclause};"
      use_database db_name
      if values
        statement = prepare(request)
        exec_statement(statement, values)
      else
        execute(request)
      end
    end

    # Actualise une donnée
    #
    def update db_name, db_table, hdata, where_clause
      use_database db_name
      if hdata[:__strict]
        hdata.delete(:__strict)
      else
        hdata[:updated_at] || hdata.merge!(updated_at: Time.now.to_i)
      end
      values    = []
      colsints  = []
      hdata.each do |k, v|
        colsints  << "#{k} = ?"
        values    << v
      end

      wclause, values = treat_where_clause(where_clause, values)

      colsints = colsints.join(', ')
      statement = client.prepare("UPDATE #{db_table} SET #{colsints}#{wclause}")
      res = statement.execute(*values)
      res.map{|row|row} if res
    end

    # @param {String|Hash} where_clause
    #                       Définition initiale de la clause WHERE
    # @return {Array} [where_clause, values]
    def treat_where_clause where_clause, values
      case where_clause
      when NilClass
        return ['', values]
      when String
        wclause = where_clause
      when Hash
        wclause = []
        where_clause.each do |k,v|
          wclause << "#{k} = ?"
          values  << v
        end
        wclause = wclause.join(' AND ')
      else
        raise "Il faut fournir soit un String soit un Hash comme clause WHERE…"
      end
      return [" WHERE #{wclause}", values]
    end

    def delete db_name, db_table, where_clause = nil
      wclause, values = treat_where_clause( where_clause, [] )
      request = "DELETE FROM #{db_table}#{wclause};"
      use_database db_name
      if values.empty?
        client.query(request)
      else
        exec_statement( prepare(request), values )
      end
    end

    def count db_name, db_table, where_clause = nil
      db_name ||= MyDB.DBNAME
      # Soit on prend la première clé de where_clause, soit "*"
      etoile = where_clause.is_a?(Hash) ? where_clause.keys.first : '*'.freeze
      wclause, values = treat_where_clause(where_clause, [])
      request = "SELECT COUNT(#{etoile}) FROM #{db_table}#{wclause};".freeze
      use_database db_name
      if values.empty?
        client.query(request)
      else
        exec_statement( prepare(request), values )
      end.first.values.first
    end

    def client
      @client ||= init_client
    end

    # Initialise le client MySql courant
    def init_client
      # require 'mysql2'
      # cl = Mysql2::Client.new(data_client||DATA_MYSQL[:local])
      # cl.query_options.merge!(:symbolize_keys => true)
      Mysql2::Client.new(data_client||DATA_MYSQL[:local]).tap do |cl|
        cl.query_options.merge!(:symbolize_keys => true)
      end
      # return cl
    end

    def data_client ; @data_client ||= site.data_client end

  end #/Database

end #/MyDB
