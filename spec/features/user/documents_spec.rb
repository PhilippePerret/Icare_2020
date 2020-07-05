# encoding: UTF-8
=begin
  Tests sur la section Documents de l'icarien
=end
feature "Section document" do
  scenario "Un non icarien en peut pas rejoindre la section document" do
    goto("bureau/documents")
    expect(page).not_to have_titre('Vos documents')
  end

  scenario 'Un icarien peut rejoindre sa section document', only:true do
    degel('marion_envoie_deux_autres_documents_cycle_complet')
    marion.rejoint_son_bureau
    click_on('Documents')
    expect(page).to have_titre('Vos documents')
    expect(page).to have_titre('Vos documents', {retour:{route:'bureau/home', text:'Bureau'}})
    expect(page).to have_css('div.documents')
    expect(marion.documents.count).to be(4)
    expect(page).to have_css('span.nombre-documents', text: '4')
    marion.documents.each do |tdocument|
      expect(page).to have_css("div.document#document-#{tdocument.id}")
    end

  end
end
