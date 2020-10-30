# encoding: UTF-8
# frozen_string_literal: true
class IcareCLI
class << self

  # Charge et affiche le contenu du log principal
  def cron_load_and_display_main_log
    display_distant_file("JOURNAL CRON", log_path)
  end

  def log_path
    @log_path ||= './www/tmp/logs/cronjob.log'
  end #/ path

end #/<< self
end #/IcareCLI
