# encoding: UTF-8
# frozen_string_literal: true
class Concours
  def change_step
    save(step: param(:current_step).to_i)
  end #/ change_step
end
