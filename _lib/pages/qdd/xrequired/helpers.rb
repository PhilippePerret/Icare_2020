# encoding: UTF-8
=begin
  Helpers méthodes pour HTML
=end
class HTML
  def retour_qdd
    @retour_qdd ||= Tag.retour(route:'qdd/home'.freeze, titre:'Qdd'.freeze)
  end #/ retour_qdd
end #/HTML
