# encoding: UTF-8
=begin
  Class IcareCLI
  -----------
  Gestion principale de la ligne de commande
=end
class IcareCLI
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  attr_reader :command, :params
  attr_reader :delim # une ligne pour la console
  def analyse_command
    @command = ARGV[0]&.to_sym
    @params = {}
    (1..5).each do |ivar|
      @params.merge!(ivar => ARGV[ivar])
    end
    @delim = '-*40'
    puts "\n"+delim
    puts "Command: #{command.inspect}"
    puts "Params : #{params.inspect}"
  end #/ analyse_command


  def run
    @command = 'help' if command.nil?
    command_path = File.join(COMMANDS_FOLDER,"#{command}")
    raise "Commande introuvable" unless File.exists?("#{command_path}.rb")
    require(command_path)
    send("proceed_#{command}".to_sym)
  end #/ run

end # /<< self
end #/IcareCLI
