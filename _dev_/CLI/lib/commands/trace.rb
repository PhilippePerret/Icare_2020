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
    puts "Traceur #{online? ? 'ONLINE' : 'OFFLINE (ajouter -o pour tracer en distant)'}"
    puts "Afficher #{only_errors? ? 'seulement les erreurs (retirer -e/--errors_only pour tout voir)' : 'tout (ajouter -e/--errors_only pour voir seulement les erreurs)'}"
    puts "Taper Ctrl-C pour arrêter le traceur de l'atelier.".vert
    self.all_lines = {}
    begin
      self.new_lines = []
      lines = get_lines
      decompose(lines)
      # affiche_new_lines
    rescue Exception => e
      break if e.message == '' #ctrl c
      unless res.nil?
        puts "Problème à la lecture des lines du traceur : #{e.message}".rouge
        puts e.backtrace.join("\n").rouge
      else
        puts e.message.rouge
      end
    ensure
      sleep FREQUENCE_CHECK
    end while true
  end #/ proceed_trace


  def online?
    @for_online = option?(:online) if @for_online.nil?
    @for_online
  end #/ online?

  def only_errors?
    @require_only_errors = option?(:errors_only) if @require_only_errors.nil?
    @require_only_errors
  end #/ only_errors?


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
      # === ÉCRITURE DE LA LIGNE ===
      next if only_errors? && !tline.error?
      puts tline.out
    end
  end #/ decompose

  # Méthode qui va chercher les lignes depuis le temps maintenant - 3600
  # secondes et affiche les nouvelles
  def get_lines
    online? ? Marshal.load(get_lines_distant) : get_lines_local
  end #/ get_lines

  def get_lines_local
    Tracer.read(Time.now.to_i - 3600)
  end #/ get_lines_local

  def get_lines_distant
    `ssh #{serveur_ssh} bash <<SSH
ruby <<EOT
Dir.chdir('./www') do
require './_lib/required/__first/Tracer'
puts Marshal.dump(Tracer.read(#{Time.now.to_i - 3600}))
end
EOT
SSH`
  end #/ get_lines_distant

  def serveur_ssh
    @serveur_ssh ||= "icare@ssh-icare.alwaysdata.net"
  end #/ serveur_ssh

end #/<<self
end #/IcareCLI

TracerLine = Struct.new(:time, :ip, :id, :message, :datastr) do
  attr_accessor :seen
  def out
    msg = []
    msg << Time.at(time).strftime('%d %m %H:%M'.freeze)
    msg << ip_formated
    msg << id.ljust(15)
    msg << pseudo_if_identified
    msg << formated_message.to_s
    msg = msg.join(' | '.freeze)
    msg = msg.rouge if error?
    return msg
  end #/ out

  def data
    @data ||= JSON.parse(datastr.strip)
  end #/ data

  def error?
    # puts "id:#{id.inspect} / !!id.match?(/(ERROR|ERREUR)/) = #{(!!id.match?(/(ERROR|ERREUR)/)).inspect}"
    !!id.match?(/(ERROR|ERREUR)/)
  end #/ error?

  def pseudo_if_identified
    if data.key?('user')
      ps = TracerUser.new(*data['user']).pseudo
      ps = ps[0...10] + '…' if ps.length > 10
      ps
    else
      ''
    end.ljust(10)
  end #/ pseudo_if_identified

  def ip_formated
    if ip.length > 15
      ip[0...15] + '…'
    else
      ip
    end.ljust(16)
  end #/ ip_formated
  def formated_message
    if error?
      'cf. l’erreur ci-dessous' + RC + message.gsub(/\\n/,"\n")
    else
      message
    end
  end #/ formated_message

end #/TracerLine


TracerUser = Struct.new(:id, :pseudo, :mail) do

end #/TracerUser
