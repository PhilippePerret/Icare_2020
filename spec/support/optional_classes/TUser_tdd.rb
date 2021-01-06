# encoding: UTF-8
=begin
  Méthode TDD pour l'user
=end
class TUser
  include ::RSpec::Matchers # pour pouvoir utiliser expect
  include Capybara::DSL

  def survol_header
    # En fait, maintenant, il faut cliquer sur l'entête
    # find('section#header').hover
    find('section#header').click
  end #/ survol_header

  # L'user doit déjà être identifié
  def revient_dans_son_bureau
    survol_header
    if page.has_css?('a', text: 'Bureau')
      click_on 'Bureau'
    else
      click_on 'bureau' # home page vraie
    end
  end #/ revient_dans_son_bureau

  # Rejoint le site (signifie qu'il va s'identifier)
  def rejoint_le_site
    # puts "\t-> rejoint le site avec (#{pseudo}/#{password})"
    loginit
  end #/ rejoint_le_site

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

  def fill_and_submit_login_form
    within("form#user-login") do
      fill_in('user_mail',    with: mail)
      fill_in('user_password', with: password)
      click_on(UI_TEXTS[:btn_login])
    end
  end #/ fill_and_submit_login_form

# ---------------------------------------------------------------------
#
#   Méthodes d'interaction avec la page
#
# ---------------------------------------------------------------------
def click(what, options = nil)
  options ||= {}
  options.merge!(within: 'body') unless options.key?(:within)
  bouton = nil
  within(options[:within]) do
    bouton = page.first('*', text: what) if page.has_css?('*', text: what)
    bouton = page.first(".#{what}") if bouton.nil? && page.has_css?(".#{what}")
    bouton = page.first("##{what}") if bouton.nil? && page.has_css?("##{what}")
  end
  # puts "bouton: #{bouton}"
  bouton || raise("Le bouton défini par #{what.inspect} est introuvable, ni en tant que texte, ni en tant qu'identifiant, ni en tant que classe CSS.")
  bouton.click
end #/ click

# ---------------------------------------------------------------------
#
#   Méthodes fonctionnelles (privées)
#
# ---------------------------------------------------------------------
private

  def loginit
    require "#{FOLD_REL_PAGES}/user/login/constants"
    Capybara.reset_sessions!
    goto_login_form
    expect(page).to have_selector('form#user-login')
    fill_and_submit_login_form
  end #/ login_it

end #/TUser
