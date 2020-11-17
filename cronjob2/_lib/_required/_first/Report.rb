# encoding: UTF-8
# frozen_string_literal: true
class Report
  pref = ONLINE ? './www' : "#{APPFOLDER}"
  require "#{pref}/_lib/required/__first/helpers/string_helpers_module"
  # => StringHelpersMethods
class << self
  attr_accessor :prefix # à ajouter avant le message
  def << msg
    reffile.puts("#{Time.now} --- #{prefix}#{msg}")
    Logger << "#{prefix}#{msg}"
  end
  def reffile
    @reffile ||= begin
      `mkdir -p "#{File.dirname(path)}"` # au cas où
      File.open(path,'a')
    end
  end #/ reffile

  def delete
    reffile.close
    File.delete(path)
    @reffile = nil
  end #/ delete

  def close
    unless @reffile.nil?
      @reffile.close
      @reffile = nil
    end
  end #/ close

  # DO    Envoi le rapport à l'administrateur, mais seulement s'il n'est pas
  #       vide.
  # Note  Un rapport n'est pas vide si son contenu contient un "RUN IT!"
  def send_if_not_empty
    send if File.read(path).include?('RUN IT!')
  end #/ send_if_not_empty

  # DO    Envoi le rapport d'activité du jour à l'administration
  def send
    close
    require_module('mail')
    MailSender.send(file:File.join(__dir__,'report','mail_rapport'), bind: self, no_citation:true)
  end #/ send

  def path
    @path ||= File.join(CRON_FOLDER,'tmp', "report-#{Cronjob.current_time.strftime('%Y-%m-%d')}.txt")
  end #/ path

  def bind; binding() end

end # /<< self
end #/Report
