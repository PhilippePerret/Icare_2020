# encoding: UTF-8
=begin
  Méthodes pratiques pour le test du frigo
=end
CSS_LINK_DISCUSSION_WITH_NEW_MESSAGE = 'a[href="bureau/frigo?disid=%i"].mark-new'
CSS_LINK_DISCUSSION = 'a[href="bureau/frigo?disid=%i"]'

class TUser
  include ::RSpec::Matchers # pour pouvoir utiliser expect
  include Capybara::DSL

def rejoint_son_frigo
  loginit
  goto("bureau/frigo")
end #/ benoit_rejoint_son_frigo

# Pour rejoindre une discussion
# Soit directement, soit depuis l'endroit où se trouve l'user connecté
# +checks+  Peut définir les checks à faire. Cf. mode d'emploi
def rejoint_la_discussion(titre_discussion, checks = nil)
  if page.has_css?('a', text: 'se déconnecter')
    click_on 'Bureau'
    click_on 'Porte de frigo'
  else
    rejoint_son_frigo
  end
  click_on(titre_discussion)
  if checks
    if checks.key?(:new_messages)
      expect(page).to have_new_messages_count(checks[:new_messages])
      expect(page).to have_css('a.mark-lu-btn', count: 2),
        "La page devrait avoir deux liens 'Tout marquer lu'"
    end
    if checks.key?(:participants_nombre)
      expect(page).to have_participants_count(checks[:participants_nombre])
    end
    if checks.key?(:participants_pseudos)
      expect(page).to have_participants_pseudos(checks[:participants_pseudos])
    end
  end
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
