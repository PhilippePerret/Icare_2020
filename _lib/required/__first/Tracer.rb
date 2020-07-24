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
  Retourne la liste des lignes lues

  ENV['HTTP_USER_AGENT']    Navigateur et système
  ENV['HTTP_REFERER']       L'adresse courante ? NON
  ENV['REQUEST_URI']              Contient l'URL appelé
  ENV['REDIRECT_QUERY_STRING']    Contient l'URL traitéee
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
DEL = '-:-:-:-'.freeze
DEL_DATA = '-^-'.freeze
class << self
  # Pour ajouter des données tracées
  # +param+
  #   :id       ID de traceur (p.e. 'REDIRECTION')
  #   :message  Le message, qui peut être un argument pour l'id (pe la route
  #             de redirection)
  #   :data     Les données supplémentaires (une table Hash).
  #
  def add(params)
    ip    = ENV['X-Real-IP'] || ENV['REMOTE_ADDR']
    params[:message] ||= ''
    params[:message] = params[:message].gsub(/\r/,'').gsub(/\n/,'\\n')
    data  = [ip, params[:id], params[:message], (params[:data]||{}).to_json]
    file.write "#{Time.now.to_f}#{DEL}#{data.join(DEL_DATA)}#{RC}"
  rescue Exception => e
    msg = e.message + '\n' + e.backtrace.join('\n')
    data = [ip||'', 'ERROR Tracer', msg, '']
    file.write "#{Time.now.to_f}#{DEL}#{data.join(DEL_DATA)}#{RC}"
  end #/ add

  # Pour lire le tracer depuis cette date
  # Retourne la liste des lignes lues
  def read(from = nil)
    lines = []
    file.close unless @file.nil?
    File.foreach(path) do |line|
      time, data = line.split(DEL)
      next if from && time.to_i < from
      lines << line
    end
    return lines
  end #/ read

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
