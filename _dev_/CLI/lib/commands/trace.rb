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
      affiche_new_lines
    rescue Exception => e
      break if e.message == '' #ctrl c
      unless res.nil?
        puts "Problème à la lecture des lines du traceur : #{e.message}".rouge
        puts "RETOUR: #{res.inspect}".rouge
      end
      sleep FREQUENCE_CHECK
    end while true
  end #/ proceed_trace

  def affiche_new_lines
    new_lines.each do |tline|
      tline.out
    end
  end #/ affiche_new_lines

  def decompose(lines)
    lines.each do |line|
      time, donnees = line.split(Tracer::DEL)
      tline = TracerLine.new(time.to_i, *donnees.split('::'.freeze))
      next if all_lines.key?(tline.time) # une ligne déjà connue
      all_lines.merge!(tline.time => tline)
      new_lines << tline
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
    d = []
    d << Time.at(time).strftime('%d %m %Y - %H:%M'.freeze)
    d << ip_formated
    d << id.ljust(15)
    d << message.to_s
    puts d.join(' | '.freeze)
  end #/ out

  def ip_formated
    if ip.length > 20
      ip[0..19] + '…'
    else
      ip
    end.ljust(21)
  end #/ ip_formated
end
