# encoding: UTF-8
# frozen_string_literal: true
=begin
  class Ticket
  ------------
  Extension pour les helpers
=end
require './_lib/required/__first/helpers/Tag'
class Ticket
  # Retourne le lien pour jouer le ticket dans le mail avec le titre +titre+
  # +options+   Options supplémentaires
  #     :class  La class CSS à utiliser pour le lien
  #
  # [1] Ne pas utiliser distant:true, pour pouvoir essayer le ticket en
  #     local au cours des tests.
  def lien titre, options = nil
    data_lien = options || {}
    route = data_lien[:route]
    route ||= "bureau/home"
    route = "#{route}?tik=#{id}"
    if @authentif_code_genered
      route = "#{route}&tckauth=#{authentif_code_genered}"
    end
    data_lien.merge!(route: route, text:titre, full:true) # [1]
    Tag.lien(data_lien)
  end #/ lien

end #/Ticketa
