# encoding: UTF-8
# frozen_string_literal: true
class Concours
  def simuler_step
    data_step = STEPS_DATA[param(:step).to_i]
    res = []
    res << "Simulation de l'étape “#{data_step[:name_current]}”…"
    res += data_step[:operations].collect{|dop| "– #{dop[:name]}"}
    @resultat = res.join(BR)
  end #/ simuler_step
end
