# encoding: UTF-8
# frozen_string_literal: true
=begin
  Méthode Cronjob::run
  C'est la méthode principale
=end
class Cronjob
class << self
  def run
    init
    CJWork.run_each_work
    finish
  rescue Exception => e
    puts "CRONJOB RUN ERROR: #{e.message}"
    puts e.backtrace.join("\n")
  end #/ run
end # /<< self
end #/Cronjob
