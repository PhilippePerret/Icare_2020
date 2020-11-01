# encoding: UTF-8
# frozen_string_literal: true
class ConcoursPhase
class Operation
  def bind; binding() end
  # IN    Nom ou chemin relatif du mail
  # OUT   Chemin absolu, pour le déserbage
  def mail_path(mailp)
    File.join(XMODULES_FOLDER,'mails', mailp)
  end #/ mail_path
end #/Operation
end #/Concours
