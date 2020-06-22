# encoding: UTF-8
=begin
  Class Tracer
  ------------
  Pour suivre l'activité du site en direct et voir les messages
  d'erreur.

  Pour utiliser ce Tracer en lecture, il faut requérir ce module puis
  définir la méthode Tracer::traite(data) qui va recevoir un hash contenant
  notamment {:message, :data, :backtrace}. Donc d'utiliser :

  class Tracer
    def self.traite(data)
      ... faire quelque chose avec +data+
    end
  end

  # Pour lire le tracer depuis le temps +time+
  Tracer.read(time)

=end
require 'json'

RC = '
' unless defined?(RC)

def trace(data)
  Tracer.add(data)
end #/ trace


class Tracer
DEL = '-:-:-:-'
class << self
  # Pour ajouter des données tracées
  def add(data)
    data = {message: data} if data.is_a?(String)
    data.merge!(ip: ENV['X-Real-IP'] || ENV['REMOTE_ADDR'])
    file.write "#{Time.now.to_i}#{DEL}#{data.to_json}#{RC}"
  end #/ add

  # Pour lire le tracer depuis cette date
  def read(from = nil)
    File.foreach(path) do |line|
      time, data = line.split(DEL)
      next if from && time.to_i < from
      traite(JSON.parse(data))
    end
  end #/ read

  # Si le module qui utilise le Tracer ne définit pas la
  # méthode Tracer#traite(data), le tracer passe simplement
  # par ici
  def traite(data)

  end #/ traite

  # Référence au fichier en ouverture
  def file
    @file ||= File.open(path,'a')
  end #/ file

  # Fichier
  def path
    @path ||= File.join(LOGS_FOLDER,'tracer.log')
  end #/ path
end # /<< self
end #/Tracer
