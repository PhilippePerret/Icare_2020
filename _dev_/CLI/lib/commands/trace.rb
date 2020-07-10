# encoding: UTF-8
=begin
  Pour suivre le traceur en ligne
=end
FREQUENCE_CHECK = 10 # nombre de secondes
require './_lib/required/__first/Tracer'
class IcareCLI
class << self
  attr_accessor :all_lines
  attr_accessor :new_lines
  def proceed_trace
    clear
    puts "Taper Ctrl-C pour arrêter le traceur de l'atelier.".vert
    self.all_lines = {}
    begin
      self.new_lines = []
      res = get_lines
      lines = Marshal.load(res)
      decompose(lines)
      # affiche_new_lines
    rescue Exception => e
      break if e.message == '' #ctrl c
      unless res.nil?
        puts "Problème à la lecture des lines du traceur : #{e.message}".rouge
        puts "RETOUR: #{res.inspect}".rouge
      else
        puts e.message.rouge
      end
    ensure
      sleep FREQUENCE_CHECK
    end while true
  end #/ proceed_trace

  DEL_DATA_ESCAPED = Regexp.escape(Tracer::DEL_DATA)
  def decompose(lines)
    lines.each do |line|
      # puts "line: #{line}"
      time, donnees = line.split(Tracer::DEL)
      next if all_lines.key?(time.to_s) # une ligne déjà connue
      if !line.match?(DEL_DATA_ESCAPED)
        puts "pas le bon délimiteur (#{Tracer::DEL_DATA.inspect}): #{line}".rouge
        next
      end
      donnees = donnees.split(Tracer::DEL_DATA)
      if donnees.count > 4
        puts "La ligne suivante contient trop de données : #{line}.\nJe prends seulement les 4 premières pour renseigner TracerLine".rouge
        donnees = donnees[0..3]
      end
      tline = TracerLine.new(time.to_f, *donnees)
      all_lines.merge!(time => tline)
      puts tline.out # === ÉCRITURE DE LA LIGNE ===
    end
  end #/ decompose

  # Méthode qui va chercher les lignes depuis le temps maintenant - 3600
  # secondes et affiche les nouvelles
  def get_lines
    `ssh #{serveur_ssh} bash <<SSH
ruby <<EOT
Dir.chdir('./www') do
require './_lib/required/__first/Tracer'
puts Marshal.dump(Tracer.read(#{Time.now.to_i - 3600}))
end
EOT
SSH`
  end #/ get_lines

  def serveur_ssh
    @serveur_ssh ||= "icare@ssh-icare.alwaysdata.net"
  end #/ serveur_ssh

end #/<<self
end #/IcareCLI

TracerLine = Struct.new(:time, :ip, :id, :message, :data) do
  attr_accessor :seen
  def out
    msg = []
    msg << Time.at(time).strftime('%d %m %Y %H:%M'.freeze)
    msg << ip_formated
    msg << id.ljust(17)
    msg << message.to_s
    msg = msg.join(' | '.freeze)
    msg = msg.rouge if error?
    return msg
  end #/ out

  def error?
    # puts "id:#{id.inspect} / !!id.match?(/(ERROR|ERREUR)/) = #{(!!id.match?(/(ERROR|ERREUR)/)).inspect}"
    !!id.match?(/(ERROR|ERREUR)/)
  end #/ error?

  def ip_formated
    if ip.length > 20
      ip[0..19] + '…'
    else
      ip
    end.ljust(21)
  end #/ ip_formated
end
