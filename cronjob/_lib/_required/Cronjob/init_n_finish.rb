# encoding: UTF-8
=begin
  Initialisation du cronjob
=end
class Cronjob
class << self

  # Initialisation du cronjob
  # -------------------------
  # - définit les travaux dans DATA_WORKS
  def init
    puts "--- CRON JOB DU #{NOW.to_s(jour:true)} ---"
    load_works
  end #/ init

  def finish
    save_works
    puts "\n\n\n"
  end #/ finish

  def load_works
    CJWork.load
  end #/ load_works

  def save_works
    CJWork.save
  end #/ save_works

end # /<< self
end #/Cronjob
