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
    return help if command.nil?
    send(command)
  end #/ run


  def degel
    main_folder_gel = File.join(APP_FOLDER,'spec','support','Gel')
    folder_gels = File.join(main_folder_gel, 'gels')
    gel_name = params[1]
    gel_name ||= begin
      liste_gels = Dir["#{folder_gels}/*"].collect{|p|File.basename(p)}
      Q.select("Dégeler…") do |q|
        q.choices liste_gels
      end
    end
    File.exists?(File.join(folder_gels,gel_name)) || raise("Le gel '#{gel_name}' est inconnu.")
    puts "Je vais dégeler '#{gel_name}'"
  end #/ degel

  def help
    require_relative '../help'
    puts AIDE
  end #/ help
end # /<< self
end #/IcareCLI
