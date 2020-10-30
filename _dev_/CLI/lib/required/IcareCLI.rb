# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class IcareCLI
  -----------
  Gestion principale de la ligne de commande


  option?(:<long>) pour savoir si une option est activée
=end
class IcareCLI
  OPTIONS_DIM_TO_REAL = {
    'd' => :delete,
    'e' => :errors_only,
    'h' => :help,
    'i' => :infos,
    'k' => :keep,
    'l' => :local,
    'o' => :online,
    'r' => :reparer,
    's' => :simuler,
    'u' => :interactive,
    'v' => :verbose,
  }
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  attr_reader :command, :params, :options
  attr_accessor :verbose
  attr_reader :delim # une ligne pour la console
  def analyse_command
    @command = ARGV[0]&.to_sym
    @params = {}
    @options = {}
    (0...ARGV.length).each do |ivar|
      if ARGV[ivar].start_with?('--')
        opt = ARGV[ivar][2..-1].gsub(/\-/,'_')
        if opt.match?('=')
          opt, val = opt.split('=')
          val = val[1...-1] if val.match?(/^['"](.*)["']$/)
        else
          val = true
        end
        @options.merge!(opt.to_sym => val)
      elsif ARGV[ivar].start_with?('-') # on peut utiliser -eohg
        ARGV[ivar][1..-1].split('').each do |short_opt|
          @options.merge!((OPTIONS_DIM_TO_REAL[short_opt]||short_opt) => true)
        end
      else
        @params.merge!(ivar => ARGV[ivar])
      end
    end
    @delim = '-'*40
    if verbose?
      puts "\n#{delim}".bleu
      puts "Command: #{command.inspect}".bleu
      puts "Params : #{params.inspect}".bleu
      puts "Options: #{options.inspect}".bleu
      puts delim.bleu
    end
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

  def verbose?
    if self.verbose === nil
      option?(:verbose)
    else
      self.verbose
    end
  end #/ verbose?

  # Retourne TRUE si on est en mode simulation
  # Le mode simulation s'obtient en ajoutant -s/--simuler à la commande
  def mode_simulation?
    options[:simuler]
  end #/ mode_simulation?

end # /<< self
end #/IcareCLI
