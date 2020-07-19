# encoding: UTF-8
=begin
  Class IcareCLI
  -----------
  Gestion principale de la ligne de commande
=end
class IcareCLI
  OPTIONS_DIM_TO_REAL = {
    'k' => :keep
  }
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  attr_reader :command, :params, :options
  attr_reader :delim # une ligne pour la console
  def analyse_command
    @command = ARGV[0]&.to_sym
    @params = {}
    @options = {}
    (0...ARGV.length).each do |ivar|
      if ARGV[ivar].start_with?('--')
        @options.merge!(ARGV[ivar][2..-1].to_sym => true)
      elsif ARGV[ivar].start_with?('-')
        @options.merge!(OPTIONS_DIM_TO_REAL[ARGV[ivar][1..-1]] => true)
      else
        @params.merge!(ivar => ARGV[ivar])
      end
    end
    @delim = '-'*40
    puts "\n#{delim}".bleu
    puts "Command: #{command.inspect}".bleu.freeze
    puts "Params : #{params.inspect}".bleu.freeze
    puts "Options: #{options.inspect}".bleu.freeze
    puts delim.bleu
  end #/ analyse_command


  def run
    @command = 'help' if command.nil?
    command_path = File.join(COMMANDS_FOLDER,"#{command}")
    raise "Commande introuvable" unless File.exists?("#{command_path}.rb")
    require(command_path)
    send("proceed_#{command}".to_sym)
  end #/ run

  def option?(key)
    !options[key].nil?
  end #/ option?

end # /<< self
end #/IcareCLI
