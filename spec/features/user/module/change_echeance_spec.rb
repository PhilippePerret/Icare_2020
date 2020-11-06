# encoding: UTF-8
=begin
  Module de test du changement de l'échéance de travail
=end
require_relative './_required'

feature "Changement de l'échéance de travail" do
  before(:all) do
    require './_lib/_pages_/bureau/travail/constants.rb'
    require './_lib/required/__first/extensions/Formate_helpers' # pour formate_date
  end

  context 'Un visiteur quelconque' do
    scenario 'ne peut pas changer une échéance de travail en forçant l’url' do
      route = "bureau/travail?ope=echeance&echeance=22000401" # 1er avril 2200
      goto(route)
      expect(page).not_to have_titre('Votre travail')
      expect(page).to have_titre('Identification')
    end
  end


  context 'Un icarien identifié inactif' do
    before(:all) do
      degel('inscription_benoit')
    end
    scenario 'ne peut pas modifier son échéance de travail' do
      benoit.rejoint_son_bureau
      click_on('Travail courant')
      expect(page).to have_titre("Votre travail")
      expect(page).not_to have_button(UI_TEXTS[:btn_modify_echeance])
    end
  end

  context 'Une icarienne identifiée active' do
    before(:all) do
      degel('change_etape')
      # degel('demarrage_module')
    end

    scenario 'ne peut pas choisir une échéance dans le passé' do
      # Vérifications préliminaires
      new_eche = Time.new(Time.now.year, 1, 1)
      expect(marion.icetape.expected_end).not_to eq(new_eche.to_i)

      pitch("Marion ne peut pas mettre son échéance à une date passée.")
      marion.rejoint_son_bureau
      click_on('Travail courant')
      expect(page).to have_titre("Votre travail")
      expect(page).to have_button(UI_TEXTS[:btn_modify_echeance])
      # On modifie les valeurs
      within("form#change-echeance") do
        select("01", from: 'echeance_day')
        select("janvier", from: 'echeance_month')
        select("#{new_eche.year}", from: 'echeance_year')
        click_on(UI_TEXTS[:btn_modify_echeance])
      end
      pitch("Un message annonce à Marion l'impossibilité de sa nouvelle échéance et ne change pas l'échéance dans ses données")
      expect(page).not_to have_message(MESSAGES[:echeance_changed] % formate_date(new_eche, duree:true))
      expect(page).to have_erreur(ERRORS[:bad_echeance])
      marion.reset
      expect(marion.icetape.expected_end).not_to eq(new_eche.to_i)
    end





    scenario 'ne peut pas choisir la même échéance comme nouvelle échéance' do
      new_eche = Time.at(marion.icetape.expected_end.to_i)
      pitch("Marion ne peut pas mettre son échéance à la même date.")
      marion.rejoint_son_bureau
      click_on('Travail courant')
      expect(page).to have_titre("Votre travail")
      expect(page).to have_button(UI_TEXTS[:btn_modify_echeance])
      # On modifie les valeurs
      within("form#change-echeance") do
        select("#{new_eche.day.to_s.rjust(2,'0')}", from: 'echeance_day')
        select(MOIS[new_eche.month][:long], from: 'echeance_month')
        select("#{new_eche.year}", from: 'echeance_year')
        click_on(UI_TEXTS[:btn_modify_echeance])
      end
      pitch("Un message annonce à Marion l'impossibilité de sa nouvelle échéance et ne change pas l'échéance dans ses données")
      expect(page).not_to have_message(MESSAGES[:echeance_changed] % formate_date(new_eche, duree:true))
      expect(page).to have_erreur(ERRORS[:same_echeance])
    end


    scenario 'peut modifier son échéance de travail' do

      # Vérifications préliminaires
      new_eche = Time.new(Time.now.year, 12, 30)
      expect(marion.icetape.expected_end).not_to eq(new_eche.to_i)

      pitch("Marion peut rejoindre son bureau pour modifier l'échéance de travail de son étape courante.")
      marion.rejoint_son_bureau
      click_on('Travail courant')
      expect(page).to have_titre("Votre travail")
      expect(page).to have_button(UI_TEXTS[:btn_modify_echeance])
      # On modifie les valeurs
      within("form#change-echeance") do
        select("30", from: 'echeance_day')
        select("décembre", from: 'echeance_month')
        select("#{new_eche.year}", from: 'echeance_year')
        click_on(UI_TEXTS[:btn_modify_echeance])
      end
      pitch("Un message annonce à Marion sa nouvelle échéance")
      expect(page).to have_message(MESSAGES[:echeance_changed] % formate_date(new_eche, duree:true))
      pitch("La nouvelle échéance est prise en compte.")
      marion.reset
      expect(marion.icetape.expected_end).to eq(new_eche.to_i.to_s)
    end
  end
end
