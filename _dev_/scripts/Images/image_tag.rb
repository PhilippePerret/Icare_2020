# encoding: UTF-8
# frozen_string_literal: true
=begin

  Écrit en console (pour copie) le code de la tag de l'image

=end

img_relpath = ARGV[0] || "Emojis/animaux/papillon-shadowed.png"


require_relative 'xlib/required'

img_relpath = img_relpath.sub(/^(\.\/)?(img\/)?/,'')
img = Image.new(File.join(FOLDER_IMAGES, img_relpath))
puts img.tag
