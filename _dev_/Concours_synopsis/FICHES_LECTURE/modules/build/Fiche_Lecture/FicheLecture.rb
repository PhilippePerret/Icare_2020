# encoding: UTF-8
# frozen_string_literal: true
=begin
  Classe FicheLecture
  -------------------
  Pour la gestion de la fiche de lecture qui sera produite. Attention, cette
  class doit vraiment se consacrer à ça et ne plus s'occuper, par exemple, des
  notes (qui appartiennent au projet).
  Tout ce qui est fait ici doit donc concerner spécifiquement la fiche de
  lecture. C'est ici par exemple qu'on détermine les textes explicatifs à
  afficher dans la fiche de lecture, en fonction des notes du Synopsis

  CONTENU D'UNE FICHE DE LECTURE
  ------------------------------
    * Note générale
    * Position par rapport aux autres projet
    * Notes par grandes catégories (Personnages, Forme/Intrigues, Thèmes,
      Rédaction)
    * Note de cohérence
      Rassemble les valeurs de toutes les "cohérences" pour faire un sujet
      général
    * Note d'adéquation au thème
      Rassembler toutes les valeurs d'adéquation avec le thème pour faire
      un sujet général
    * Note d'équilibre U/O (facteur U et facteur O)

=end
require 'yaml'
require 'erb'
require_relative '../constants'
require_relative '../Projet'


class FicheLecture

DATA_MAIN_PROPERTIES = YAML.load_file(DATA_MAIN_PROPERTIES_FILE)

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :projet
def initialize(projet)
  @projet = projet
end #/ initialize

# Construction de la fiche de lecture
#
# Ça consiste à :
#   1. produire le fichier HTML
#   2. transformer le fichier HTML en fichier PDF
def build
  File.delete(html_file)  if File.exists?(html_file)
  File.delete(pdf_file)   if File.exists?(pdf_file)
  build_HTML_file || return
  # build_PDF_file
  build_with_whtmltopdf
end #/ build

def build_with_whtmltopdf
   res = `/usr/local/bin/wkhtmltopdf "file://#{html_file}" "#{pdf_file}" 2>&1`
   # puts "Retour : #{res.inspect}"
end #/ build_with_whtmltopdf

def build_HTML_file
  File.open(html_file,'wb'){|f|f.write(out)}
  return File.exists?(html_file)
end
def build_PDF_file
  res = `#{EBOOK_CONVERT_CMD} '#{html_file}' '#{pdf_file}' 2>&1`
  # puts "Res : #{res.inspect}"
end
def html_file
  @html_file ||= File.join(projet.folder,'fiche_lecture.html')
end
def pdf_file
  @pdf_file ||= File.join(projet.folder,pdf_fname)
end
def pdf_fname; @pdf_fname ||= "FL-#{projet.concurrent_id}-#{annee_edition}.pdf" end

def bind; binding() end

# Sortie de la fiche de lecture du projet
#
# Quand la méthode est appelée sans aucun argument, cela signifie qu'on doit
# retourner la fiche de lecture pour le visiteur courant (qui peut être admin,
# concurrent ou membre du jury) et la phase courante du concours.
#
# IN    +options+ Table d'options, cnotient :
#           :prix       True ou False suivant qu'on veuille voir la fiche de
#                       lecture pour le prix ou pour les présélections.
#           :admin      True/False — pour savoir si c'est pour un administrateur
#                       Un administrateurp peut voir sa note (if any) et la
#                       note générale.
#           :evaluator  Si NIL, c'est la note totale qui est considérée.
#                       Si défini, c'est l'identifiant de l'évaluateur et il
#                       faut afficher la fiche en fonction de ses notes seulement.
#                       Note : tout se joue simplement au niveau du rassemblement
#                       des résultats : si :evaluator est défini, on prend SA
#                       fiche seulement, sinon on prend TOUTES les fiches.
def out
  ERB.new(template).result(self.bind)
end #/ out

def template
  File.read(template_path).force_encoding('utf-8')
end

def template_path
  File.expand_path(File.join(__dir__,'..','assets','fiche_lecture_template.erb'))
end

def styles_css_code
  @styles_css_code ||= begin
    '<style type="text/css">' + File.read(cssfile_path).force_encoding('utf-8') + '</style>'
  end
end #/ styles_css_code

def cssfile_path
  File.expand_path(File.join(__dir__,'..','assets','fiche_lecture.css'))
end

# Une des méthodes principales qui retourne le texte dynamique en fonction
# de la note et du contexte.
# - La méthode récupère le texte adéquat dans le fichier
#   'textes_fiches_lecture.yaml', au niveau du A, B, C ou D.
# - Elle le met ensuite en forme en fonction des balises.
#
def explication_categorie_per_note(cate)
  n = note_categorie(cate)
  return if n.nil? || n == 'NC'
  traite_balises_in(FicheLecture::DATA_MAIN_PROPERTIES[cate][key_per_note(n)])
end

# / Fin des balises
# ---------------------------------------------------------------------

def noteOf(key)
  if not projet.evaluation.categories.key?(key)
    key = case key
    when 'projet'       then 'po'
    when 'originalité'  then 'fO'
    when 'universalité' then 'fU'
    when 'personnages'  then 'p'
    when 'forme', 'structure' then 'f'
    when 'intrigues'    then 'i'
    when 'thèmes'       then 't'
    when 'rédaction'    then 'r'
    when 'clarté'       then 'cla'
    when 'simplicité'   then 'sim'
    end
  end
  if projet.evaluation.categories.key?(key)
    projet.evaluation.categories[key][:note]
  else
    puts "ERR: Impossible de trouve la catégorie de clé '#{key}'…".rouge
    return 0.0
  end
end #/ noteOf

def avertissement_subjectivite
  FicheLecture::DATA_MAIN_PROPERTIES[:subjectivite]
end

def note_categorie(cate)
  projet.evaluation&.note_categorie(cate) || 'NC'
end #/ note_categorie

# Retourne la note pour la catégorie +cate+
def fnote_categorie(cate)
  projet.formate_note(note_categorie(cate))
end #/ fnote_categorie

def explication_categorie(cate)
  FicheLecture::DATA_MAIN_PROPERTIES[cate][:explication]
end



def key_per_note(n)
  case n
  when 15.0..20.0   then  'A'   # 15 compris à 20
  when 10.0...15.0  then  'B'   # 10 compris à 15 non compris
  when 5.0...10.0   then  'C'   # 5 compris à 10 non compris
  when 0.0...5.0    then  'D'   # 0 à 5 non compris
  else :not_evaluated
  end
end #/ key_per_note

end #/FicheLecture
