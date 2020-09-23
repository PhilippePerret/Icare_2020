# encoding: UTF-8
# frozen_string_literal: true
=begin
  Script de traitement des images, pour obtenir une meilleur conformité
  avec les performances.
  Ce script produit toutes les tailles nécessaires de l'image au format
  JPEG 2000. Pour ce faire, il passe en revue toutes les images et convertit
  celles qui manquent. Donc, il suffit de placer l'image dans le dossier ./img
  et le traitement est automatique.

  La balise pour utiliser l'image voulue est de la forme :
    <img src="..." srcset="..., ..., ..." size />
  On peut l'obtenir facilement grâce au script image_tag.rb de ce dossier.

=end


require_relative 'xlib/required'

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
