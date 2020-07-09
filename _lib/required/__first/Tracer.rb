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

unless defined?(RC)
RC = '
'
end
unless defined?(LOGS_FOLDER)
  LOGS_FOLDER = File.expand_path(File.join('.','tmp','logs'))
  `mkdir -p "#{LOGS_FOLDER}"` unless File.exists?(LOGS_FOLDER)
end

def trace(data)
  Tracer.add(data)
end #/ trace


class Tracer
DEL = '-:-:-:-'
class << self
  # Pour ajouter des données tracées
  # +param+
  #   :id       ID de traceur (p.e. 'REDIRECTION')
  #   :message  Le message, qui peut être un argument pour l'id (pe la route
  #             de redirection)
  #   :data     Les données supplémentaires.
  def add(params)
    params[:data] ||= {}
    ip = ENV['X-Real-IP'] || ENV['REMOTE_ADDR']
    file.write "#{Time.now.to_i}#{DEL}#{ip}::#{params[:id]}::#{params[:message]}::#{params[:data].to_json}#{RC}"
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
