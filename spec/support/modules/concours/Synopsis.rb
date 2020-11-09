# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la class Synopsis pour les tests
=end
class Synopsis
  def reset
    raise "Ne pas utiliser Synopsis#reset. Toujours utiliser Concurrent#reset"
  end #/ reset
  def specs
    raise "Ne pas utiliser Synopsis#specs. Toujours utiliser Concurrent#specs"
  end #/ specs
end #/Synopsis
