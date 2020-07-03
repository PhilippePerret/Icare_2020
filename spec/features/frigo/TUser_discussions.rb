# encoding: UTF-8
=begin
  Méthodes pratiques pour le test du frigo
=end
CSS_LINK_DISCUSSION_WITH_NEW_MESSAGE = 'a[href="bureau/frigo?disid=%i"].mark-new'
CSS_LINK_DISCUSSION = 'a[href="bureau/frigo?disid=%i"]'

class TUser
  include ::RSpec::Matchers # pour pouvoir utiliser expect
  include Capybara::DSL

def loginit
  Capybara.reset_sessions!
  goto_login_form
  expect(page).to have_selector('form#user-login')
  within("form#user-login") do
    fill_in('user_mail', with: mail)
    fill_in('user_password', with: password)
    click_on('S’identifier')
  end
end #/ login_it
def rejoint_son_frigo
  loginit
  goto("bureau/frigo")
end #/ benoit_rejoint_son_frigo
def rejoint_son_bureau
  loginit
  goto("bureau/home")
end #/ rejoint_son_bureau

# Pour rejoindre une discussion
# Soit directement, soit depuis l'endroit où se trouve l'user connecté
def rejoint_la_discussion(titre_discussion)
  if page.has_css?('a', text: 'se déconnecter')
    click_on 'Bureau'
    click_on 'Porte de frigo'
  else
    rejoint_son_frigo
  end
  click_on(titre_discussion)
end #/ rejoint_la_discussion

def start_discussion_with_phil(titre, msg)
  within('form#discussion-phil-form') do
    fill_in('frigo_titre', with: titre)
    fill_in('frigo_message', with: msg)
    click_on 'Lancer la discussion avec Phil'
  end
end #/ start_discussion_with_phil

# Méthode pour ajouter un message à une discussion
# Note : on doit se trouver sur la discussion (produit une erreur dans le cas
# contraire)
def add_message_to_discussion(titre_discussion, new_msg)
  expect(page).to have_css('div.titre-discussion', text: titre_discussion),
    "SYSTEM ERROR: On doit se trouver sur la page de la discussion pour utiliser cette méthode"
  within('form#discussion-form') do
    fill_in('frigo_message', with: new_msg)
    click_on 'Ajouter'
  end
end #/ add_message_to_discussion

end #/Class TUser
