# encoding: UTF-8
=begin
  Ce script-test permet de créer des discussions fictives à partir
  des données de l'atelier réel.
=end
feature "Discussion avec les vrais icariens" do
  scenario "Génération des discussion" do
    degel('_real-icare_')
    implementer(__FILE__, __LINE__)
  end
end
