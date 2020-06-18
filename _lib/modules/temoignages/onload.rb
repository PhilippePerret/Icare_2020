# encoding: UTF-8
=begin
  Pour gérer les témoignages au chargement
=end
require_relative 'Temoignage'
case param(:op)
when 'create-temoignage'
  Temoignage.check_and_create
end
