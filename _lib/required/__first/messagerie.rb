# encoding: UTF-8
# frozen_string_literal: true
require_relative 'handies/messages'
class Messager

DIV_OUT = '<div class="%{css}"><span class="picto-message">%{picto}</span>%{str}</div>'

class << self
  def add msg
    return if msg.nil?
    msg = msg.message if msg.respond_to?(:message)
    @messages ||= []
    @messages << msg.strip
  end
  def out
    return '' if no_messages?
    DIV_OUT % {css:css_class, picto:picto, str: @messages.join(BR).gsub(/#</,'#&lt;')}
  end
  # On met les messages dans une variable session pour une redirection
  def sessionnize
    return if no_messages?
    session[session_id] = @messages.join(';;;')
  end
  # On récupère les messages mis en session pour une redirection
  def desessionnize
    unless session[session_id].nil_if_empty.nil?
      @messages = session[session_id].split(';;;')
      session[session_id] = nil
    end
  end
  def session_id
    @session_id ||= "messages_#{self.name}"
  end
  def no_messages?
    @messages.nil? || @messages.empty?
  end
end #/<< self
end

class Debugger < Messager
  def self.css_class; 'debug' end
  def self.picto ; '' end
end #/Debug
class Errorer < Messager
  def self.css_class;'errors' end
  def self.picto ; Emoji.get('panneau/attention').page_title end
end #/Errorer
class Noticer < Messager
  def self.css_class;'notices' end
  def self.picto ; Emoji.get('gestes/parle').page_title end
end #/Errorer

class Logger
class << self
  def add msg
    if msg.respond_to?(:message)
      # Une erreur par exemple
      msg = "ERROR: #{msg.message}" + RC + msg.backtrace.join(RC)
    elsif msg.is_a?(Hash)
      msg = msg.collect {|k,v| "=== #{k} = #{v.inspect}"}.join(RC)
    end
    ref.write "---[#{Time.now}] #{msg}#{RC}"
    # Dès que le message contient ERROR ou ERREUR, on le trace
    if msg.match?(/(ERROR|ERREUR)/)
      trace(id:'ERROR', message:msg, data:{log_time:Time.now})
    end rescue nil
  end
  def ref
    @ref ||= begin
      File.unlink(path) if RESET_LOG && File.exists?(path)
      File.open(path,'a')
    end
  end
  def path
    @path ||= File.join(LOGS_FOLDER,'journal2020.log')
  end
end #/<< self
end #/Logger
