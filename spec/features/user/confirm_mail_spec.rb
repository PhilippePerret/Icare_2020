# encoding: UTF-8
# frozen_string_literal: true
=begin
  Check de la validation d'un mail

  - un inscrit doit valider son adresse mail (ticket + watcher)
    Ça lui est rappelé à chaque connexion.
  - un inscrit peut valider son mail par le mail qui lui a été envoyé
  - un inscrit peut renvoyer un mail pour valider son mail
=end

feature 'Validation du mail' do
  before(:each) do
    degel('inscription_marion')
    require './_lib/required/_classes/_User/constants'
    require './_lib/_watchers_processus_/User/valid_mail/constants'
  end

  context 'Un candidat' do

    it 'doit valider son mail' do
      pitch("Quand Marion, qui vient de s'inscrire, rejoint le site, on lui demande de valider son mail.")
      marion.rejoint_le_site
      # Elle trouve un message quand elle se connect
      msg = MESSAGES[:confirmation_mail_required] % marion.pseudo
      expect(page).to have_erreur(msg)
      # Elle possède un watcher lui indiquant la demande
      expect(marion).to have_watcher(wtype:'validation_adresse_mail', user_id:marion.id, vu_user:false)
      # Elle a reçu un mail lui demandant de valider son adresse
      expect(marion).to have_mail(subject:'Validation du mail')
    end











    it 'peut valider son mail à l’aide du lien dans son mail de validation' do

      pitch("Marion peut valider son mail à l'aide du lien qui lui a été envoyé par mail.")

      # *** Vérifications préliminaires ***
      # D'abord, on vérifie qu'elle doivent bien valider son mail
      # Dans ses options
      expect(marion.options[2]).to eq('0')
      # Elle a bien un message de demande quand elle se connecte
      marion.rejoint_le_site
      msg = MESSAGES[:confirmation_mail_required] % marion.pseudo
      expect(page).to have_erreur(msg)
      logout
      # Elle possède un watcher lui indiquant la demande
      expect(marion).to have_watcher(wtype:'validation_adresse_mail', vu_user:false)
      # Elle a reçu un mail lui demandant de valider son adresse
      expect(marion).to have_mail(subject:'Validation du mail')


      # Récupérer le mail de confirmation
      mails = TMails.for(marion.mail, {subject: "Validation du mail"})
      mail = mails.first
      ticket_id = mail.content.match(/\?tik=([0-9]+)"/).to_a[1]
      expect(ticket_id).not_to eq(nil),
        "L'identifiant du ticket devrait être défini, dans le mail de validation."
      # Appeler le ticket
      goto("bureau/home?tik=#{ticket_id}")
      # goto("plan?tik=#{ticket_id}") # n'importe quelle route doit reconduire au formulaire d'identification
      expect(page).to have_titre('Identification'),
        "Marion devrait être retournée vers le formulaire d’identification."
      marion.fill_and_submit_login_form
      # Un message confirme la validation du mail
      expect(page).to have_message("Votre mail a été confirmé"),
        "Un message devrait confirmer la validation du mail"
      msg = MESSAGES[:confirmation_mail_required] % marion.pseudo
      expect(page).not_to have_erreur(msg),
        "La page ne devrait plus afficher le message d'erreur de mail non validé."
      # Vérifier que le mail a bien été marqué vérifié dans les options
      marion.reset
      expect(marion.options[2]).to eq('1'),
        "Les options de MarionM devraient indiquer que son mail a été confirmé"
      # Vérifier que le watcher ait été détruit
      expect(marion).not_to have_watcher(wtype:'validation_adresse_mail'),
        "Marion ne devrait plus avoir le watcher de validation de mail"
      # Vérifier que le ticket ait été détruit
      expect(db_count('tickets', {id:ticket_id})).to eq(0)
    end


















    it 'peut se renvoyer le mail de validation du mail' do

      pitch("Quand Marion rejoint le site et qu'on lui demande de valider son mail, un lien lui permet de se renvoyer le mail de confirmation du mail. Marion le clique et reçoit le nouveau mail.")


      marion.rejoint_le_site
      expect(page).to have_css('a.goto', text:"Notifications")
      start_time = Time.now.to_i
      find('a.goto', text:"Notifications").click
      expect(page).to have_link("Renvoyer le mail")
      marion.click_link("Renvoyer le mail")
      expect(page).to have_titre('Notifications')
      # *** Vérifications ***
      expect(page).to have_message(MESSAGES[:mail_confirmation_mail_resent] % marion.pseudo)
      expect(marion).to have_mail(subject: 'Validation du mail', after: start_time)
    end

  end
end
