# encoding: UTF-8
# frozen_string_literal: true
=begin

  Écrit en console (pour copie) le code de la tag de l'image

=end

IMAGE_FOR_TAG = "Emojis/animaux/papillon-shadowed.png"


require_relative 'xlib/required'

img = Image.new(File.join(FOLDER_IMAGES, IMAGE_FOR_TAG))
puts img.tag
