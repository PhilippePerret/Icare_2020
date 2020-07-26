# encoding: UTF-8
require_relative 'handies/messages'
class Messager

DIV_OUT = '<div class="%{css}"><span class="emoji fleft">%{picto}</span>%{str}</div>'.freeze

class << self
  def add msg
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
    @session_id ||= "messages_#{self.name}".freeze
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
  def self.picto ; Emoji.get('panneau/attention').page_title.freeze end
end #/Errorer
class Noticer < Messager
  def self.css_class;'notices' end
  def self.picto ; Emoji.get('geste/parle').page_title.freeze end
end #/Errorer

class Logger
class << self
  def add msg
    if msg.respond_to?(:message)
      # Une erreur par exemple
      msg = "ERROR: #{msg.message}".freeze + RC + msg.backtrace.join(RC)
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
    @path ||= File.join(LOGS_FOLDER,'journal.log')
  end
end #/<< self
end #/Logger
