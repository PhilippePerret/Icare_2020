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
    @path ||= File.join(CRON_FOLDER,'tmp','main.log')
  end #/ path
end # /<< self
end #/Logger
