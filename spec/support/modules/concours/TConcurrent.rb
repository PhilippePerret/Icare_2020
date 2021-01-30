# encoding: UTF-8
# frozen_string_literal: true
require './_lib/required/__first/feminines'
class TConcurrent
  # extend RSpec::Matchers

include RSpec::Matchers

include Capybara::DSL

include FemininesMethods

include SpecModuleNavigation

# ---------------------------------------------------------------------
#
#   MÉTHODES D'INSTANCE PUBLIQUES DE TEST
#
# ---------------------------------------------------------------------

def ref
  @ref ||= "#{pseudo} (#{id})"
end #/ ref

def synopsis
  @synopsis ||= begin
    require './_lib/_pages_/concours/xmodules/synopsis/Synopsis'
    load File.join(__dir__,'Synopsis.rb') # pour surclasser les méthodes
    Synopsis.new(id, ANNEE_CONCOURS_COURANTE)
  end
end #/ synopsis

# Pour savoir si le concurrent a reçu un mail
def has_mail?(data)
  expect(TMails).to have_mail(data.merge(destinataire: mail))
end #/ has_mail?

# Méthode de feature pour identifier le concurrent
# Il rejoint le formulaire d'identification, le remplit et le soumet
def identify
  goto("concours/identification")
  expect(page).to have_css("form#concours-login-form")
  within("form#concours-login-form") do
    fill_in("p_mail", with: mail)
    fill_in("p_concurrent_id", with:id)
    click_on(UI_TEXTS[:concours_bouton_sidentifier])
  end
end #/ identify
alias :rejoint_le_concours :identify

def logout
  if not page.has_css?('a', text: 'Se déconnecter')
    page.execute_javascript('alert("Pas de bouton pour se déconnecter")')
  end
  click_on("Se déconnecter")
end #/ logout

# Note : on peut aussi utiliser set_spec(bit, value[, save])
def set_specs(new_specs)
  request = "UPDATE concurrents_per_concours SET specs = ? WHERE concurrent_id = ? AND annee = ?"
  db_exec(request, [new_specs, id, ANNEE_CONCOURS_COURANTE])
  reset
end #/ set_specs

def dossier_transmis?
  (@dossier_is_transmis ||= begin
    fichier_path(ANNEE_CONCOURS_COURANTE).nil? ? :false : :true
  end) == :true
end #/ dossier_transmis?

def fichier_conforme?
  (@fichier_is_conforme ||= begin
    dossier_transmis? && (specs[1] == "1") ? :true : :false
  end) == :true
end #/ fichier_conforme?

def preselected?
  (@is_preselected ||= begin
    specs[2] == "1" ? :true : :false
  end) == :true
end #/ preselected?

def set_preselected
  set_spec(2,1)
end #/ set_preselected

def set_not_preselected
  set_spec(2,0)
end #/ set_not_preselected

# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------

class << self

# OUT   Une liste Array de {concurrent}s répondant au filtre +filtre+
#       Ce sont des instances de concurrents.
#
# IN    +filtre+ Table des filtres à appliquer sur la liste
#           :avec_fichier     Le concurrent doit avoir un fichier dans la
#                             disposition courante
#           :avec_fichier_conforme    Idem mais le fichier doit être conforme
#           :conformite_definie   Si false, la conformité n'est pas définie
#           :preselected      Le concurrent doit être présélectionné.
#           :primed           Le concurrent doit être primé
#
def find(filtre)
  where = []
  values = []
  confo_undefined = filtre[:conformite_definie] === false

  if filtre[:avec_fichier_conforme]
    where << "SUBSTRING(cpc.specs,1,2) = '11'"
  elsif filtre[:avec_fichier_conforme] === false
    where << "SUBSTRING(cpc.specs,1,2) = '12'"
  elsif filtre[:avec_fichier]
    if confo_undefined
      where << "SUBSTRING(cpc.specs,1,2)  = 10"
    else
      where << "SUBSTRING(cpc.specs,1,1)  = 1"
    end
  end

  where << "SUBSTRING(cpc.specs,3,1) = 1" if filtre[:preselected]
  where << "SUBSTRING(cpc.specs,4,1) IN (1,2,3)" if filtre[:primed]
  if filtre.key?(:avec_fichier) || filtre.key?(:avec_fichier_conforme) ||
    filtre.key?(:preselected) || filtre[:current] || filtre[:primed]
    where << "annee = ?"
    values << ANNEE_CONCOURS_COURANTE
  end
  request = REQUEST_ALL_CONCURRENTS_WHERE % {where: where.join(' AND ')}
  db_exec(request, values).collect { |dc| new(dc) }
end #/ find

# Retourne une instance TConcurrent choisie au hasard
#
# IN    +options+ Table d'options:
#                 :count
#                     Le nombre de concurrents attendus
#                 :not_mail
#                     LISTE des mails qu'il ne faut pas prendre (i.e. qui sont
#                     déjà utilisés par une autre recherche par exemple)
#                 :femme
#                     Si true on doit retourner une femme
#                 :avec_fichier
#                     Si true, un concurrent avec déjà un fichier pour la
#                     session courante.
#                 :conformite_definie   Si false, un concurrent ayant un
#                     fichier avec la conformité non définie
#                 :avec_fichier_conforme
#                     Si true, un concurrent avec un fichier conforme.
#                 :current
#                     Un concurrent courant
#                 :ancien
#                     Si true, le concurrent doit déjà avoir des participations
#                     aux concours précédent (si :current est explicitement
#                     false, le concurrent ne doit pas être inscrit au
#                     concours courant)
#                 :preselected
#                     Si true, un présélectionné
#                     Si false, un non présélectionné (avec fichier conforme)
#                     Si nil, don't mind
#
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

# Retourne la liste des jurés
# OBSOLÈTE (il vaut mieux utiliser la classe TEvaluator)
def jury
  @jury ||= TEvaluator.data
end #/ jury

# ---------------------------------------------------------------------
#   MÉTHODES DE CLASSE FONCTIONNELLES
# ---------------------------------------------------------------------

  def reset
    @allconcurrents = nil
  end #/ reset

  def proceed_get_random(options = nil)
    options ||= {}
    options.merge!({
      current:  true,
      avec_fichier_conforme: true
    }) if options.key?(:preselected)
    # Noter ci-dessus : quand un concurrent est présélectionné ou non présélectionné,
    # il a forcément un fichier conforme et il est forcément du concours courant
    # preselected: false signifie "qui a participé au concours avec un bon
    # fichier mais n'a pas été présélectionné".
    options.merge!(avec_fichier: true) if options.key?(:avec_fichier_conforme)
    options.merge!(count: 1) if not options.key?(:count)
    options.merge!(current: true) if options.key?(:avec_fichier)
    options.merge!(not_mail: []) unless options.key?(:not_mail)

    # puts "\n\noptions avant définition de where : #{options.inspect}"

    where = []
    valus = []
    case options[:avec_fichier]
    when TrueClass  then where << "SUBSTRING(cpc.specs,1,1) = 1"
    when FalseClass then where << "SUBSTRING(cpc.specs,1,1) = 0"
    end
    case options[:avec_fichier_conforme]
    when TrueClass  then where << "SUBSTRING(cpc.specs,2,1) = 1"
    when FalseClass then where << "SUBSTRING(cpc.specs,2,1) = 0 OR SUBSTRING(cpc.specs,2,1) = 2"
    end
    case options[:conformite_definie]
    when TrueClass  then where << "SUBSTRING(cpc.specs,2,1) = 1"
    when FalseClass then where << "SUBSTRING(cpc.specs,2,1) = 0"
    end
    case options[:femme]
    when TrueClass  then where << "cc.sexe = 'F'"
    when FalseClass then where << "cc.sexe = 'H'"
    end
    case options[:current]
    when TrueClass  then where << "cpc.annee = #{ANNEE_CONCOURS_COURANTE}"
    end
    case options[:preselected]
    when TrueClass  then where << "SUBSTRING(cpc.specs,3,1) = 1"
    when FalseClass then where << "SUBSTRING(cpc.specs,3,1) = 0"
    end

    # Dans le cas où il faut trouver un concurrent ancien
    if options[:current] === false || options[:ancien]
      intermediaire_req = <<-SQL
SELECT concurrent_id FROM concurrents_per_concours
WHERE concurrent_id  NOT IN (SELECT concurrent_id FROM concurrents_per_concours
WHERE annee = ?)
      SQL
      concurrent_id_hors_concours = db_exec(intermediaire_req, [ANNEE_CONCOURS_COURANTE]).first
      concurrent_id_hors_concours = concurrent_id_hors_concours[:concurrent_id]
      concurrent_id_hors_concours || raise("Impossible de trouver un ancien concurrent hors concours…")
      where << "cpc.concurrent_id = ?"
      valus << concurrent_id_hors_concours
    end

    concurrents = [] # les candidats retenus
    # Liste d'instances {TConcurrent}
    where = ["1 = 1"] if where.empty?
    request = REQUEST_ALL_CONCURRENTS_WHERE % {where: where.join(' AND ')}
    # puts "request concurrent: #{request.inspect}"
    # puts "Request all concurrents : #{request.inspect}"
    res = if valus.empty?
            db_exec(request)
          else
            db_exec(request, valus)
          end
    # on prend les candidats
    candidats = res.collect { |dc| new(dc) }
    if candidats.empty?
      candidat = all_current.shuffle.shuffle.first
      if options[:avec_fichier] === false
        candidat.set_spec(0,0, false)
        candidat.set_spec(1,0, true)
        File.delete(candidat.fichier_path(ANNEE_CONCOURS_COURANTE))
      end
      if options[:conformite_definie] === false
        candidat.set_spec(1,0)
      end
      candidat.reset
      candidats << candidat
      if candidats.empty?
        raise "Impossible de trouver un tconcurrent avec #{options.inspect}"
      end
    end
    candidats.shuffle
    # puts "candidats: #{candidats.inspect}"
    candidats.each do |candidat|
      next if options[:not_mail].include?(candidat.mail)
      # puts "Je prends #{candidat.inspect}"
      concurrents << candidat
      options[:not_mail] << candidat.mail
      break if concurrents.count == options[:count]
    end

    concurrents.each do |conc| conc.reset end
    if options[:count] == 1
      concurrents.first
    else
      concurrents
    end
  end #/ get_a_concurrent

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
attr_reader :patronyme, :mail, :sexe, :concurrent_id, :options, :created_at, :updated_at
attr_reader :specs, :titre, :auteurs, :keywords, :prix
def initialize(data)
  # puts "Data : #{data.inspect}"
  dispatch(data) unless data.nil?
end #/ initialize

alias :pseudo :patronyme
alias :id :concurrent_id

# ---------------------------------------------------------------------
#
#   Méthodes d'interaction
#
# ---------------------------------------------------------------------

# Pour se déconnecter, le concurrent rejoint la page d'accueil du
# concours et clique sur "Se déconnecter".
# Noter que cette déconnexion n'a rien à voir avec la connexion de l'atelier
def se_deconnecte
  visit("#{App::URL}/concours/espace_concurrent")
  # On doit faire disparaitre le message s'il y en a un
  if page.has_css?("section#messages")
    page.find("section#messages").click
  end
  click_link("Se déconnecter")
end #/ se_deconnecte

# ---------------------------------------------------------------------
#
#   Méthodes publiques
#
# ---------------------------------------------------------------------

def reset
  d = db_exec(REQUEST_CONCURRENT_ALL_DATA, [ANNEE_CONCOURS_COURANTE, id]).first
  # Mais si le concurrent n'est pas inscrit à la session courante, la commande
  # ci-dessus renverra nil. Il faut alors prendre les données seulement  dans
  # la table concours_concurrents
  d = db_exec(REQUEST_CONCURRENT_MIN_DATA, [id]).first if d.nil?
  log("d après reset : #{d}")
  dispatch(d)
  @fichier_is_conforme = nil
  @dossier_is_transmis = nil
  @is_preselected = nil
  @folder = nil
  @synopsis = nil
end #/ reset

# Fabrique un fichier de candidature pour le concurrent pour l'année +annee+
# (ou l'année courante si nil), en réglant ses specs à "11" pour les
# deux premières
#
# +conforme+ Si on le met à true, ça crée un fichier non conforme
#
def make_fichier_conforme(annee = nil, conforme = true)
  annee ||= ANNEE_CONCOURS_COURANTE
  make_fichier(annee)
  dc = db_get(DBTBL_CONCURS_PER_CONCOURS,"annee = #{annee} AND concurrent_id = #{id}")
  sp = dc[:specs].split('')
  sp[0] = "1"
  sp[1] = conforme ? "1" : "2"
  request = "UPDATE #{DBTBL_CONCURS_PER_CONCOURS} SET specs = ? WHERE annee = ? AND concurrent_id = ?"
  db_exec(request, [sp.join(''), annee, id])
  reset
end #/ make_fichier

# Produit un fichier non conforme pour le concurrent
# En fait, un fichier non, conforme, c'est un fichier normal, mais les bits
# des specs ont été modifiés (le bit 1 — 2e — à 2)
def make_fichier_non_conforme(annee = nil)
  make_fichier_conforme(annee, false)
end #/ make_fichier_non_conforme

def make_fichier(annee = nil)
  destroy_fichier(annee) # au cas où
  annee ||= ANNEE_CONCOURS_COURANTE
  fsrc = File.join(SPEC_SUPPORT_FOLDER,'asset','documents','autre_doc.pdf')
  fdst = File.join(folder, "#{id}-#{annee}.pdf")
  FileUtils.copy(fsrc, fdst)
end #/ make_fichier

# Méthode qui permet de détruire le fichier de candidature du concurrent
# Si aucune année n'est précisée, c'est l'année courante
# DO    - Détruit le fichier du concurrent
#       - Mets ses specs à "0"
def destroy_fichier(annee = nil)
  annee ||= ANNEE_CONCOURS_COURANTE
  fpath = fichier_path(annee)
  File.delete(fpath) if File.exists?(fpath)
  set_specs("0"*8)
end #/ destroy_fichier

# ---------------------------------------------------------------------
#
#   Méthodes fonctionnelles
#
# ---------------------------------------------------------------------

def dispatch(d)
  return if d.nil?
  d.each{|k,v|instance_variable_set("@#{k}",v)}
end #/ dispatch

def folder
  @folder ||= File.join(CONCOURS_DATA_FOLDER, self.id)
end #/ folder

def fichier_path(annee)
  Dir["#{folder}/#{id}-#{annee}.*"].first
end #/ fichier_path

def femme?
  sexe == 'F'
end #/ femme?


def set_spec(bit,value, save = true)
  sp = specs.dup.split('')
  sp[bit] = value.to_s
  set_specs(sp.join('')) if save
end

# Note : penser à utiliser 'reconnecte_visitor' après si on est déjà connecté
def set_pref_fiche_lecture(value)
  set_option(1, value ? 1 : 0)
end

# Réglage d'un bit d'option
def set_option(bit, value, save = true)
  @options[bit] = value.to_s
  request = "UPDATE #{DBTBL_CONCURRENTS} SET options = ? WHERE concurrent_id = ?"
  db_exec(request, [@options, id])
end



REQUEST_CONCURRENTS_COURANTS = <<-SQL
SELECT
  cc.*,
  cpc.titre, cpc.auteurs, cpc.keywords, cpc.specs, cpc.prix, cpc.pre_note, cpc.fin_note
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

REQUEST_ALL_CONCURRENTS_WHERE = <<-SQL
SELECT
  cc.*,
  cpc.titre, cpc.auteurs, cpc.keywords, cpc.specs, cpc.prix, cpc.pre_note, cpc.fin_note
  FROM concours_concurrents cc
  INNER JOIN concurrents_per_concours cpc ON cc.concurrent_id = cpc.concurrent_id
  WHERE %{where}
SQL
end #/TConcurrent
