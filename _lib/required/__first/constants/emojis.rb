# encoding: UTF-8
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
class Emoji
IMG_TAG = '<img src="%s" alt="%s" class="emoji %s" />'.freeze
IMG_TAG_STYLED = '<img src="%s" alt="%s" class="emoji" style="%s" />'.freeze
ABSOLUTE_PATH = 'http://www.atelier-icare.net/img/Emojis/%s'.freeze
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :init_relpath
def initialize relpath
  relpath = File.join(File.dirname(relpath), File.basename(relpath,File.extname(relpath)) )# enlever .png
  @init_relpath = relpath.freeze
end #/ initialize
# ---------------------------------------------------------------------
#   Méthodes publiques
# ---------------------------------------------------------------------
# Pour définir précisément le format de l'image
def format(params)
  @require_full_path = true if params[:full]
  @is_shadowed = params[:shadowed] === true
  build(params[:class] || 'regular')
end #/ format
def small
  @small ||= build(:small)
end #/ small
def mini
  @mini ||= build(:mini)
end #/ mini
def regular
  @regular ||= build(:regular)
end #/ regular
alias :to_str :regular
alias :reg :regular
def title
  @title ||= build(:title)
end #/ title
def large
  @large ||= build(:large)
end #/ large
def big
  @big ||= build(:big)
end #/ big
# ---------------------------------------------------------------------
#   Méthodes fonctionnelles
# ---------------------------------------------------------------------
def absolute?
  @require_full_path === true
end #/ absolute?
def build taille
  Emoji::IMG_TAG % [(absolute? ? absolute_path : path), name, taille.to_s]
end #/ build
def name
  @name ||= File.basename(init_relpath)
end #/ name
def relpath
  @relpath ||= "#{init_relpath}#{@is_shadowed ? '-shadowed' : ''}.png"
end #/ relpath
def path
  @path ||= File.join('.','img','Emojis',relpath)
end #/ path
def absolute_path
  @absolute_path ||= ABSOLUTE_PATH % relpath
end #/ absolute_path
end #/Emoji

# ---------------------------------------------------------------------
#
#   CONSTANTES ÉMOJIS
#
# ---------------------------------------------------------------------


EMO_PAPILLON = Emoji.new('animaux/papillon')
EMO_ROBOT = Emoji.new('machine/robot')
EMO_TERRE = Emoji.new('nature/terre')
EMO_POUCEUP = Emoji.new('humain/pouceup')
EMO_BOITE_DOSSIER = Emoji.new('objets/boite-dossier')
EMO_FICHIER_CRAYON = Emoji.new('objets/fichier-crayon')
EMO_CADENAS_CLE = Emoji.new('objets/cadenas-cle')
EMO_LETTRE_MAIL = Emoji.new('objets/lettre-mail')
EMO_PILE_LIVRES = Emoji.new('objets/pile-livres')
EMO_TABLEAU_SOLEIL = Emoji.new('objets/tableau-soleil')
EMO_SABLIER_COULE = Emoji.new('objets/sablier-coule')
EMO_GYROPHARE = Emoji.new('objets/gyrophare')

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
