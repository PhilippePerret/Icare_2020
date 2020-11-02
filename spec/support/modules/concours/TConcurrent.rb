# encoding: UTF-8
# frozen_string_literal: true
class TConcurrent
  # extend RSpec::Matchers

  include RSpec::Matchers

  include Capybara::DSL
# ---------------------------------------------------------------------
#
#   MÉTHODES PUBLIQUES DE TEST
#
# ---------------------------------------------------------------------

# Pour savoir si le concurrent a reçu un mail
def has_mail?(data)
  expect(TMails).to have_mail(data.merge(destinataire: mail))
end #/ has_mail?

# Méthode de feature pour identifier le concurrent
# Il rejoint le formulaire d'identification, le remplit et le soumet
def identify
  visit("http://localhost/AlwaysData/Icare_2020/concours/identification")
  expect(page).to have_css("form#concours-login-form")
  within("form#concours-login-form") do
    fill_in("p_mail", with: mail)
    fill_in("p_concurrent_id", with:id)
    click_on(UI_TEXTS[:concours_bouton_sidentifier])
  end
end #/ identify

def logout
  click_on("Se déconnecter")
end #/ logout

def set_specs(new_specs)
  request = "UPDATE concurrents_per_concours SET specs = ? WHERE concurrent_id = ? AND annee = ?"
  db_exec(request, [new_specs, id, ANNEE_CONCOURS_COURANTE])
end #/ set_specs


class << self

# Retourne une instance TConcurrent choisie au hasard
#
# IN    +options+ Table d'options:
#                 :femme    Si true on doit retourner une femme
#                 :without_synopsis   Si true, on doit retourner un
#                       concurrent sans synopsis.
#                 :with_synopsis  Si true, un concurrent avec déjà un fichier
#                       pour la session courante.
#                 :non_inscrit    Si true, il faut renvoyer un ancien concurrent
#                 :current        Inverse de :non_inscrit
# OUT   Un concurrent pris au hasard, qui peut remplir certaines
#       conditions optionnellement définies par +options+.
#       Mais c'est forcément un candidat courant
#
def get_random(params = nil)
  proceed_get_random(params || {})
end #/ get_random


# Pour inscrire un icarien au concours
def inscrire_icarien(u, options)
  proceed_inscrire_icarien(u, options)
end #/ self.inscrire_icarien

end #/ << self
# ---------------------------------------------------------------------
#
#   MÉTHODES FONCTIONNELLES
#
# ---------------------------------------------------------------------

class << self

  def reset
    @allconcurrents = nil
  end #/ reset

  def proceed_get_random(options = nil)
    options ||= {}
    options[:current] = !options[:non_inscrit] if options.key?(:non_inscrit)
    candidat = nil
    begin
      candidat =  if options[:with_synopsis] # tiendra compte de options[:femme]
                    get_concurrent_with_synopsis(options)
                  elsif options[:femme]
                    get_une_femme
                  elsif options[:current]
                    all_current[rand(all_current.count)]
                  else
                    all[rand(all.count)]
                  end
    end while candidat.nil?

    # puts "Candidat: #{candidat.inspect}"
    # Si on veut un ancien concurrent
    if options[:current] === false
      request = "DELETE FROM concurrents_per_concours WHERE annee = ? AND concurrent_id = ?"
      db_exec(request, [ANNEE_CONCOURS_COURANTE, candidat.id])
    end

    # Si on veut un candidat sans synopsis
    if options[:without_synopsis]
      # On doit détruire son dossier
      FileUtils.rm_rf(candidat.folder)
      # On doit régler ses options (specs à "00000000")
      candidat.set_specs("0"*8)
    elsif options[:with_synopsis]
      raise if candidat.specs[0] != "1"
    end
    # puts "candidat : #{candidat.inspect}"
    candidat.reset
    return candidat
  end #/ get_a_concurrent

  def get_une_femme
    all.each do |concurrent|
      return concurrent if concurrent.femme?
    end
  end #/ get_femme

  def get_concurrent_with_synopsis(options)
    all_current.each do |concurrent|
      cond = concurrent.specs[0] == "1"
      next if not cond
      cond = cond && concurrent.femme? if options[:femme]
      return concurrent if cond
    end
    return nil
  end #/ get_concurrent_with_synopsis

  def all
    @allconcurrents ||= begin
      db_exec("SELECT * FROM #{DBTBL_CONCURRENTS}").collect { |dc| new(dc) }
    end
  end #/ all

  # OUT   Liste ARRAY de tous les concurrents du concours courant
  def all_current
    @all_current ||= begin
      db_exec(REQUEST_CONCURRENTS_COURANTS, [Concours.current.annee]).collect{|dc|new(dc)}
    end
  end #/ all_current

  # Pour inscrire un {TUser} qui est un icarien
  # Noter que cette inscription se fera toujours sur un concours précédent,
  # jamais sur le concours présent.
  #
  # IN    +u+ {User} à inscrire
  #       +options+   {Hash} d'options, donc :
  #         :session_courante   Si true, on l'inscrit à la session courante
  #                             Sinon, non.
  def proceed_inscrire_icarien(u, options)
    data_cc = {
      patronyme: u.patronyme||u.pseudo,
      mail: u.mail,
      sexe: u.ini_sexe, # u.sexe = "une femme" ou "un homme" pour le moment…
      session_id: "1"*32,
      concurrent_id: new_concurrent_id,
      options: "11100000" # 3e bit à 1 => icarien
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
  end #/ inscrire

  def new_concurrent_id
    now = Time.now
    concid = "#{now.strftime("%Y%m%d%H%M%S")}"
    while db_count(DBTBL_CONCURRENTS, {concurrent_id: concid}) > 1
      now += 1
      concid = "#{now.strftime("%Y%m%d%H%M%S")}"
    end
    return concid
  end #/ new_concurrent_id

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :patronyme, :mail, :concurrent_id, :options, :created_at, :updated_at
attr_reader :specs, :titre, :auteurs, :keywords, :prix
def initialize(data)
  # puts "Data : #{data.inspect}"
  dispatch(data) unless data.nil?
end #/ initialize

alias :pseudo :patronyme
alias :id :concurrent_id

def reset
  d = db_exec(REQUEST_CONCURRENT_ALL_DATA, [ANNEE_CONCOURS_COURANTE, id]).first
  # Mais si le concurrent n'est pas inscrit à la session courante, la commande
  # ci-dessus renverra nil. Il faut alors prendre les données seulement  dans
  # la table concours_concurrents
  d = db_exec(REQUEST_CONCURRENT_MIN_DATA, [id]).first if d.nil?
  dispatch(d)
end #/ reset

def dispatch(d)
  return if d.nil?
  d.each{|k,v|instance_variable_set("@#{k}",v)}
end #/ dispatch

def folder
  @folder ||= File.join(CONCOURS_DATA_FOLDER, self.id)
end #/ folder

def femme?
  sexe == 'F'
end #/ femme?

REQUEST_CONCURRENTS_COURANTS = <<-SQL
SELECT
  cc.*, cpc.titre, cpc.auteurs, cpc.keywords, cpc.specs, cpc.prix
  FROM concours_concurrents cc
  INNER JOIN concurrents_per_concours cpc ON cc.concurrent_id = cpc.concurrent_id
  WHERE cpc.annee = ?
SQL

REQUEST_CONCURRENT_ALL_DATA = <<-SQL
SELECT
  cc.*, cpc.titre, cpc.auteurs, cpc.keywords, cpc.specs, cpc.prix
  FROM concours_concurrents cc
  INNER JOIN concurrents_per_concours cpc ON cc.concurrent_id = cpc.concurrent_id
  WHERE cpc.annee = ? AND cc.concurrent_id = ?
SQL

REQUEST_CONCURRENT_MIN_DATA = <<-SQL
SELECT * FROM concours_concurrents WHERE concurrent_id = ?
SQL
end #/TConcurrent
