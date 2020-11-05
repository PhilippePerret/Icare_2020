# encoding: UTF-8
# frozen_string_literal: true
=begin
  Script de traitement des images, pour obtenir une meilleur conformité
  avec les performances.

  LANCEMENT
  ---------
    Pour qu'il fonctionne, on doit le lancer dans le terminal :

      cd /Users/philippeperret/Sites/AlwaysData/Icare_2020
      ruby ./_dev_/scripts/Images/convert_images.rb

  RÉGLAGE
  -------
    Avant de le lancer, il faut définir ci-dessous si l'on doit traiter :
      - une image seule
      - un sous-dossier
      - tout le dossier images

  DESCRIPTION
  -----------
  Ce script produit toutes les tailles nécessaires de l'image au format
  JPEG 2000. Pour ce faire, il passe en revue toutes les images et convertit
  celles qui manquent. Donc, il suffit de placer l'image dans le dossier ./img
  et le traitement est automatique.

  La balise pour utiliser l'image voulue est de la forme :
    <img src="..." srcset="..., ..., ..." size />
  On peut l'obtenir facilement grâce au script image_tag.rb de ce dossier.

=end

# Pour traiter une unique image, indiquer son chemin relatif depuis le
# dossier image (./img), avec l'extension.
# Sinon, excommenter cette ligne.
IMAGE_SEULE_RELPATH = "Emojis/objets/coupe.png"

# Pour traiter seulement un sous-dossier du dossier images, décommenter la
# ligne suivante en indiquant le sous-dossier
# FOLDER_ONLY_IMAGES = "Emojis/animaux"

# Note si aucun des IMAGE_SEULE_RELPATH ou FOLDER_ONLY_IMAGES n'est défini,
# c'est tout le dossier images (./img) qui sera traité


require_relative 'xlib/required'

# L'expression régulière qui va permettre de ne pas faire des réductions de
# réductions de réductions…
REG_END_PASSE = /\-(regular|big|small|large)\.(png|jp2)/

puts "FOLDER_IMAGES: #{File.expand_path(FOLDER_IMAGES)}"

def traite_image(imgpath)
  File.exists?(imgpath) || begin
    puts "IMAGE INTROUVABLE : #{imgpath}…"
    return
  end
  img = Image.new(imgpath)
  STDOUT.write "🌅 IMAGE #{img.affixe}… "
  if img.all_exists?
    puts "déjà traitée."
    return
  end
  # On commence par transformer l'image au format jpeg2000
  img.convert_to_jpeg2000
  # Ensuite, on en fait différents formats (tailles)
  img.product_sizes
  puts "Tailles produites : #{img.sizes_required.join(', ')}"
end #/ traite_image

def traite_dossier(dospath)
  Dir["#{dossier_treatables}/**/*.{png,jpg}"].each do |imgpath|
    if imgpath.match?(/\-(regular|big|small|large|bigger|huge)\.(png|jpg|jp2)$/)
      next
    end
    traite_image(imgpath)
    # break # Pour essayer une seule
  end
end #/ traite_dossier


if defined?(IMAGE_SEULE_RELPATH)
  traite_image(File.join(FOLDER_IMAGES,IMAGE_SEULE_RELPATH))
elsif defined?(FOLDER_ONLY_IMAGES)
  traite_dossier(FOLDER_ONLY_IMAGES)
else
  traite_dossier(FOLDER_IMAGES)
end
