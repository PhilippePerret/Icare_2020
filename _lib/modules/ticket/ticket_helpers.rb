# encoding: UTF-8
=begin
  class Ticket
  ------------
  Extension pour les helpers
=end
class Ticket
  # Retourne le lien pour jouer le ticket dans le mail avec le titre +titre+
  # +options+   Options supplémentaires
  #     :class  La class CSS à utiliser pour le lien
  def lien titre, options = nil
    data_lien = options || {}
    data_lien.merge!(text:titre, full:true, route:"ticket?tik=#{id}")
    Tag.lien(data_lien)
  end #/ lien

end #/Ticketa
