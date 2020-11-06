# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module de test d'un témoignage

  - créer le témoignage
  - valider le témoignage (administrateur)
  - plébisciter un témoignage (icarien)
  - supprimer un témoignage (administrateur)
  - modifier un témoignage (administrateur seulement)
=end
require_relative './_required'

feature 'Le Témoignages' do
  def prepare_dernier_etape_pour_marion
    degel('marion_paie_son_module')
    # Et on met son absetape à la dernière étape du module
    # puts marion.icetape.inspect
    absmodule_id = marion.icmodule.absmodule_id
    # puts "Module absolu : #{marion.icmodule.absmodule_id}"
    request = "SELECT * FROM absetapes WHERE absmodule_id = #{absmodule_id} ORDER BY numero DESC LIMIT 1"
    result = db_exec(request)
    last_absetape_id = result.first[:id]
    # puts "last_absetape_id: #{last_absetape_id}"
    marion.icetape.set(absetape_id: last_absetape_id)
  end #/ prepare_dernier_etape_pour_marion

  before(:all) do
    require './_lib/modules/temoignages/constants'
    vide_dossier_mails
  end



  context 'Un icarien' do
    scenario 'peut enregistrer un témoignage dans sa dernière étape', gel: true do
      prepare_dernier_etape_pour_marion
      BTN_NAME = 'Enregistrer ce témoignage'
      TEM_MSG  = "Le témoignage de Marion, datant du #{formate_date}.#{RC*2}C'est un bon témoignage."

      pitch("Marion peut rejoindre le site et enregistrer son témoignage lors de sa dernière étape.")
      marion.rejoint_son_bureau
      marion.click_on('Travail courant')
      expect(page).to have_css('form#temoignage-form'),
        "Marion devrait trouver un formulaire pour enregistrer son témoignage."
      expect(page).to have_css('textarea#temoignage_content'),
        "Marion devrait trouver un champ pour entrer son témoignage."
      expect(page).to have_button(BTN_NAME),
        "Marion devrait trouver un bouton pour enregistrer le témoignage"

      start_time = Time.now.to_i
      vide_dossier_mails

      pitch("Si marion ne rentre pas de texte, un message d'alerte est affiché et rien n'est enregistré.")
      click_on(BTN_NAME)
      expect(page).to have_erreur("Il faut écrire votre témoignage")
      result = db_get('temoignages', {user_id: marion.id, absmodule_id: marion.icmodule.absmodule_id})
      expect(result).to eq(nil)

      pitch("Si marion rentre son texte, le témoignage est consigné correctement")
      find('form#temoignage-form').fill_in('temoignage_content', with: TEM_MSG)
      find('form#temoignage-form').click_on(BTN_NAME)

      # Un enregistrement dans la table, avec les bonnes valeurs
      result = db_get('temoignages', {user_id: marion.id, absmodule_id: marion.icmodule.absmodule_id})
      expect(result).not_to eq(nil)
      expect(result[:confirmed]).to eq(0)
      expect(result[:content]).to eq(TEM_MSG)
      # Un message de confirmation
      expect(page).to have_message("Votre témoignage a été enregistré")
      # Un mail qui m'est envoyé
      expect(phil).to have_mail(after:start_time, subject:MESSAGES[:tem_subject_mail_validation])

      logout

      gel("marion-avec-un-temoignage", <<-TEXT)
Dans ce gel, Marion est à la dernière étape de son module Analyse et
laisse un témoignage sur son travail à l'atelier.
Donc ce témoignage n'est pas validé, et ne doit pas apparaitre dans la
liste des témoignages.
      TEXT
    end


    scenario 'ne peut pas valider un témoignage' do
      pitch("Marion revient sur le site et essaie de forcer la validation de son témoignage. Elle n'y parvient pas.")
      degel("marion-avec-un-temoignage")
      marion.rejoint_son_bureau
      # Elle trouve son témoignage à valider sur la page des témoignages
      goto("overview/temoignages")
      expect(page).to have_css("fieldset#temoignage-a-valider")
      # Mais elle ne peut pas le valider en forcer l'url
      tem_id = db_get('temoignages', {user_id:marion.id, confirmed:false})[:id]
      goto("admin/temoignages?operation=valider-temoignage&temid=#{tem_id}")
      screenshot('marion-force-validation-temoignage')
      # Marion ne doit pas voir son témoignage (ou plutôt si : mais en indiquant qu'il n'est pas validé)
      # Le témoignage reste à valider
      tem2validate = db_get('temoignages', {user_id:marion.id, confirmed:false})
      expect(tem2validate).not_to eq(nil)
      logout
    end

  end


  context 'Un icarien quelconque (hors auteur témoignage)' do
    scenario 'ne peut pas voir le témoignage à valider' do
      degel("marion-avec-un-temoignage")
      benoit.rejoint_le_site
      goto("overview/temoignages")
      expect(page).not_to have_css("fieldset#temoignage-a-valider")
      logout
    end
  end


  context 'Un administrateur' do


    scenario 'peut valider un témoignage enregistré' do
      pitch("Un administrateur peut valider un témoignage depuis son bureau.")
      degel("marion-avec-un-temoignage")
      phil.rejoint_son_bureau
      goto('admin/temoignages')
      expect(page).to have_titre("Administration des témoignages")
      # Je dois trouver le témoignage à valider
      expect(page).to have_css('div.temoignage.to_confirm')
      logout
    end


  end


  context 'Un autre icarien' do
    scenario 'peut plébisciter un témoignage' do
      implementer(__FILE__, __LINE__)
    end
  end


end
