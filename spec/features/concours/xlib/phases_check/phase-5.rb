# encoding: UTF-8
# frozen_string_literal: true
=begin
  Check du bon déroulé de la phase _5
=end

# Le test profond de la phase
def check_phase_5

  # LE TABLEAU DES LAURÉATS
  # ------------------------------
  # Dans la section "Palmarès", on doit pouvoir trouver la liste des lauréats
  fpath = File.join(CONCOURS_PALM_FOLDER,ANNEE_CONCOURS_COURANTE.to_s,"laureats.html")
  expect(File).to be_exists(fpath), "le fichier des lauréats pour la section “Palmarès” du site devrait exister"
  pitch("Le tableau des lauréats et non retenus a été construit")


end


# Avant de procéder au changement de phase, on s'assure d'avoir ce qu'il faut
def ensure_test_phase_5

end
