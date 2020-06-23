# encoding: UTF-8
=begin
  Module pour gérer le statut de l'user
=end
class User

def guest?
  @is_guest = option(16) == 1 if @is_guest.nil?
  @is_guest
end

def icarien?
  @is_icarien = option(16) > 1 if @is_icarien.nil?
  @is_icarien
end

def real?
  @is_real_icarien = option(24) == 1 || admin? if @is_real_icarien.nil?
  @is_real_icarien
end #/ real?

def essai?
  !real?
end #/ essai?

def admin?
  @is_admin = option(0) > 0 if @is_admin.nil?
  @is_admin
end

def femme?
  @is_femme = get(:sexe) == 'F' if @is_femme.nil?
  @is_femme
end

def super_admin?
  @is_superadmin = option(0) > 1 if @is_superadmin.nil?
  @is_superadmin
end

def actif?
  @is_actif = !get(:icmodule_id).nil? if @is_actif.nil?
  @is_actif
end #/ actif?

def grade
  option(1)
end

def mail_confirmed?
  option(2) == 1
end

def destroyed?
  option(3) == 1
end

def frequence_mail_actu
  case option(4)
  when 0 then :day
  when 1 then :week
  when 9 then :none
  end
end

def statut
  return :actif if actif? # bit 16 ne sert plus pour actif
  case option(16)
  when 0, 1 then :candidat
  when 3 then :en_pause
  when 4 then :inactif
  end
end

def no_mail?
  option(17) == 1
end

def route_after_login
  Route::REDIRECTIONS[bit_redirection][:route]
end

def bit_redirection
  option(18)
end #/ bit_redirection

# --- Type de contact ---
# La valeur est un flag qui peut contenir :
#   0:  aucun
#   1:  mail      FLAG_MAIL
#   2:  frigo     FLAG_FRIGO
#   4:  direct    FLAG_DIRECT (quand présent sur le site)
#
# Donc on peut utiliser :
#   if type_contact_admin & FLAG_MAIL
#     # ce qu'on fait si l'icarien peut être contacté par mail
#   end
# 
def type_contact_admin
  bit_option(26)
end #/ type_contact_admin
def type_contact_icariens
  bit_option(27)
end #/ type_contact_icariens
def type_contact_world
  bit_option(28)
end #/ type_contact_world

def hide_header?        ; option?(20)   end
def share_historique?   ; option?(21)   end
def notify_if_message?  ; option?(22)   end

end #/class User
