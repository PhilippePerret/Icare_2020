# encoding: UTF-8
=begin
  Extension propre à l'application pour PageChecker

  Initié pour pouvoir gérer les contextes
=end

class Contexts
class << self
  def context_icarien
    login_user(12)
    puts "Icarien(ne) identifié(e)".vert
  end #/ context_icarien

  def context_administrateur
    login_user(1)
    puts "Administrateur identifié".vert
  end #/ context_administrateur

private

  def login_user(uid)
    require 'securerandom'
    curluser = SecureRandom.hex(10)
    pth = File.join('.','tmp', curluser)
    File.open(pth,'wb'){|f| f.write(uid)}
    res = `cUrl -s --cookie-jar cookies.txt http://localhost/AlwaysData/Icare_2020/?curluser=#{curluser}`
    # res = `cUrl -s --cookie cookies.txt --cookie-jar cookies.txt http://localhost/AlwaysData/Icare_2020/bureau/home`
  end #/ login_user

end # /<< self
end #/Contexts
