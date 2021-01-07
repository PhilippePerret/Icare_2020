# encoding: UTF-8
# frozen_string_literal: true
class Logger
class << self
  def << msg
    reffile.puts("#{Time.now.strftime('%H:%M:%S')} --- #{msg}")
  end
  def reffile
    @reffile ||= begin
      rf = File.open(path,'a')
      rf.puts("--- #{Time.now.strftime('%d %m %Y - %Hh')} ---")
      rf # pour le rendre
    end
  end #/ reffile

  def path
    @path ||= begin
      File.join(APPFOLDER,'tmp','logs','cronjob.log').tap{|p|`mkdir -p "#{File.dirname(p)}"`}
    end
  end #/ path
end # /<< self
end #/Logger
