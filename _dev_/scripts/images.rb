# encoding: UTF-8
# frozen_string_literal: true
=begin
  Script de traitement des images, pour obtenir une meilleur conformité
  avec les performances. L'idée est de produire plusieurs tailles pour
  chaque image afin de permettre un choix par le browser.
  L'idée est d'utiliser une balise :
    <img src="..." srcset="..., ..., ..." size />
=end

FOLDER_IMAGES = File.join('./img')

DATA_SIZES = {
  huge:         {name: 'huge',        width: 4000,  height: 2000},
  extra_large:  {name: 'extra-large', width: 2560,  height: 1600},
  very_large:   {name: 'very-large',  width: 1680,  height: 1050},
  large:        {name: 'large',       width: 1080,  height: 680},
  bigger:       {name: 'bigger',      width: 500,   height: 500},
  big:          {name: 'big',         width: 250,   height: 250},
  regular:      {name: 'regular',     width: 100,   height: 100},
  small:        {name:'small',        width: 32,    height: 32},
  very_small:   {name: 'very-small',  width: 20,    height: 20},
}
# Comme une liste (pour être sûr du classement), celle qui servira
# à savoir les tailles qui doivent être faites.
DATA_SIZES_ARRAY = DATA_SIZES.collect{|ids, ds| ds.merge(id: ids)}.sort_by{|ds| ds[:width]}.reverse

class Image
class << self

end # /<< self
attr_reader :path
def initialize(path)
  @path = path
end #/ initialize

# ---------------------------------------------------------------------
#
#   Méthodes de transformation
#
# ---------------------------------------------------------------------
def convert_to_jpeg2000
  `magick "#{path}" "#{jpg2000_path}"`
end #/ convert_to_jpeg2000

# Produit les différentes tailles d'image
# On s'arrange pour avoir cinq tailles max si c'est une grande. Plus
# la taille de départ est petites et moins on en fabrique.
# Il faut donc connaitre la taille initialize de l'image.
def product_sizes
  sizes_required.each do |size_id|
    data_size = DATA_SIZES[size_id]
    sized_path = path_size(data_size[:name])
    next if File.exists?(sized_path)
    # Si l'image n'existe pas, on la crée
    `magick "#{path}" -resize #{data_size[:width]}x#{data_size[:height]} "#{sized_path}"`
  end
end #/ product_sizes

# Retourne la liste des tailles qui doivent être faites en fonction
# de la taille de l'image originale
def sizes_required
  @sizes_required ||= begin
    ary = []
    nombre_tailles = 0
    # puts "ref_value: #{ref_value}"
    DATA_SIZES_ARRAY.collect do |data_size|
      next if data_size[ref_prop] > ref_value
      break if nombre_tailles == 5
      img_path = path_size(data_size[:name])
      nombre_tailles += 1
      ary << data_size[:id]
    end
    ary
  end
end #/ sizes_required

# La propriété (:width ou :height) qu'il faut prendre en référence
def ref_prop
  @ref_prop ||= begin
    initial_width > initial_height ? :width : :height
  end
end #/ ref_prop

# La valeur de référence (en fonction de la propriété de référence)
def ref_value
  @ref_value ||= send("initial_#{ref_prop}".to_sym)
end #/ ref_value
# ---------------------------------------------------------------------
#
#   Méthodes d'état
#
# ---------------------------------------------------------------------
def all_exists?
  return false if not File.exists?(folder)
  return false if not jpeg2000_exists?
  # Vérifie que toutes les tailles nécessaires existent
  sizes_required.each do |size_id|
    return false if not File.exists?(path_size(DATA_SIZES[size_id][:name]))
  end
  return true
end #/ all_exists?

def jpeg2000_exists?
  File.exists?(jpg2000_path)
end #/ jpeg2000_exists?

# ---------------------------------------------------------------------
#
#   Données de l'image
#
# ---------------------------------------------------------------------
def initial_width
  @initial_width ||= begin
    get_initial_size[:width]
  end
end #/ initial_width
def initial_height
  @initial_height ||= get_initial_size[:height]
end #/ initial_height
def get_initial_size
  @get_initial_size ||= begin
    result = `magick identify -format "%w/%h" "#{path}"`
    w, h = result.split('/').collect{|i| i.to_i}
    {height:h, width:w}
  end
end #/ get_initial_size
# ---------------------------------------------------------------------
#
#   Données de path
#
# ---------------------------------------------------------------------
def path_size(size_name)
  File.join(folder, "#{affixe}-#{size_name}.jp2")
end #/ path_size
def jpg2000_path
  @jpg2000_path ||= File.join(folder,"#{affixe}.jp2")
end #/ jpg2000_path
def affixe
  @affixe ||= File.basename(path, File.extname(path))
end #/ affixe
def folder
  @folder ||= begin
    File.join(init_folder, affixe).tap{|p|`mkdir -p "#{p}"`}
  end
end #/ folder
def init_folder
  @init_folder ||= File.dirname(path)
end #/ init_folder
end #/Image

Dir["#{FOLDER_IMAGES}/**/*.{png,jpg}"].each do |imgpath|
  img = Image.new(imgpath)
  STDOUT.write "🌅 IMAGE #{img.affixe}… "
  if img.all_exists?
    puts "déjà traitée."
    next
  end
  # On commence par transformer l'image au format jpeg2000
  img.convert_to_jpeg2000
  # Ensuite, on en fait différents formats (tailles)
  img.product_sizes
  puts "Tailles produites : #{img.sizes_required.join(', ')}"
  # break # Pour essayer une seule
end
