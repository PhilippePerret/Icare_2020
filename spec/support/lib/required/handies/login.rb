# encoding: UTF-8
=begin
  Méthodes utiles pour les gels
=end

# Raccourcis
def login_marion
  goto_login_form
  login_icarien(1) # User#10
end #/ login_marion
def login_benoit
  goto_login_form
  login_icarien(2) # User#11
end #/ login_benoit
def login_elie
  goto_login_form
  login_icarien(3) # User#12
end #/ login_elie
def login_destroyed
  goto_login_form
  login_icarien(4) # User#13
end #/ login_destroyed

def login_admin
  require './_lib/data/secret/phil'
  goto_login_form
  login_in_form(mail: PHIL_MAIL, password:PHIL_PASSWORD)
end #/ login_admin

# Pour s'identifier sur la page de login
def goto_login_form
  extend SpecModuleNavigation
  goto('user/login'.freeze)
end #/ goto_login_form

def login_in_form(data)
  within("#user-login") do
    fill_in('user_mail', with: data[:mail])
    fill_in('user_password', with:data[:password])
    click_on('S’identifier')
  end
end #/ login

# Pour identifier une icarienne par son index dans les bonnes données
def login_icarien(nth)
  require_data('signup_data')
  data = DATA_SPEC_SIGNUP_VALID[nth]
  login_in_form(mail: data[:mail][:value], password:data[:password][:value])
end #/ login_icarien
# Pour identifier l'administrateur

# Pour se déconnecter
def logout
  click_on(class:'btn-logout')
end #/ logout
