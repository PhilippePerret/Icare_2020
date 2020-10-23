# encoding: UTF-8
# frozen_string_literal: true
class HTML
  attr_reader :concours
end


class Concours
STEPS_DATA = {
  0 => {name: "En attente", name_current:"En attente", name_done: "Préparé"},
  1 => {name: "Lancer et annoncer le concours", name_current:"Lancement du concours en cours", name_done: "Concours lancé et annoncé"},
  2 => {name: "Statuer l'échéance des rendus", name_current: "Première sélection en cours", name_done: "Première sélection effectuée"},
  3 => {name: "Annoncer première sélection", name_current: "Seconde sélection en cours", name_done: "Sélection finale effectuée"},
  5 => {name: "Annoncer le palmarès", name_current:"Annonce du palmarès en cours", name_done: "Palmarès annoncé"},
  8 => {name: "Annoncer fin officielle du concours", name_current:"Annonce de la fin du concours", name_done: "Fin officielle du concours"},
  9 => {name: "Nettoyer le concours", name_current:"Nettoyage du concours en cours", name_done:"Concours nettoyé"}
}
STEPS_DATA[0].merge!(operations:[
  {name:"Le changement du step modifie automatiquement l'affichage"}
])
STEPS_DATA[1].merge!(operations: [
  {name:"Réglage des configurations (utiles ?…)"},
  {name:"Envoi du mail d'annonce de lancement à tous les concurrents"},
  {name:"Envoi du mail d'annonce de lancement à tous les membres du jury"},
  {name:"Affichage du formulaire pour envoyer son dossier"}
])
STEPS_DATA[2].merge!(operations:[
  {name:"Envoi du mail aux concurrents annonçant l'échéance finale"},
  {name:"Envoi du mail aux jurés annonçant la fin de l'échéance"},
  {name:"Retrait du formulaire pour envoyer son dossier"},
])
STEPS_DATA[3].merge!(operations:[
  {name:"Envoi du mail aux concurrents annonçant les résultats de la première sélection"},
  {name:"Construction du panneau pour voir le résultat des premières sélections"}
])
STEPS_DATA[5].merge!(operations:[
  {name:"Envoi du mail aux concurrent annonçant le palmarès final"},
  {name:"Construction du panneau pour voir les résultats finaux"},
  {name:"Construction des fiches de lecture de chaque concurrent"},
  {name:"Affichage de la fiche de lecture sur l'espace personnel"}
])
STEPS_DATA[8].merge!(operations:[
  {name:"Envoi du mail de remerciement (et félicitations) à tous concurrents"},
  {name:"Envoi du mail de remerciement aux jurés"},
  {name:"Le concours n'est plus annoncé sur l'atelier"}
])
STEPS_DATA[9].merge!(operations:[
  {name:"Mise des dossiers de côté (zippés)"}
])
class << self
  attr_accessor :current # le concours courant
  def current
    @current ||= new(ANNEE_CONCOURS_COURANTE)
  end #/ current
end # /<< self
attr_reader :annee
def initialize(annee, data = nil)
  @annee = annee
  @data  = data
end #/ initialize
def data
  @data ||= begin
    # Particulariré de cette propriété : si le concours n'existe pas pour
    # l'année demandée, on crée sa donnée
    if db_count(DBTBL_CONCOURS, {annee: annee}) == 0
      db_compose_insert(DBTBL_CONCOURS, data_default.dup)
    end
    db_get(DBTBL_CONCOURS, {annee: annee})
  end
end #/ data

# ---------------------------------------------------------------------
#
#   Property
#
# ---------------------------------------------------------------------
def theme;  @theme  ||= data[:theme]  end
def step;   @step   ||= data[:step]   end

def prix1
  @prix1 ||= data[:prix1]
end #/ prix1
def prix2
  @prix2 ||= data[:prix2]
end #/ prix2
def prix3
  @prix3 ||= data[:prix3]
end #/ prix3

# ---------------------------------------------------------------------
#
#   Propriétés volatiles
#
# ---------------------------------------------------------------------
def nombre_concurrents
  @nombre_concurrents ||= db_count(DBTBL_CONCURS_PER_CONCOURS, {annee: annee})
end #/ nombre_concurrents

# Helper pour indiquer l'échéance, avec le nombre de jours restants
def h_echeance
  @h_echeance ||= formate_date(Time.new(ANNEE_CONCOURS_COURANTE, 3, 1), {duree: true})
end #/ h_echeance

# ---------------------------------------------------------------------
#
#   STATUTS
#
# ---------------------------------------------------------------------
# Retourne TRUE is le concours est démarré
def started?
  config[:started] == true
end #/ started?

# ---------------------------------------------------------------------
#
#   CONFIGURATION
#
# ---------------------------------------------------------------------
def config
  @config ||= begin
    h = {}
    JSON.parse(File.read(config_path)).each do |k,v|
      h.merge!(k.to_sym => v)
    end ; h
  end
end #/ config

def config_path
  @config_path ||= File.expand_path(File.join('.','_lib','_pages_','concours','xrequired','config.json'))
end #/ config_path

private

  # OUT   Les données par défaut, à la création du concours de l'année
  def data_default
    {
      annee: ANNEE_CONCOURS_COURANTE,
      theme: "THEME_COURANT"
    }
  end #/ data_default
end #/Concours
