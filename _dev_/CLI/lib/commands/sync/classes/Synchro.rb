# encoding: UTF-8
# frozen_string_literal: true

# Opération principale de synchronisation.
# +operations+ Table contenant les synchronisations à faire :
#   :updates    Liste de SFile à synchroniser
#   :deletes    Liste des fichiers distants à supprimer
def synchronize(operations)
  puts "*** Synchronisation ***".bleu
  operations[:updates].each do |sfile|
    sfile.synchronize
  end
  operations[:deletes].each do |df|
    puts "Pour le moment, je ne détruis pas #{df.inspect}"
  end
end #/ synchronise
