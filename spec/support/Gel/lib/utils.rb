# encoding: UTF-8
=begin
  Méthodes utiles pour les gels
=end
def goto route
  visit "#{SpecModuleNavigation::URL_OFFLINE}/#{route}".freeze
end #/ goto

# Pour s'identifier sur la page de login
def goto_login_form
  goto('user/login'.freeze)
end #/ goto_login_form

def login(data)
  within("#user-login") do
    fill_in('user_mail', with: data[:mail])
    fill_in('user_password', with:data[:password])
    click_on('S’identifier')
  end
end #/ login

# Pour identifier une icarienne par son index dans les bonnes données
def login_icarien(nth)
  data = DATA_SPEC_SIGNUP_VALID[nth]
  login(mail: data[:mail][:value], password:data[:password][:value])
end #/ login_icarien
# Pour identifier l'administrateur

def login_admin
  require './_lib/data/secret/phil'
  login(mail: PHIL_MAIL, password:PHIL_PASSWORD)
end #/ login_admin

# Pour se déconnecter
def logout
  click_on(class:'btn-logout')
end #/ logout
