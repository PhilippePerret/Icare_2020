# encoding: UTF-8
=begin
  Test complet du frigo
=end

# ---------------------------------------------------------------------
#
#   LES UTILITAIRES
#
# ---------------------------------------------------------------------
class TFrigo
class << self
  include Capybara::DSL
  def user_rejoint_son_frigo(udes)
    send("login_#{udes}".to_sym) # par exemple login_benoit
    click_on 'Bureau'
    click_on 'Porte de frigo'
  end #/ user_rejoint_son_frigo
end # /<< self

end #/TFrigo

def benoit_rejoint_son_frigo
  TFrigo.user_rejoint_son_frigo(:benoit)
end #/ benoit_rejoint_son_frigo
def marion_rejoint_son_frigo
  TFrigo.user_rejoint_son_frigo(:marion)
end #/ marion_rejoint_son_frigo
def phil_rejoint_son_frigo
  TFrigo.user_rejoint_son_frigo(:admin)
end #/ phil_rejoint_son_frigo

# ---------------------------------------------------------------------
#
#   LES TESTS
#
# ---------------------------------------------------------------------
feature "Test du frigo" do
  before(:all) do
    degel('benoit_demarre_son_module')
  end
  before(:each) do
    Capybara.reset_sessions!
  end
  scenario "Benoit peut initier une discussion avec Phil", only:true do
    benoit_rejoint_son_frigo
    # Il n'a aucune discussion
    logout
  end

  scenario 'Marion peut initier une discussion avec Phil' do
    marion_rejoint_son_frigo
    logout
  end
end
