# encoding: UTF-8
=begin
  Tests sur la section Documents de l'icarien
=end
require_relative './_required'

feature "Section document" do
  before(:all) do
    require './_lib/required/__first/constants/emojis'
    require './_lib/_pages_/bureau/documents/constants'
  end
  context 'un visiteur quelconque' do
    scenario "ne peut pas rejoindre la section document" do
      goto("bureau/documents")
      expect(page).not_to have_titre(UI_TEXTS[:titre_section_documents])
    end
  end

  context 'un icarien identifié' do
    before(:all) do
      degel('marion_envoie_deux_autres_documents_cycle_complet')
    end
    scenario 'Un icarien peut rejoindre sa section document depuis son bureau' do
      marion.rejoint_son_bureau
      click_on('Documents')
      expect(page).to have_titre(UI_TEXTS[:titre_section_documents])
    end

    scenario 'trouve une section document conforme' do
      marion.rejoint_son_bureau
      click_on('Documents')
      expect(page).to have_titre(UI_TEXTS[:titre_section_documents])
      expect(page).to have_titre(UI_TEXTS[:titre_section_documents], {retour:{route:'bureau/home', text:'Bureau'}})
      expect(page).to have_css('div.icdocuments')
      expect(marion.documents.count).to be(4)
      expect(page).to have_css('span.nombre-documents', text: '4')
      marion.documents.each do |tdocument|
        expect(page).to have_css("div.icdocument#icdocument-#{tdocument.id}")
      end
    end
  end
end
