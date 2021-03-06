# encoding: UTF-8
=begin
  Class Scenariopole
  ------------------
  Permet de faire des appels à la table Scenariopole
=end
require 'mysql2'

class Scenariopole
class << self
  # Pour exécuter une requête sur le site scénariopole
  def db_exec(request)
    client = client_scenariopole('scenariopole_biblio')
    begin
      all_res = []
      res = client.query(request, {symbolize_keys: true})
      res.each { |row| all_res << row } if res
      return all_res
    rescue Mysql2::Error => e
      raise Mysql2::Error.new("PROBLÈME AVEC LA REQUÊTE : `#{request}` : #{e.message}")
    rescue Exception => e
      erreur ("PROBLÈME SQL: #{e.message}")
      log(e)
      raise Error.new("PROBLÈME AVEC LA REQUÊTE : `#{request}` : #{e.message}")
    end
  end #/ db_exec

  # RETURN Un hash des données de la citation choisie
  #
  # +options+ Surtout pour l'administration
  #   :no_last_sent     Si true, on n'actualise pas la date de dernier envoi
  #   :only_online      Si true, renvoie nil quand on est OFFLINE
  def get_citation(options = nil)
    options ||= {}
    # options[:only_online] && OFFLINE && (return nil)
    client = client_scenariopole('scenariopole_biblio')
    candidates = client.query("SELECT id, citation, auteur FROM citations ORDER BY last_sent ASC LIMIT 10 OFFSET 11;")
    candidates = candidates.collect{|row| row}
    candidate = candidates.shuffle.shuffle.first
    options[:no_last_sent] || begin
      client.query("UPDATE LOW_PRIORITY citations SET last_sent = #{Time.now.to_i} WHERE id = #{candidate['id']};") rescue nil
    end
    return candidate
  rescue Exception => e
    debug "# PROBLÈME DANS get_citation #"
    debug e
    return {id:'', citation:'', auteur:''}
  end

  # Le client ruby qui permet d'intergagir avec la base de
  # données.
  def client_scenariopole db_scenariopole_name
    @client_scenariopole ||= begin
      Mysql2::Client.new(client_data_scenariopole.merge(database: db_scenariopole_name))
    end
  end
  def client_data_scenariopole
    data_mysql_scenariopole[ONLINE ? :online : :offline]
  end
  def data_mysql_scenariopole # sur scénariopole maintennat
    @data_mysql_scenariopole ||= begin
      require File.join(DATA_FOLDER,'secret','sql_scenariopole')
      DATA_MYSQL_SCENARIOPOLE
    end
  end
end #/<<self
end #/Scenariopole
