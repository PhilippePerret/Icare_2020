# encoding: UTF-8
=begin
  Extension de IcareCLI pour l'aide
=end
class IcareCLI
class << self
  def proceed_help
    require_relative '../help'
    puts AIDE
  end #/ help
end # /<< self
end #/IcareCLI
