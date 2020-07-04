# encoding: UTF-8
=begin
  Méthode TDD pour l'user
=end
class TUser
  include ::RSpec::Matchers # pour pouvoir utiliser expect
  include Capybara::DSL

  # L'user doit déjà être identifié
  def revient_dans_son_bureau
    click_on 'Bureau'
  end #/ revient_dans_son_bureau

  # Rejoint le bureau par une identification complète
  def rejoint_son_bureau
    loginit
    revient_dans_son_bureau
  end #/ rejoint_son_bureau

  def rejoint_ses_notifications
    loginit
    revient_dans_son_bureau
    click_on 'Notifications'
  end #/ rejoint_ses_notifications

# ---------------------------------------------------------------------
#
#   Méthodes fonctionnelles (privées)
#
# ---------------------------------------------------------------------
private

  def loginit
    Capybara.reset_sessions!
    goto_login_form
    expect(page).to have_selector('form#user-login')
    within("form#user-login") do
      fill_in('user_mail',    with: mail)
      fill_in('user_password', with: password)
      click_on('S’identifier')
    end
  end #/ login_it

end #/TUser
