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

def peut_telecharger_une_ancienne_fiche_de_lecture
  it "peut télécharger une ancienne fiche de lecture" do
    goto("concours/espace_personnel")
    expect(page).to have_link("Mes fiches de lecture")
    visitor.click_on("Mes fiches de lecture")
    expect(page).to be_section_fiches_lecture(:concurrent)
    dold = db_exec("SELECT annee FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE concurrent_id = ?", [visitor.id]).first
    expect(dold).not_to eq(nil), "Un ancien concurrent devrait avoir un enregistrement pour un concours précédent… (erreur de test)"
    annee = dold[:annee]
  end

end #/ peut_telecharger_une_ancienne_fiche_de_lecture

# it-case qui teste que le visiteur ne peut pas télécharger sa fiche de
# lecture. Il peut y avoir plusieurs raisons pour ça, qui sont décrites avec
# le paramètre +raison+
#   :new        C'est un nouveau concurrent, il n'a pas de lien le conduisant
#               à sa fiche de lecture avant la phase 5.
#   :too_soon   C'est un ancien concurrent qui peut rejoindre la section des
#               fiche de lecture, mais qui ne trouve pas la fiche de lecture
#               du concours courant car il est trop tôt (phase < 5)
#   :old        C'est un ancien concurrent, mais il ne participe pas au concours
#               courant donc il ne pourra pas avoir de fiche de lecture.
#   :not_want   Il ne veut pas sa fiche de lecture, dans ses préférences.
#
def ne_peut_pas_telecharger_sa_fiche_de_lecture(raison)
  it "ne peut pas telecharger sa fiche de lecture" do
    goto("concours/espace_concurrent")
    expect(page).to be_espace_personnel
    expect(page).not_to have_link("TÉLÉCHARGER LA FICHE DE LECTURE")
    case raison
    when :not_want
      expect(page).not_to have_link("Mes fiches de lecture")
      # --- Essai par lien direct ---
      goto("concours/fiches_lecture")
      expect(page).to be_section_fiches_lecture(as = :concurrent)
      expect(page).to have_content(MESSAGES[:prefs_dont_want_fiches_lecture])
    when :new
      # Le concurrent doit pouvoir atteindre sa liste de fiches de lecture
      expect(page).not_to have_link("Mes fiches de lecture")
      # --- Essai par lien direct ---
      goto("concours/fiches_lecture")
      expect(page).to be_section_fiches_lecture(as = :concurrent)
      expect(page).not_to have_link("Télécharger votre fiche de lecture du concours #{ANNEE_CONCOURS_COURANTE}")
    else
      expect(page).to have_link("Mes fiches de lecture")
      visitor.click_on("Mes fiches de lecture")
      expect(page).to be_section_fiches_lecture(as = :concurrent)
      # Mais on ne trouve pas la fiche de lecture pour le concours courant
      if raison == :too_soon
        expect(page).to have_content("Pas encore de fiche de lecture pour le concours courant (#{TConcours.current.annee})")
      elsif raison == :old
        expect(page).to have_content("Vous ne participez pas au concours courant.")
      else
        raise "Il faut définir la raison qui empêche de télécharger sa fiche de lecture."
      end
    end

  end
end #/
