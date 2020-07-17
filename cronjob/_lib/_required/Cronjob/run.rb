# encoding: UTF-8
=begin
  Méthode Cronjob::run
  C'est la méthode principale
=end
class Cronjob
class << self
  def run
    puts "J'écrie une première phrase à #{Time.now}."
  rescue Exception => e
    erreur(e)
  end #/ run
end # /<< self
end #/Cronjob
