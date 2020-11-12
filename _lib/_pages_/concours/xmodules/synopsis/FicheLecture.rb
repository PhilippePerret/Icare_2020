# encoding: UTF-8
# frozen_string_literal: true
=begin
  Classe FicheLecture
  -------------------
  Pour la gestion de la fiche de lecture qui sera produite. Attention, cette
  class doit vraiment se consacrer à ça et ne plus s'occuper, par exemple, des
  notes (qui appartiennent au synopsis).
  Tout ce qui est fait ici doit donc concerner spécifiquement la fiche de
  lecture. C'est ici par exemple qu'on détermine les textes explicatifs à
  afficher dans la fiche de lecture, en fonction des notes du Synopsis

  CONTENU D'UNE FICHE DE LECTURE
  ------------------------------
    * Note générale
    * Position par rapport aux autres synopsis
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
require_relative './constants'

class FicheLecture

DATA_MAIN_PROPERTIES = YAML.load_file(DATA_MAIN_PROPERTIES_FILE)


# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :synopsis
def initialize(synopsis)
  @synopsis = synopsis
end #/ initialize

def bind; binding() end

# DO    Produit le fichier HTML de la fiche de lecture (ou peut-être aussi pdf)
def export
  log("---> Export fiche de lecture de “#{synopsis.titre}”")
  res = `/usr/local/bin/wkhtmltopdf "#{App::URL}/concours/fiche_lecture?cid=#{synopsis.concurrent_id}&an=#{Concours.current.annee}" "#{pdf_file_path}" 2>&1`
  log("     Res: #{res.inspect}")
end #/ export
def pdf_file_path
  @pdf_file_path ||=  File.join(TEMP_FOLDER,'concours',pdf_filename)
end #/ pdf_file_path
def pdf_filename
  @pdf_filename ||= "fiche-#{synopsis.concurrent_id}-#{Concours.current.annee}.pdf"
end #/ pdf_filename

# Sortie de la fiche de lecture du synopsis
#
# IN    +options+ Table d'options, cnotient :
#           :format     Le format de sortie (seulement :concurrent pour le
#                       moment, mais ça s'adresse à tout le monde, en fait)
#           :evaluator  Si NIL, c'est la note totale qui est considérée.
#                       Si défini, c'est l'identifiant de l'évaluateur et il
#                       faut afficher la fiche en fonction de ses notes seulement.
#                       Note : tout se joue simplement au niveau du rassemblement
#                       des résultats : si :evaluator est défini, on prend SA
#                       fiche seulement, sinon on prend TOUTES les fiches.
def out(options = nil)
  rassemble_resultats(options)
  dispatche_per_element
  case options[:format]
  when :concurrent
    out_for_concurrent
  else
    puts "Je ne sais pas encore faire ça"
  end
end #/ out

# OUT   True si la fiche de lecture est téléchargeable.
# Note  Pour qu'elle soit téléchargeable, il faut :
#       - qu'elle existe en tant que fichier pdf (dans tmp/concours)
#       - que le concours ne soit plus en phase 1, qu'il soit en phase
#         3 si le concurrent n'a pas été sélectionné pour la phase finale,
#         ou en phase 5 si le concurrent a été sélectionné.
def downloadable?
  Concours.current.phase > 1 && File.exists?(pdf_file_path)
end #/ downloadable?

def download_link
  "#{App::URL}/tmp/concours/#{pdf_filename}"
end #/ download_link

# OUT   Retourne le code HTML de la fiche de lecture complète pour le
#       synopsis.
def out_for_concurrent
  deserb('templates/fiche_lecture_template', self)
end #/ out_for_concurrent

def ecusson
  @ecusson ||= Emoji.new('objets/blason').regular
end #/ ecusson
def annee_edition ; ANNEE_CONCOURS_COURANTE end

def formated_auteurs
  synopsis.real_auteurs
end #/ auteurs

def formated_note
  @formated_note ||= formate_float(synopsis.evaluation.note)
end

def formated_pourcentage
  @f_pourcentage ||= "#{synopsis.evaluation.pourcentage} %"
end #/ formated_pourcentage

# IN    {Symbol} Une catégorie (p.e. :coherence, :personnages, :intrigues)
# OUT   {String} La note à afficher
def fnote_categorie(cate)
  formate_float(synopsis.evaluation.note_categorie(cate))
end #/ note_categorie

def explication_categorie(cate)
  FicheLecture::DATA_MAIN_PROPERTIES[cate][:explication]
end

def explication_categorie_per_note(cate)
  n = synopsis.evaluation.note_categorie(cate)
  return if n.nil?
  FicheLecture::DATA_MAIN_PROPERTIES[cate][key_per_note(n)]
end

def key_per_note(n)
  case n.to_i
  when (20...15)  then :plus15  # 20a16
  when (15..10)   then :moins15
  when (9..5)     then :moins10
  else                 :moins5
  end
end #/ key_per_note

# Position formatée du synopsis par rapport aux autres synopsis
def formated_position
  @formated_position ||= begin
    p = synopsis.position
    pstr = ""
    if not p.nil?
      pstr = p == 1 ? "1<exp>er</exp>" : "#{p}<exp>e</exp>"
      pstr = "#{pstr}#{ISPACE}🏆" if p < 4 # => S'il est primé
    end
    pstr
  end
end #/ position


end #/FicheLecture
