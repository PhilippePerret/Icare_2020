# encoding: UTF-8
# frozen_string_literal: true
=begin
  Tous les IT-CASES pour la fiche de lecture
=end

def peut_rejoindre_la_section_fiches_de_lecture_as(as = nil, msg = nil)
  itstr = "peut rejoindre la section fiches de lecture comme #{as||concurrent}"
  itstr = "#{itstr} avec le message “#{msg}”" if msg
  it itstr do
    goto("concours/fiches_lecture")
    expect(page).to be_section_fiches_lecture(as)
    if msg
      expect(page).to have_content(msg)
    end
  end
end

def ne_peut_pas_atteindre_la_section_fiches_de_lecture
  it "ne peut pas atteindre la section fiches de lecture" do
    goto("concours/fiches_lecture")
    expect(page).not_to be_section_fiches_lecture
  end
end

def peut_telecharger_sa_fiche_de_lecture(as = nil)
  it "peut telecharger sa fiche de lecture depuis l'espace personnel" do
    goto("concours/espace_concurrent")
    expect(page).to be_espace_personnel
    expect(page).to have_link("TÉLÉCHARGER LA FICHE DE LECTURE")
    click_on("TÉLÉCHARGER LA FICHE DE LECTURE")
    expect(page).to be_section_fiches_lecture(as)

  end
  it "peut télécharger sa fiche de lecture depuis la section des fiches de lecture" do
    goto("concours/fiches_lecture")
    expect(page).to be_section_fiches_lecture(as)
  end
end

def peut_telecharger_une_ancienne_fiche_de_lecture(as = :ancien)
  it "peut télécharger une ancienne fiche de lecture" do
    require './_lib/_pages_/concours/espace_concurrent/constants'
    goto("concours/espace_concurrent")
    expect(page).to have_link(UI_TEXTS[:btn_vers_fiches_lecture])
    visitor.click_on(UI_TEXTS[:btn_vers_fiches_lecture])
    expect(page).to be_section_fiches_lecture(:concurrent)
    if as == :ancien
      dold = db_exec("SELECT annee FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE concurrent_id = ?", [visitor.id]).first
      expect(dold).not_to eq(nil), "Un ancien concurrent devrait avoir un enregistrement pour un concours précédent… (erreur de test)"
      annee = dold[:annee]
    end
  end
end #/ peut_telecharger_une_ancienne_fiche_de_lecture
alias :peut_telecharger_ses_fiches_de_lecture :peut_telecharger_une_ancienne_fiche_de_lecture

# it-case qui teste que le visiteur ne peut pas télécharger sa fiche de
# lecture. Il peut y avoir plusieurs raisons pour ça, qui sont décrites avec
# le paramètre +raison+
# OBSOLÈTE
#   :new        C'est un nouveau concurrent, il n'a pas de lien le conduisant
#               à sa fiche de lecture avant la phase 5.
#   :too_soon   C'est un ancien concurrent qui peut rejoindre la section des
#               fiche de lecture, mais qui ne trouve pas la fiche de lecture
#               du concours courant car il est trop tôt (phase < 5)
#   :old        C'est un ancien concurrent, mais il ne participe pas au concours
#               courant donc il ne pourra pas avoir de fiche de lecture.
#   :not_want   Il ne veut pas sa fiche de lecture, dans ses préférences.
#
def ne_peut_pas_telecharger_sa_fiche_de_lecture(raison = nil)
  it "ne peut pas telecharger sa fiche de lecture" do
    require './_lib/_pages_/concours/espace_concurrent/constants'
    goto("concours/espace_concurrent")
    expect(page).to be_espace_personnel
    expect(page).not_to have_link("TÉLÉCHARGER LA FICHE DE LECTURE")
  end
end #/
