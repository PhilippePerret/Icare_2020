# encoding: UTF-8
# frozen_string_literal: true
class Concours
  def save_concours_data
    save({
      theme:param(:concours_theme),
      theme_d:param(:concours_theme_d),
      prix1:param(:concours_prix1),
      prix2:param(:concours_prix2),
      prix3:param(:concours_prix3),
    })
  end #/ save_concours_data
end #/Concours
