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

  def delete
    reffile.close
    File.delete(path)
    @reffile = nil
  end #/ delete

  # DO    Envoi le rapport d'activité du jour à l'administration
  def send
    require_module('mail')
    MailSender.send(file:File.join(__dir__,'report','mail_rapport'), bind: self, no_citation:true)
  end #/ send

  def path
    @path ||= File.join(CRON_FOLDER,'tmp', "report-#{Cronjob.current_time.strftime('%Y-%m-%d')}.txt")
  end #/ path

  def bind; binding() end

end # /<< self
end #/Report
