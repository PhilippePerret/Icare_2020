# encoding: UTF-8
# frozen_string_literal: true
class IcareCLI
class << self

  def proceed_concours_fiches_lecture
    Dir.chdir(APP_FOLDER) do
      load './_dev_/Concours_synopsis/FICHES_LECTURE/runner.rb'
    end
  end
end #/<< self
end #/IcareCLI
