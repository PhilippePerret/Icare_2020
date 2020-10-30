# encoding: UTF-8
# frozen_string_literal: true
class Logger
class << self
  def << msg
    reffile.puts("#{Time.now} --- #{msg}")
  end
  def reffile
    @reffile ||= begin
      File.open(path,'a')
    end
  end #/ reffile

  def path
    @path ||= begin
      File.join(APPFOLDER,'tmp','logs','cronjob.log').tap{|p|`mkdir -p "#{File.dirname(p)}"`}
    end
  end #/ path
end # /<< self
end #/Logger
