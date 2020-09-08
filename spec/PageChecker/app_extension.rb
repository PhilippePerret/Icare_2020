# encoding: UTF-8
=begin
  Extension propre à l'application pour PageChecker

  Initié pour pouvoir gérer les contextes
=end

class Contexts
class << self
  # Pour faire le check dans le contexte d'un visiteur quelconque
  def context_user
    # Rien à faire
  end #/ context_user
  # Pour faire le check dans le contexte d'un icarien identifié
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
    puts "CURLUSER = #{curluser.inspect} (nom du fichier de contexte)"
    pth = context_file(curluser)
    if PageChecker.online?
      PageChecker.ssh_exec("echo '#{uid}' > #{pth}")
    else
      File.open(pth,'wb'){|f| f.write(uid)}
    end
    # On identifie l'user voulu
    `cUrl -s --cookie-jar cookies.txt #{PageChecker.base}?curluser=#{curluser}`
  end #/ login_user

  def context_file(fname)
    b = PageChecker.online? ? File.join('.','www') : '.'
    File.join(b, 'tmp', fname)
  end #/ context_file

end # /<< self
end #/Contexts
