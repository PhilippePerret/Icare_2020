# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test des différents types d'inscription en sachant que pour le concours
  ils sont particulièrement nombreux :

  1) un visiteur quelconque, inconnu de l'atelier et du concours
      => Il procède à son inscription normale
  2) un icarien NON identifié qui participe au concours courant
     => Lorsqu'il veut s'inscrire, on lui signale qu'il est déjà
        inscrit et qu'il participe déjà au concours courant
  3) un icarien NON identifié qui n'a participé à aucun concours
     => Lorsqu'il s'inscrit, on l'inscrit simplement
  4) un icarien NON identifié qui a participé à des concours précédents
     => Lorsqu'il s'inscrit, on lui signale et on l'inscrit au concours
        courant.
  5) un icarien identifié qui participe au concours courant
     => Ne doit pas trouver de formulaire pour s'inscrire ni de bouton
        pour participer.
  6) un icarien identifié concurrent, mais par pour la session courante
     => Ne doit pas trouver de formulaire pour s'inscrire mais doit
        trouver un bouton pour s'inscrire au concours courant.
  7) un concurrent non identifié concurrent session courante
     => On lui signale qu'il est déjà inscrit et participe déjà au
        concours courant.
  8) un concurrent non identifié qui ne participe pas au concours courant
     => On lui signale qu'il est déjà inscrit et on lui donne un bouton
        un bouton lui permet de s'inscrire au concours courant.

  ICARIEN
    qui n'a jamais participé à un seul concours
    qui a participé à un concours précédent, mais pas le courant
    qui participe au concours précédent

  CONCURRENT
    déjà inscrit à un concours précédent (mais pas le courant)
    déjà inscrit au concours courant
=end
require_relative './_required'

def inscrire_marion_au_concours
  within("form#concours-signup-form") do
    fill_in("p_patronyme", with: marion.pseudo)
    fill_in("p_mail", with: marion.mail)
    fill_in("p_mail_confirmation", with: marion.mail)
    select('féminin', from:"p_sexe")
    check("p_reglement")
    click_on("S’inscrire")
  end
  screenshot("marion-signup-concours")
end #/ inscrire_marion_au_concours

def inscrire_au_concours_with_data(datac)
  patronyme = datac[:pseudo]||datac[:patronyme]
  within("form#concours-signup-form") do
    fill_in("p_patronyme", with: patronyme)
    fill_in("p_mail", with: datac[:mail])
    fill_in("p_mail_confirmation", with: datac[:mail])
    select(datac[:genre] || 'masculin', from:"p_sexe")
    check("p_reglement")
    click_on("S’inscrire")
  end
  screenshot("#{patronyme}-signup-concours")
end #/ inscrire_au_concours_with_data


feature "Inscription au concours courant suivant le type de visiteur" do
  before(:all) do
    # headless
    degel("concours-phase-1")
    require './_lib/_pages_/concours/inscription/constants' # propres à l'inscription
  end

  context '1) un visiteur quelconque ni icarien ni concurrent' do
    scenario 'peut s’inscrire de façon normale' do
      # headless(false)
      pitch("Un visiteur quelconque, ni icarien ni ancien concurrent du concours, peut s'inscrire en passant par le formulaire.")
      # On s'assure que ce concurrent n'existe pas encore
      concurrent = Candidat.new("Jules Romain", "jules.romain@chez.lui", "H")
      concurrent.destroy if concurrent.exists?
      goto("concours")
      expect(page).to have_link("Inscription au concours")
      expect(page).to have_link("vous inscrire")
      click_on("Inscription au concours")
      inscrire_au_concours_with_data({
        pseudo:concurrent.patronyme,
        mail:concurrent.mail,
        genre:concurrent.genre,
        reglement:true,
      })
      screenshot("visiteur-lambda-signup-concours")
      expect(page).to have_no_erreur
      expect(page).to have_titre "Espace personnel"
      expect(page).to have_link "Se déconnecter"
      click_on("Se déconnecter")
      expect(concurrent).to be_exists
      expect(concurrent).not_to be_femme
    end
  end  # // context 1)


  context '2) Icarien non identifié participant au concours courant' do
    before(:all) do
      # Il faut créer une inscription pour Marion
      # Note : ça crée un enregistrement pour un concours précédent.
      TConcurrent.inscrire_icarien(marion, session_courante: true)
      require './_lib/_pages_/user/login/constants'
    end
    scenario 'se voit averti qu’il participe déjà au concours courant' do
      marionc = Candidat.new(marion.pseudo,marion.mail,marion.sexe)
      goto("concours")
      click_on("Inscription au concours")
      inscrire_marion_au_concours
      expect(page).not_to have_titre "Espace personnel"
      expect(page).to have_titre "Identification"
      expect(page).to have_message(MESSAGES[:concours_icarien_inscrit_login_required] % {pseudo:marion.pseudo, e:"e"})
      within("form#user-login") do
        fill_in("user_mail", with: marion.mail)
        fill_in("user_password", with: marion.password)
        click_on(UI_TEXTS[:btn_login])
      end
      sleep 10
      expect(page).to be_espace_personnel
      expect(page).to have_link("Se déconnecter") # pas pour les icariens
    end
  end #/context 2)

  context '3) Icarien non identifié qui n’a participé à aucun concours' do
    scenario 'se voit demander de s’identifer' do
      marionc = Candidat.new("Marion Concurrente", marion.mail, 'F')
      marionc.destroy if marionc.exists?
      pitch("En s'inscrivant au concours, un icarien non identifié doit trouver un message l'informant qu'il doit s'identifier et rejoindre le formulaire d'inscription du concours.")
      goto("concours")
      click_on("Inscription au concours")
      inscrire_marion_au_concours
      expect(page).not_to be_espace_personnel
      expect(page).to have_titre "Identification"
      expect(page).to have_message("Vous êtes icarienne, identifiez-vous")
    end
  end # / context 3)

  context '4) Un icarien non identifié qui a participé à des concours précédents' do
    before(:all) do
      # Il faut créer une inscription pour Marion
      # Note : ça crée un enregistrement pour un concours précédent.
      TConcurrent.inscrire_icarien(marion, session_courante: false)
    end
    scenario 'se voit renvoyé vers l’identification avec un message d’information' do
      marionc = Candidat.new(marion.pseudo,marion.mail,marion.sexe)
      goto("concours")
      click_on("Inscription au concours")
      inscrire_marion_au_concours
      expect(page).not_to have_titre "Espace personnel"
      expect(page).to have_titre "Identification"
      expect(page).to have_message(MESSAGES[:concours_icarien_inscrit_login_required] % {pseudo:marion.pseudo, e:"e"})
    end
  end # /context 4)


  context '5) Un icarien identifié qui participe au concours courant' do
    before(:all) do
      marionc = Candidat.new(marion.pseudo,marion.mail,'F')
      marionc.destroy if marionc.exists?
      TConcurrent.inscrire_icarien(marion, session_courante: true)
    end
    scenario 'ne trouve pas de formulaire pour s’inscrire' do
      marion.rejoint_son_bureau
      goto("concours")
      expect(page).to have_content("Puisque vous êtes inscrite, vous pouvez")
      expect(page).not_to have_link("vous inscrire")
      expect(page).not_to have_link(href: "concours/inscription")
      expect(page).to have_link("votre espace personnel")
      # On essaie d'atteindre le formulaire "de force"
      goto("concours/inscription")
      expect(page).not_to have_css("form#concours-signup-form")
    end
  end # / context 5)

  context '6) Un icarien identifié concurrent, mais pas de la session courante'do
    before(:all) do
      marionc = Candidat.new(marion.pseudo,marion.mail,'F')
      marionc.destroy if marionc.exists?
      TConcurrent.inscrire_icarien(marion, session_courante: false)
    end
    scenario 'trouve un bouton qui lui permet de s’inscrire à la session courante' do
      start_time = Time.now.to_i - 1
      marion.rejoint_son_bureau
      goto("concours")
      screenshot("home-concours-icarien-concurrent-not-current-session")
      expect(page).not_to have_link("votre espace personnel")
      expect(page).to have_link("vous inscrire à la session courante")
      expect(page).to have_link(href: "concours/inscription")
      marion.click_on("vous inscrire à la session courante")
      screenshot("marion-want-signup-cur-session-concours")
      expect(page).not_to have_css("form#concours-signup-form")
      # À la place il y a un bouton pour s'inscrire à cette session du
      # concours
      btn_name = UI_TEXTS[:concours_signup_session_concours] % {annee:ANNEE_CONCOURS_COURANTE}
      expect(page).to have_link(btn_name)
      marion.click_on(btn_name)
      screenshot("marion-signup-cur-session-concours")
      expect(page).to be_espace_personnel
      expect(page).to have_message(MESSAGES[:concours_confirm_inscription_session_courante] % {e:"e"})
      marionc = Candidat.new(marion.pseudo, marion.mail,'F')
      expect(marionc).to be_concurrent_session_courante
      expect(TActualites).to have_actualite(after: start_time, user_id:marion.id, type:"CONCOURS", message:"<strong>#{marion.pseudo}</strong> s'inscrit au concours de synopsis.")
    end
  end #/ context 6)


  context '7) Un concurrent non identifié concurrent session courante' do
    before(:all) do
      cand = Candidat.new("Alain Esquerre", "alain.esquerre@gmail.com", "H")
      if not(cand.exists?)
        cand.signup(session_courante: true)
      elsif not(cand.cand_session_courante?)
        cand.signup_session_courante
      end
      @candidat = cand
    end
    let(:candidat) { @candidat }
    scenario 'se voit redirigé vers l’identification avec un message d’information' do
      goto("concours")
      click_on("Inscription au concours")
      inscrire_au_concours_with_data({
        pseudo:candidat.patronyme,
        mail:candidat.mail,
        genre:candidat.genre,
      })
      expect(page).to have_no_erreur
      expect(page).not_to have_titre "Espace personnel"
      expect(page).to have_titre "Identification"
      expect(page).to have_message(MESSAGES[:concurrent_login_required])
      within("form#concours-login-form") do
        fill_in("p_mail", with: candidat.mail)
        fill_in("p_concurrent_id", with: candidat.id)
        click_on(UI_TEXTS[:concours_bouton_sidentifier])
      end
      expect(page).to have_titre "Espace personnel"
      expect(page).to have_link("Se déconnecter")
    end
  end #/ context 7)

end
