# encoding: UTF-8
# frozen_string_literal: true
class Concours
  def simuler_step
    step_num = param(:step).to_i
    data_step = STEPS_DATA[step_num]
    res = []
    res << "<div class=\"etape-titre\">Simulation de l'étape #{step_num}. “#{data_step[:name_current]}”…</div>"
    res += data_step[:operations].collect do |dop|
      if dop[:info]
        "🥁 #{dop[:name]}"
      else
        "⚙️ #{dop[:name]}"
      end
    end
    @resultat = res.join(BR)
  end #/ simuler_step
end
