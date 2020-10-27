# encoding: UTF-8
# frozen_string_literal: true
class Report
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
    @path ||= File.join(CRON_FOLDER,'tmp', "report-#{Cronjob.current_time.strftime('%Y-%m-%d')}.txt")
  end #/ path
end # /<< self
end #/Report
