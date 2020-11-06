# encoding: UTF-8
# frozen_string_literal: true
require_relative './_required'
=begin
  Tests des évaluateurs en phase 1

  En phase 1, c'est-à-dire quand le concours est ouvert et que les
  concurrents peuvent s'inscrire, un évaluateur peut déjà consulter et
  évaluer un synopsis qui aurait déjà été déposé.

=end
feature "Possibilité d'un évaluateur en phase 1" do
  before(:all) do
    degel('concours-phase-1')
    @member = TEvaluator.get_random
  end
  let(:member) { @member }
  context 'quand c’est vraiment un évaluateur' do
    scenario 'il peut s’identifier sur le site et voir les concurrents et les synopsis' do
      goto("concours/evaluation")

      # *** Vérifications préliminaires ***
      expect(page).to have_css("form#concours-membre-login")
      expect(page).not_to have_css("div.usefull-links")

      # *** LOGIN ***
      within("form#concours-membre-login") do
        fill_in("member_mail", with: member.mail)
        fill_in("member_password", with: member.password)
        click_on("M’identifier")
      end
      screenshot("after-login-member")
      expect(page).to be_page_evaluation
      expect(page).to have_css("div.usefull-links")

    end
  end
end
