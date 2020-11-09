# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class Candidat
  --------------
  Classe facilitatrice pour le concours, pour gérer un visiteur qui
  vient participer au concours.
=end
require 'fileutils'
Candidat = Struct.new(:patronyme, :mail, :sexe) do

  alias :pseudo :patronyme
  
  # OUT   true si le concurrent est une femme
  def femme?; sexe == "F" end #/ femme?

  # OUT   true si le concurrent existe
  def exists?; not(db_data.nil?) end

  # OUT   Pour le menu "sexe" du formulaire d'inscription
  def genre; @genre ||= femme? ? "féminin" : "masculin" end

  # OUT   Donnée du concurrent dans la base, s'il existe
  def db_data
    @db_data ||= db_get(DBTBL_CONCURRENTS, {mail: mail})
  end #/ db_data

  # OUT   ID concours du concurrent (concurrent_id)
  def id ; @id ||= db_data[:concurrent_id] end

  # DO    Inscrit le concurrent pour un des concours
  #       Si options[:session_courante] est true, on l'inscrit pour
  #       la session courante.
  #
  def signup(options)
    @id = TConcurrent.new_concurrent_id
    data_cc = {
      patronyme: patronyme,
      mail: mail,
      sexe: sexe, # u.sexe = "une femme" ou "un homme" pour le moment…
      session_id: "1"*32,
      concurrent_id: id,
      options: "11000000"
    }
    db_compose_insert(DBTBL_CONCURRENTS, data_cc)
    if options && false === options[:session_courante]
      # Note : il faut forcément une participation à un concours, donc on prend
      # un des concours précédent
      dco = db_exec("SELECT annee FROM concours WHERE annee < ? LIMIT 1", Time.now.year).first
      dco || raise("Pour inscrire un concurrent, il faut au moins un concours précédent")
      data_cpc = {concurrent_id:data_cc[:concurrent_id], annee:dco[:annee], specs:"00000000"}
    elsif options && options[:session_courante]
      data_cpc = {concurrent_id:data_cc[:concurrent_id], annee:ANNEE_CONCOURS_COURANTE, specs:"00000000"}
    end
    db_compose_insert(DBTBL_CONCURS_PER_CONCOURS, data_cpc)
  end #/ signup

  # DO    Inscrit le candidat à la session courante
  def signup_session_courante
    data_cpc = {concurrent_id:id, annee:ANNEE_CONCOURS_COURANTE, specs:"00000000"}
    db_compose_insert(DBTBL_CONCURS_PER_CONCOURS, data_cpc)
  end #/ signup_session_courante

  # DO    Méthode pour détruire complètement un concurrent
  def destroy
    db_exec("DELETE FROM #{DBTBL_CONCURRENTS} WHERE concurrent_id = ?", id)
    db_exec("DELETE FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE concurrent_id = ?", id)
    FileUtils.rm_rf(folder) if File.exists?(folder)
    @db_data = nil; @id = nil; @folder = nil
  end #/ destroy

  # OUT   True si le candidat est inscrit à la session courante du concours
  def concurrent_session_courante?
    db_count(DBTBL_CONCURS_PER_CONCOURS, {concurrent_id: id, annee: ANNEE_CONCOURS_COURANTE}) > 0
  end #/ concurrent_session_courante?

  # OUT   Dossier du concurrent (celui pour mettre le fichier par exemple)
  def folder
    @folder ||= File.join(CONCOURS_DATA_FOLDER, id)
  end #/ folder
end
