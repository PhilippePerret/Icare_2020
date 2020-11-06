# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module pour checker la possibilité d'ajouter des jours gratuits à un icarien
=end
require_relative './_required'

# include Capybara::DSL

feature 'Opération Ajout de jours gratuits' do
  before(:all) do
    require "#{FOLD_REL_PAGES}/admin/tools/constants"
    degel('elie_demarre_son_module')
  end

  context 'avec un icarien dans un module à durée déterminée' do
    scenario 'il ne peut pas recevoir de jours grauits' do
      phil.rejoint_son_bureau
      phil.click_on('OUTILS')
      expect(page).to have_titre('Outils')
      phil.click('cb-statut-actif', within: '#div-statuts')
      select('Marionm', from: 'icariens')
      select('Jours gratuits', from: 'operations')
      expect(page).to have_css('textarea#long_value')
      expect(page).to have_css('input[type="text"]#short_value')
      page.within('div#div-fields') do
        fill_in('long_value', with: 'Ceci est le texte de l’actualité')
        fill_in('short_value', with: '20')
        click_on(UI_TEXTS[:btn_execute_operation])
      end
      expect(page).to have_erreur("Impossible d’offrir des jours gratuits à MarionM")
      expect(page).to have_erreur("n’est pas un module de suivi de projet")
    end
  end



  context 'avec un icarien dans un module de suivi' do
    scenario 'il peut recevoir des jours gratuits de façon discrète' do

      # On prend le watcher de paiement d'Élie
      watcher_paiement = db_get('watchers', {user_id:elie.id, wtype:'paiement_module'})
      # puts "watcher_paiement: #{watcher_paiement.inspect}"
      old_trigger = watcher_paiement[:triggered_at].to_i

      phil.rejoint_son_bureau
      start_time = Time.now.to_i
      phil.click_on('OUTILS')
      expect(page).to have_titre('Outils')
      phil.click('cb-statut-actif', within: '#div-statuts')
      select('Élie', from: 'icariens')
      select('Jours gratuits', from: 'operations')
      expect(page).to have_css('textarea#long_value')
      expect(page).to have_css('input[type="text"]#short_value')
      page.within('div#div-fields') do
        fill_in('long_value', with: '')
        fill_in('short_value', with: '20')
        uncheck("cb_value")
        click_on(UI_TEXTS[:btn_execute_operation])
      end
      next_paiement_time = old_trigger + 20.days
      next_paiement_formated = formate_date(next_paiement_time)
      expect(page).to have_message("20 jours gratuits ont été attribués à Élie.")
      expect(page).to have_message("Sa prochaine date de paiement est le #{next_paiement_formated}")
      expect(page).not_to have_message("Un mail d’annonce lui a été envoyé")
      expect(page).to have_message("Aucun mail d’annonce ne lui a été envoyé")
      # Le watcher doit avoir été modifié
      new_watcher = db_get('watchers', watcher_paiement[:id])
      expect(new_watcher[:triggered_at]).to eq(next_paiement_time.to_s)
      # Le mail a été envoyé à Élie
      expect(elie).not_to have_mail(after: start_time, subject:"Ajout de jours gratuits")
    end



    scenario 'il peut recevoir des jours gratuits et être averti' do

      # On prend le watcher de paiement d'Élie
      watcher_paiement = db_get('watchers', {user_id:elie.id, wtype:'paiement_module'})
      old_trigger = watcher_paiement[:triggered_at].to_i

      phil.rejoint_son_bureau
      start_time = Time.now.to_i
      phil.click_on('OUTILS')
      expect(page).to have_titre('Outils')
      phil.click('cb-statut-actif', within: '#div-statuts')
      select('Élie', from: 'icariens')
      select('Jours gratuits', from: 'operations')
      expect(page).to have_css('textarea#long_value')
      expect(page).to have_css('input[type="text"]#short_value')
      page.within('div#div-fields') do
        fill_in('long_value', with: '')
        fill_in('short_value', with: '20')
        check("cb_value")
        click_on(UI_TEXTS[:btn_execute_operation])
      end
      next_paiement_time = old_trigger + 20.days
      next_paiement_formated = formate_date(next_paiement_time)
      expect(page).to have_message("20 jours gratuits ont été attribués à Élie.")
      expect(page).to have_message("Sa prochaine date de paiement est le #{next_paiement_formated}")
      expect(page).to have_message("Un mail d’annonce lui a été envoyé")
      # Le watcher doit avoir été modifié
      new_watcher = db_get('watchers', watcher_paiement[:id])
      expect(new_watcher[:triggered_at]).to eq(next_paiement_time.to_s)
      # Le mail a été envoyé à Élie
      expect(elie).to have_mail(after: start_time, subject:"Ajout de jours gratuits", message:"aux alentours du #{next_paiement_formated}")
    end




    scenario 'il peut recevoir des jours gratuits et être averti avec un message personnalisé' do

      # On prend le watcher de paiement d'Élie
      watcher_paiement = db_get('watchers', {user_id:elie.id, wtype:'paiement_module'})
      old_trigger = watcher_paiement[:triggered_at].to_i

      phil.rejoint_son_bureau
      start_time = Time.now.to_i
      phil.click_on('OUTILS')
      expect(page).to have_titre('Outils')
      phil.click('cb-statut-actif', within: '#div-statuts')
      select('Élie', from: 'icariens')
      select('Jours gratuits', from: 'operations')
      expect(page).to have_css('textarea#long_value')
      expect(page).to have_css('input[type="text"]#short_value')
      page.within('div#div-fields') do
        fill_in('long_value', with: '<p><%= owner.pseudo %>, c’est un cadeau pour toi</p>')
        fill_in('short_value', with: '20')
        check("cb_value")
        click_on(UI_TEXTS[:btn_execute_operation])
      end
      next_paiement_time = old_trigger + 20.days
      next_paiement_formated = formate_date(next_paiement_time)
      expect(page).to have_message("20 jours gratuits ont été attribués à Élie.")
      expect(page).to have_message("Sa prochaine date de paiement est le #{next_paiement_formated}")
      expect(page).to have_message("Un mail d’annonce lui a été envoyé")
      # Le watcher doit avoir été modifié
      new_watcher = db_get('watchers', watcher_paiement[:id])
      expect(new_watcher[:triggered_at]).to eq(next_paiement_time.to_s)
      # Le mail a été envoyé à Élie
      expect(elie).to have_mail(after: start_time, subject:"Ajout de jours gratuits",
        message:["aux alentours du #{next_paiement_formated}",
          "<p>Élie, c’est un cadeau pour toi"]),
        "Élie aurait dû recevoir un mail conforme aux attentes (avec message personnel)."
    end

  end #/ context icarien en suivi



  context 'un simple visiteur'do
    scenario 'ne peut pas s’ajouter des jours gratuits' do
      # On prend le watcher de paiement d'Élie
      watcher_paiement = db_get('watchers', {user_id:elie.id, wtype:'paiement_module'})
      old_trigger = watcher_paiement[:triggered_at].to_i
      # IL ne peut pas rejoindre la section des outils
      # + Il ne peut pas forcer une URL
      querystring = {"uid":"[\"1\",\"integer\"]","icarien":"[\"#{elie.id}\",\"string\"]","operation":"[\"free_days\",\"string\"]","long_value":"[\"C'est à voir ?\",\"string\"]","short_value":"[\"30\",\"string\"]","script":"[\"operation_icarien.rb\",\"string\"]"}
      querystring = querystring.collect{|k,vs| "#{k}=#{uri_encode(vs)}"}.join('&')
      goto('_lib/ajax/ajax.rb?'+querystring)
      # Le watcher n'a pas changé
      new_watcher = db_get('watchers', watcher_paiement[:id])
      expect(new_watcher[:triggered_at]).to eq(old_trigger.to_s)

    end
  end

  context 'un simple icarien' do
    scenario 'ne peut pas s’ajouter des jours gratuits' do
      elie.rejoint_son_bureau
      # On prend le watcher de paiement d'Élie
      watcher_paiement = db_get('watchers', {user_id:elie.id, wtype:'paiement_module'})
      old_trigger = watcher_paiement[:triggered_at].to_i
      # IL ne peut pas rejoindre la section des outils
      # + Il ne peut pas forcer une URL
      querystring = {"uid":"[\"1\",\"integer\"]","icarien":"[\"#{elie.id}\",\"string\"]","operation":"[\"free_days\",\"string\"]","long_value":"[\"C'est à voir ?\",\"string\"]","short_value":"[\"30\",\"string\"]","script":"[\"operation_icarien.rb\",\"string\"]"}
      querystring = querystring.collect{|k,vs| "#{k}=#{uri_encode(vs)}"}.join('&')
      goto('_lib/ajax/ajax.rb?'+querystring)
      # Le watcher n'a pas changé
      new_watcher = db_get('watchers', watcher_paiement[:id])
      expect(new_watcher[:triggered_at]).to eq(old_trigger.to_s)
    end
  end


end
