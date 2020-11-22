# encoding: UTF-8
# frozen_string_literal: true
=begin
  Exemples partagés pour tester l'accès aux fiches de lecture en fonction
  des phases du concours
=end
RSpec.shared_examples "un visiteur renvoyé à l’identification" do
  it 'est renvoyé à l’identification' do
    goto("concours/evaluation?view=fiches_lecture")
    expect(page).not_to be_fiches_lecture_jury
    expect(page).to be_identification_evaluator
  end
end
RSpec.shared_examples "un juré renvoyé à l'accueil du jury" do |visitor|
  it 'est renvoyé à l’accueil du jury' do
    visitor.rejoint_le_concours if visitor.is_a?(TEvaluator)
    goto("concours/evaluation?view=fiches_lecture")
    expect(page).not_to be_fiches_lecture_jury
    expect(page).to be_accueil_jury
    visitor.se_deconnecte if visitor.is_a?(TEvaluator)
    screenshot("deconnexion-membre-jury")
  end
end

RSpec.shared_examples "un juré renvoyé à la liste des synopsis" do |visitor|
  it 'confirmé' do
    visitor.rejoint_le_concours if visitor.is_a?(TEvaluator)
    goto("concours/evaluation?view=fiches_lecture")
    expect(page).not_to be_fiches_lecture_jury
    expect(page).to be_fiches_synopsis
    expect(page).to have_message("La liste des fiches de lecture n'est pas encore consultable")
    visitor.se_deconnecte if visitor.is_a?(TEvaluator)
    screenshot("deconnexion-membre-jury")
  end
end

RSpec.shared_examples "un juré autorisé à voir les fiches de lecture" do |visitor|
  it 'avec les bonnes informations en fonction de son rang' do
    is_jure = visitor.is_a?(TEvaluator)
    visitor.rejoint_le_concours if is_jure
    goto("concours/evaluation?view=fiches_lecture&ks=note&ss=desc")
    expect(page).to be_fiches_lecture_jury

    # Fonctionnement : on prend les fiches qui sont affichées, dans leur ordre
    actuals = page.all("div#fiches-lecture div.fiche-lecture").collect do |div|
      note = div.find('div.note').text
      note = note.to_f if note != '---'
      syno_id = div[:data_synopsis_id]
      # puts "syno_id: #{syno_id.inspect} / note: #{note.inspect}"
      [syno_id, note]
    end

    # On vérifie que la note affichée soit bien celle du juré et pas celle
    # générale (qui peut cependant être la même).
    actuals.each do |syno_id, note|
      concid, annee = syno_id.split('-')
      # Chemin d'accès au fichier d'évaluation du membre
      path = File.join(CONCOURS_DATA_FOLDER,concid,syno_id,"evaluation-pres-#{visitor.id}.json")
      dscore =  if File.exists?(path)
                  ConcoursCalcul.note_et_pourcentage_from(JSON.parse(File.read(path)))
                else
                  {note: '---'}
                end
      # puts "dscore:#{dscore}"
      # On vérifie que la note affichée soit bien celle du juré
      # puts "#{syno_id}  #{note.to_s.ljust(10)} #{dscore.note.to_s.ljust(10)} #{dscore.pourcentage} %"
      expect(note).to eq(dscore[:note]),
        "La note affichée n'est pas celle du juré #{visitor.id} pour le synopsis #{syno_id} : sur la fiche: #{note}, d'après la fiche d'évaluation : #{dscore[:note]}"
    end

    # pending("Vérifier que les notes soient bien les notes de l'évaluateur")
    if is_jure
    elsif user.admin?
    end
    # TODO
    # pending("Vérifier que l'ordre de classement soit bien celui qui dépend des notes du membre courant")
    # TODO
    visitor.se_deconnecte if is_jure
    screenshot("deconnexion-membre-jury")
  end
end
