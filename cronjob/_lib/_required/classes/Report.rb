# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class Report
  ------------
  Pour produire le rapport qui sera envoyé à l'administration
=end
require 'json'

class Report
DEL_DATA = '°°°°°'
class << self

  # Ajout d'une ligne au rapport
  #
  # +msg+       String  La ligne à ajouter au rapport
  # +options+   Hash    Table d'options
  #               :type   :titre      la ligne est un titre
  #                       :error      C'est une erreur
  #                       :operation  Une opération
  #                       :resultat   Pour le résultat d'une opération
  #
  def add msg, options = nil
    options ||= {}
    options.merge!(time: NOW_S)
    line = [msg.strip, options.to_json].join(DEL_DATA)
    write(line)
    puts msg # feedback
  end #/ add

  def read
    @items ||= []
    return unless File.exists?(report_path)
    File.foreach(report_path) do |line|
      msg, options = line.split(DEL_DATA)
      options = JSON.parse(options).to_sym
      @items << new(msg, options)
    end
  end #/ read

  def write str
    @reffile ||= begin
      File.unlink(report_path) if File.exists?(report_path)
      File.open(report_path,'a')
    end
    @reffile.puts str
  end #/ write

  # Envoi du rapport
  # ----------------
  # Normalement, il est envoyé après toutes les autres opérations de la
  # nuit.
  def send
    require_mail
    self.read
    return if @items.empty? # aucun rapport à faire
    Mail.send({
      to:      PHIL[:mail],
      subject: "Rapport du #{NOW.to_s(jour:true)}",
      message: GABARIT_MESSAGE_RAPPORT % [@items.collect{|i|i.out}.join]
    })
  end #/ send

  def report_path
    @report_path ||= File.join(CJDATA_FOLDER,"report-#{NOW.strftime('%Y-%m-%d')}.txt")
  end #/ report_path

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :content, :params, :type, :time
def initialize msg, params
  @content  = msg
  @params   = params || {}
  @type     = params[:type]
  @time     = params[:time]
end #/ initialize msg

def out
  cont = LINE_CONT % [Time.at(time.to_i).to_s(simple:true), content]
  sty = case type
  when :titre       then 'font-weight:bold;'
  when :error       then 'color:red;'
  when :operation   then 'font-family:courrier;color:blue;'
  when :resultat    then 'color:green;'
  else ''
  end
  cont = LINE_DIV % [sty, cont]
end #/ out
end #/Report

# ---------------------------------------------------------------------
#
#   CONSTANTES
#
# ---------------------------------------------------------------------
GABARIT_MESSAGE_RAPPORT = <<-HTML.strip
<p>Phil,</p>
<p style="font-size:0.85em;">Voici le rapport quotidien du site de l'atelier Icare.</p>
%s
<p>Bien à toi,</p>
<p>Le Bot de l'atelier</p>
HTML

LINE_CONT = '- %s -- %s'
LINE_DIV = '<div style="%s">%s</div>'
