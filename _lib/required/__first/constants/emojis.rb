# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module qui permet de gérer les émojis comme des émojis (alors que pour
  windows, qui en possède des affreuses, on est contraint d'utiliser des
  images PNG)

  La classe peut être 'small', 'regular', ou 'big'

  EMO_PAPILLON.small

  Pour obtenir un émoji formaté
  -----------------------------
    <EMO_...>.format(<params>)
    <params> est un hash qui peut contenir
      :full       True si on veut un path absolu, comme pour les mails
      :class      La classe CSS à utiliser


=end
require_relative '../../_classes/App'
class Emoji
IMG_TAG = '<img src="%s" alt="%s" class="emoji %s" />'
IMG_TAG_STYLED = '<img src="%s" alt="%s" class="emoji" style="%s" />'
ABSOLUTE_PATH = "#{App::URL}/img/Emojis/%s" #'https://www.atelier-icare.net/img/Emojis/%s'
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
# Certains smileys courants sont en constantes plus bas, mais certains,
# qui ne sont utilisés que rarement, peuvent être enregistrés seulement
# ici par cette méthode get.
def get(relpath)
  @items ||= {}
  @items[relpath] ||= new(relpath)
end #/ get

end #/<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :init_relpath
attr_reader :options # les options envoyéees pour formatage
def initialize relpath
  relpath = File.join(File.dirname(relpath), File.basename(relpath,File.extname(relpath)) )# enlever .png
  @init_relpath = relpath
end #/ initialize
# ---------------------------------------------------------------------
#   Méthodes publiques
# ---------------------------------------------------------------------
# Pour définir précisément le format de l'image
def format(params)
  @options = params
  @require_full_path = true if params[:full]
  @is_shadowed = params[:shadowed] === true
  build(params[:class] || 'regular')
end #/ format
def small(options = nil)
  build_with_or_without_options(:small, options)
end #/ small
def mini(options = nil)
  build_with_or_without_options(:mini, options)
end #/ mini
def regular(options = nil)
  build_with_or_without_options(:regular, options)
end #/ regular
alias :to_str :regular
alias :reg :regular
def title(options = nil)
  build_with_or_without_options(:title, options)
end #/ title
def page_title(options = nil)
  build_with_or_without_options(:page_title, options)
end #/ page_title
def texte(options = nil)
  build_with_or_without_options(:texte, options)
end #/ texte
def large(options = nil)
  build_with_or_without_options(:large, options)
end #/ large
def big(options = nil)
  build_with_or_without_options(:big, options)
end #/ big
def logo(options = nil)
  build_with_or_without_options(:logo, options)
end #/ logo
def build_with_or_without_options(type, options)
  if options.nil?
    @builts ||= {}
    @builts[type] ||= build(type)
  else
    @options = options
    build(type)
  end

end #/ build_with_or_without_options
# ---------------------------------------------------------------------
#   Méthodes fonctionnelles
# ---------------------------------------------------------------------
# Ajoute la valeur valstring
# Cette méthode permet de faire `EMO_TRUC + ISPACE + 'mon string'`
def + valstring
  self.regular + valstring
end #/ +
def absolute?
  @require_full_path === true
end #/ absolute?
def full?
  options && (options[:full] === true)
end #/ full?
TAILLES = {
  mini: 10, small:20, texte: 'height:1.3em;', regular:30, title:60, page_title:45, large:120, big:240, logo:30
}
# NEW_TAILLES correspond à TAILLES ci-dessous mais tient compte du nouveau
# traitement par images de tailles différentes (pour optimisation du
# chargement). Donc, ici, chaque "taille" (:mini, :small, etc.) renvoie à deux
# chose :
# {
#   width:    {Integer} La width qui devra être appliquée
#   suffix:   {String|Symbol} La taille string de l'image ("large", "bigger", etc.)
# }
NEW_TAILLES = {
  mini:       {width: 10,   size_name: 'very-small'},
  small:      {width: 20,   size_name: 'very-small'},
  texte:      {width: 'height:1.3em;', size_name: 'small'},
  regular:    {width: 30,   size_name: 'small'},
  logo:       {width: 30,   size_name: 'small'},
  title:      {width: 60,   size_name: 'regular'},
  none:       {width: nil,  size_name: 'regular'},
  page_title: {width: 45,   size_name: 'regular'},
  large:      {width: 120,  size_name: 'big'},
  big:        {width: 240,  size_name: 'big'},
}
def build taille
  data_taille = NEW_TAILLES[(taille.to_s.nil_if_empty||'none').to_sym]
  size_name = data_taille[:size_name]
  if full?
    # En format full, il faut appliquer les tailles. C'est pour les mails par exemple
    sty = data_taille[:width]
    sty = "width:#{sty}px" if sty && sty.is_a?(Integer)
    IMG_TAG_STYLED % [absolute_path(size_name), name, sty]
  else
    Emoji::IMG_TAG % [absolute_path(size_name), name, taille.to_s]
  end
end #/ build
def name
  @name ||= File.basename(init_relpath)
end #/ name
def relpath(size_name)
  @relpath ||= begin
    "#{init_relpath}#{@is_shadowed ? '-shadowed' : ''}/#{name}#{@is_shadowed ? '-shadowed' : ''}#{size_name ? "-#{size_name}" : ""}.png"
  end
end #/ relpath
def path
  @path ||= File.join('.','img','Emojis',relpath)
end #/ path
def absolute_path(size_name)
  @absolute_path ||= ABSOLUTE_PATH % relpath(size_name)
end #/ absolute_path
end #/Emoji

# ---------------------------------------------------------------------
#
#   CONSTANTES ÉMOJIS
#
# ---------------------------------------------------------------------


EMO_PAPILLON = Emoji.new('animaux/papillon')
EMO_ROBOT = Emoji.new('machine/robot')
EMO_GYROPHARE = Emoji.new('objets/gyrophare')


EMO_RAPPORT = Emoji.new('machine/rapport')
EMO_MANETTE_JEU = Emoji.new('machine/manette-jeu')
EMO_TERRE = Emoji.new('nature/terre')
EMO_POUCEUP = Emoji.new('gestes/pouceup')
EMO_BOITE_DOSSIER = Emoji.new('objets/boite-dossier')
EMO_FICHIER_CRAYON = Emoji.new('objets/fichier-crayon')
EMO_CADENAS_CLE = Emoji.new('objets/cadenas-cle')
EMO_LETTRE_MAIL = Emoji.new('objets/lettre-mail')
EMO_PILE_LIVRES = Emoji.new('objets/pile-livres')
EMO_TABLEAU_SOLEIL = Emoji.new('objets/tableau-soleil')
EMO_SABLIER_COULE = Emoji.new('objets/sablier-coule')
EMO_ARMOIRE = Emoji.new('objets/armoire')
EMO_OUTILS = Emoji.new('objets/outils')
EMO_ECRAN = Emoji.new('objets/ecran')
EMO_TOOLBOX = Emoji.new('objets/toolbox')
EMO_ROUE_DENTEE = Emoji.new('objets/roue-dentee')
EMO_PORTE_VOIX = Emoji.new('objets/porte-voix')
EMO_THERMOMETRE = Emoji.new('objets/thermometre')

EMO_COUCOU_MAIN = Emoji.new('gestes/coucou-main')
EMO_APPLAUSE_LEFT = Emoji.new('gestes/applause-left')
EMO_APPLAUSE_RIGHT = Emoji.new('gestes/applause-right')

EMO_EXCLAMATION = Emoji.new('signes/exclamation')
EMO_BULLE_MESSAGE = Emoji.new('signes/bulle-message')

EMO_FILLE_BLONDE_COUPE_CARREE = Emoji.new('humain/fille-blonde-carre')
EMO_FILLE_ROUSSE_CARREE = Emoji.new('humain/fille-rousse-carre')
EMO_FILLE_BLONDE_CHIGNON = Emoji.new('humain/femme-blond-chignon')
EMO_FEMME_JARDINIER = Emoji.new('humain/femme-jardinier')
EMO_FEMME_CARRE_BLANC = Emoji.new('humain/femme-carre-blanc')
EMO_FEMME_VOILEE = Emoji.new('humain/femme-voilee')
EMO_FILLE_BLONDE_FRISEE = Emoji.new('humain/fille-blonde-frisee')
EMO_EXTRATERRESTRE = Emoji.new('humain/extraterrestre')
EMO_HOMME_BARBE_NOIRE = Emoji.new('humain/homme-barbe-noire')
EMO_HOMME_BRUN_MOUSTACHE = Emoji.new('humain/homme-brun-moustache')
EMO_HOMME_MARRON_MOUSTACHE = Emoji.new('humain/homme-marron-moustache')
EMO_HOMME_NOIR_MOUSTACHE = Emoji.new('humain/homme-noir-moustache')
EMO_HOMME_BRUN = Emoji.new('humain/homme-brun')
EMO_HOMME_NOIR_CHAUVE = Emoji.new('humain/homme-noir-chauve')
EMO_JEUNE_HOMME_BLOND = Emoji.new('humain/jeune-homme-blond')
EMO_ESPIONNE = Emoji.new('humain/espionne')
EMO_ETUDIANT = Emoji.new('humain/etudiant')
EMO_ETUDIANTE = Emoji.new('humain/etudiante')

SMILEY_REFLEXIF = Emoji.new('smileys/reflexif')
