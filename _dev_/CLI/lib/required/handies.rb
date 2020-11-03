# encoding: UTF-8
# frozen_string_literal: true


# Pour les modules empruntés au site, qui n'utilisent pas 'puts'
def log(msg)
  puts msg
end #/ log
def message(msg)
  msg.vert
end #/ message
def erreur(msg)
  msg.rouge
end

def user
  def pseudo; "Phil" end
  def id; 1 end
  def admin?; true end
end #/ user

# OUT   Les choix pour tty-prompt
def formate_choices(command, data)
  data.each do |h|
    next if h[:value].nil?
    h.merge!(name: "#{h[:name]} [#{"'icare #{command} #{h[:value]}'".jaune}]")
  end
  return data
end #/ formate_choices
