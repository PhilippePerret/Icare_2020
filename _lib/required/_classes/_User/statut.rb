# encoding: UTF-8
=begin
  Module pour gérer le statut de l'user
=end
class User

def guest?
  @is_guest = bit_options(16) == 1 if @is_guest.nil?
  @is_guest
end

def icarien?
  @is_icarien = bit_options(16) > 1 if @is_icarien.nil?
  @is_icarien
end

def real?
  @is_real_icarien = bit_options(24) > 1 if @is_real_icarien.nil? # TODO à vérifier
  @is_real_icarien
end #/ real?

def essai?
  !real?
end #/ essai?

def admin?
  @is_admin = bit_options(0) > 0 if @is_admin.nil?
  @is_admin
end

def femme?
  @is_femme = get(:sexe) == 'F' if @is_femme.nil?
  @is_femme
end

def super_admin?
  @is_superadmin = bit_options(0) > 1 if @is_superadmin.nil?
  @is_superadmin
end

def actif?
  statut == :actif
end #/ actif?

def grade
  bit_options(1)
end

def mail_confirmed?
  bit_options(2) == 1
end

def destroyed?
  bit_options(3) == 1
end

def frequence_mail_actu
  case bit_options(4)
  when 0 then :day
  when 1 then :week
  when 9 then :none
  end
end

def statut
  case bit_options(16)
  when 0, 1 then :candidat
  when 2 then check_actif
  when 3 then :en_pause
  when 4 then :inactif
  end
end

def no_mail?
  bit_options(17) == 1
end

def route_after_login
  Route::REDIRECTIONS[bit_redirection][:route]
end

def bit_redirection
  bit_options(18)
end #/ bit_redirection

def type_contact_with_other
  case bit_options[19]
  when 9 then :none
  else :undefined
  end
end

def hide_header?
  @hides_header = bit_options(20) == 1 if @hides_header.nil?
  @hides_header
end

def share_historique?
  @shares_historique = bit_options(21) == 1 if @shares_historique.nil?
  @shares_historique
end

def notify_if_message?
  @notify_if_message = bit_options(22) == 1 if @notify_if_message.nil?
  @notify_if_message
end

def type_contact_with_world
  case bit_options(23)
  when 9 then :none
  else :undefined
  end
end

def bit_options(bit)
  @options ||= get(:options)
  @options[bit].to_i
end

def set_option bit, value
  @options ||= get(:options)
  @options.ljust(bit,'0')
  @options[bit] = value.to_s
  save(options: @options)
end #/ set_option

private

  # Méthode privée qui vérifie que l'icarien est bien actif.
  def check_actif
    if data[:icmodule_id]
      :actif
    else
      set_option(16, 4)
      :inactif
    end
  end #/ check_actif


end
