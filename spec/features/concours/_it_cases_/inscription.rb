# encoding: UTF-8
# frozen_string_literal: true
=begin
  Tests concernant l'inscription
=end
HUMAN_VISITOR_STATE = {
  simple:   'simple visiteur',
  ancien:   'ancien concurrent',
  icarien:  'icarien jamais inscrit',
  icarieni: 'icarien déjà inscrit'
}
# Test de l'inscription d'un visiteur qui peut être ancien concurrent, icarien,
# simple visiteur, etc. Pour chacun de ces statuts un test différent est prévu
# puisque la procédure est différente.
#
# +as+
#   :simple     Simple visiteur (jamais inscrit, non icarien)
#   :ancien     Ancien concurrent non inscrit
#   :icarien    Icarien en activité (ou pas…)
#
# Rappel : le visiteur, si ça n'est pas un simple visiteur, est toujours
# identifié quand il arrive ici.
#
def peut_sinscrire_au_concours(as)
  scenario "trouve des liens pour rejoindre l'inscription" do
    phase = TConcours.current.phase || 0
    puts "phase courante du concours : #{phase}"
    goto("plan")
    click_on("CONCOURS")
    btn_name = phase < 2 ? "vous inscrire" : "Inscription au prochain concours"
    click_on(btn_name)
    expect(page).to be_inscription_concours(form = nil)
  end

  scenario "peut s'inscrire au concours en tant que #{HUMAN_VISITOR_STATE[as]}" do
    require './_lib/_pages_/concours/xmodules/inscription/constants'
    start_time = Time.now.to_i
    goto("concours/inscription")
    screenshot("inscription-#{as.inspect}")
    case as
    when :simple
      expect(page).to be_inscription_concours(with_formulaire = true)
      concurrent_pseudo = concurrent_patro = "Concurrent #{Time.now.to_i}"
      concurrent_mail   = "#{concurrent_pseudo.downcase.gsub(/ /,'')}@philippeperret.fr"
      concurrent_e      = "e"
      concurrent_sexe   = 'F'
      within("form#concours-signup-form") do
        fill_in("p_patronyme", with: concurrent_pseudo)
        fill_in("p_mail", with: concurrent_mail)
        fill_in("p_mail_confirmation", with: concurrent_mail)
        select("féminin", from: "p_sexe")
        check("p_reglement")
        check("p_fiche_lecture")
        click_on(UI_TEXTS[:concours_bouton_signup])
      end
      screenshot('after-inscription')
      # On récupère l'identifiant du concurrent
      dc = db_exec("SELECT * FROM #{DBTBL_CONCURRENTS} WHERE patronyme = ?", [concurrent_pseudo]).first
      concurrent_id = dc[:concurrent_id]
    when :ancien, :icarien
      expect(page).to be_inscription_concours(with_formulaire = false)
      btn_name = UI_TEXTS[:concours_signup_session_concours] % {annee: ANNEE_CONCOURS_COURANTE}
      expect(page).to have_link(btn_name)
      click_on(btn_name)
    when :icarieni
      expect(page).to be_inscription_concours(with_formulaire = false)
    else # when par défaut
      raise("Le cas #{as.inspect} n'est pas encore traité")
    end

    screenshot('after-click-signup')

    vtested = visitor.is_a?(TUser) ? visitor.as_concurrent : visitor
    concurrent_pseudo ||= vtested.pseudo.freeze
    concurrent_patro  ||= vtested.patronyme.freeze
    concurrent_mail   ||= vtested.mail.freeze
    concurrent_id     ||= begin
      dc = db_exec("SELECT * FROM #{DBTBL_CONCURRENTS} WHERE patronyme = ?", [concurrent_patro]).first
      dc[:concurrent_id]
    end
    concurrent_e      ||= vtested.fem(:e)
    concurrent_sexe   ||= vtested.femme? ? 'F' : 'H'

    expect(page).to be_espace_personnel

    # Un message annonce la réussite de l'opération
    # pseudo_message = visitor.is_a?(TUser) ? visitor.pseudo
    expect(page).to have_message(MESSAGES[:concours_confirm_inscription_session_courante] % {e:concurrent_e, pseudo:visitor&.pseudo||concurrent_pseudo})

    # Les données sont justes, dans la table des concurrents
    dc = db_exec("SELECT * FROM #{DBTBL_CONCURRENTS} WHERE patronyme = ?", [concurrent_patro]).first
    if dc.nil?
      puts "Concurrent introuvable avec le patronyme #{concurrent_patro.inspect} parmi : ".rouge
      puts db_exec("SELECT * FROM #{DBTBL_CONCURRENTS}").pretty_inspect
    end
    expect(dc).not_to eq(nil), "Les informations du concurrent auraient dû être enregistrées dans la base"
    expect(dc[:mail]).to eq(concurrent_mail)
    expect(dc[:sexe]).to eq(concurrent_sexe)
    expect(dc[:options][0]).to eq("1")
    expect(dc[:options][1]).to eq("1") # fiche de lecture

    # Les données sont justes, dans la table des concours
    dcc = db_exec("SELECT * FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE concurrent_id = ? and annee = ?", [concurrent_id, ANNEE_CONCOURS_COURANTE]).first
    expect(dcc).not_to eq(nil), "La donnée pour le concours courant aurait dû être enregistrée dans la base de données"

    # L'inscription a été annoncée par une actualité
    expect(TActualites).to have_actualite(after: start_time, type:"CONCOURS", message:"<strong>#{concurrent_pseudo}</strong> s'inscrit au concours de synopsis.")

    # Un mail m'avertit de la nouvelle inscription
    # Le message est différent en fonction du fait que c'est un icarien ou non
    msg = case as
    when :icarien then "vient de s'inscrire au concours de synopsis"
    else "nouvelle inscription au concours de synopsis"
    end
    expect(TMails).to have_mail(to:CONCOURS_MAIL, after: start_time, subject: MESSAGES[:concours_new_signup_titre], message:[msg])

    # L'inscrit a reçu un mail de confirmation (différent en fonction de
    # son statut à son arrivée)
    msg_content = case as
    when :icarien
      ["Je vous confirme que votre inscription à la session #{ANNEE_CONCOURS_COURANTE} du Concours de Synopsis"]
    else
      ["vous confirmons par la présente votre inscription au Concours de Synopsis","Numéro de concurrent",concurrent_id.to_s]
    end
    expect(vtested).to have_mail(after:start_time, subject:MESSAGES[:concours_signed_confirmation], message:msg_content)
  end
end

# Dans ce test, le visiteur (@visitor) essaie par tous les moyens possibles
# de s'inscrire (alors qu'il l'est déjà)
def ne_peut_pas_sinscrire_au_concours(raison_affichee = "déjà inscrit")
  it "ne peut pas s'inscrire au concours (#{raison_affichee})" do
    goto("concours/inscription")
    expect(page).to be_inscription_concours(formulaire = false)
    expect(page).to have_content(raison_affichee)
  end
end #/ne_peut_pas_sinscrire_au_concours

def ne_peut_pas_sinscrire_au_concours_avec_des_donnees_erronnees
  require './_lib/_pages_/concours/xmodules/inscription/constants'
  dc = db_exec("SELECT mail FROM #{DBTBL_CONCURRENTS} LIMIT 1").first
  mauvaise_inscription_avec("un mail existant",  dc)
  dc = db_exec("SELECT mail FROM users WHERE id > 9 LIMIT 1").first
  mauvaise_inscription_avec('un mail d’icarien', dc)
  mauvaise_inscription_avec('un mail trop long', mail: "#{'xy'*256}@chez.lui")
  mauvaise_inscription_avec('un mail invalide', mail: "mauvais@mail")
  mauvaise_inscription_avec('une mauvaise confirmation de mail', mail_confirmation:'mauvaise@confirmation.com')
  mauvaise_inscription_avec('un patronyme trop long', patronyme: "x"*257)
  dc = db_exec("SELECT patronyme FROM #{DBTBL_CONCURRENTS} LIMIT 1").first
  mauvaise_inscription_avec('un patronyme existant', dc)
  mauvaise_inscription_avec('un règlement non approuvé', reglement: false)
end



def peut_detruire_son_inscription
  it "peut détruire son inscription" do
    # Cas particulier où le visiteur est un icarien
    # Je pense qu'il faut transformer le 'visitor' ici par un vrai
    # TConcurrent car sinon les propriétés '.folder', '.id' etc.
    # seront fausses.
    testedvisitor = visitor.is_a?(TUser) ? visitor.as_concurrent : visitor
    puts "testedvisitor = #{testedvisitor.inspect}"
    dossier = testedvisitor.folder

    # *** Vérifications préliminaires ***
    if not File.exists?(dossier)
      mkdir(dossier)
    end
    expect(File).to be_exists(dossier), "Le dossier du concurrent devrait exister avec ses documents."

    goto("concours/espace_concurrent")
    puts "Est-ce que son dossier existe ici ? #{File.exists?(dossier).inspect}"
    expect(page).to have_css("form#destroy-form")
    within("form#destroy-form") do
      fill_in("c_numero", with: testedvisitor.id)
      click_on(UI_TEXTS[:concours_button_destroy])
    end
    screenshot("destroy-inscription")
    puts "Est-ce que son dossier '#{dossier}' existe là (il ne devrait pas) ? #{File.exists?(dossier).inspect}"

    # *** Vérifications ***
    nb = db_count(DBTBL_CONCURS_PER_CONCOURS, {concurrent_id: testedvisitor.id})
    expect(nb).to eq(0), "Il ne devrait plus y avoir de participations du concurrent dans '#{DBTBL_CONCURS_PER_CONCOURS}'…"
    d = db_exec("SELECT * FROM #{DBTBL_CONCURRENTS} WHERE concurrent_id = ?", [testedvisitor.id])
    expect(d).to be_empty
    if File.exists?(dossier)
      puts "Le dossier '#{dossier}' existe (il ne devrait pas)".jaune
    end
    expect(File).not_to be_exists(dossier), "Le dossier du concurrent ne devrait plus exister."

    goto("concours/accueil")
    # Étonnament (ou pas), ci-dessous, le lien s'appelle "Identifiez-vous" même
    # lorsque la phase du concours est à 1.
    # btn_login_name = TConcours.current.phase < 2 ? "vous identifier" : "Identifiez-vous"
    btn_login_name = "Identifiez-vous"
    click_on(btn_login_name)
    expect(page).to have_titre("Identification au concours") # juste pour être sûr
    within("form#concours-login-form") do
      fill_in("p_mail", with: testedvisitor.mail)
      fill_in("p_concurrent_id", with:testedvisitor.id)
      click_on(UI_TEXTS[:concours_bouton_sidentifier])
    end
    expect(page).to have_titre("Identification au concours") # juste pour être sûr
    expect(page).to have_error("Désolé, je ne vous remets pas")
  end

  @visitor = nil # pour forcer sa réinitialisation
end #/ peut_detruire_son_inscription


# ---------------------------------------------------------------------
#
#   Méthodes fonctionnelle
#
# ---------------------------------------------------------------------


def mauvaise_inscription_avec(raison, data)
  it "ne réussit pas à s’inscrire au concours avec #{raison}" do
    proceed_inscription_with(data)
    error_msg = case raison
    when "un mail existant"
      "Vous êtes déjà concurrent du concours"
      ERRORS[:concours][:signup][:errors][:already_concurrent]
    when 'un mail trop long'
      ERRORS[:concours][:signup][:errors][:mail_too_long]
    when 'un mail invalide'
      ERRORS[:concours][:signup][:errors][:invalid_mail]
    when 'un mail d’icarien'
      ERRORS[:concours][:signup][:errors][:is_icarien]
    when 'une mauvaise confirmation de mail'
      ERRORS[:concours][:signup][:errors][:confirmation_mail_doesnt_match]
    when 'un patronyme existant'
      ERRORS[:concours][:signup][:errors][:patronyme_exists]
    when 'un patronyme trop long'
      ERRORS[:concours][:signup][:errors][:patronyme_too_long]
    when 'un règlement non approuvé'
      ERRORS[:concours][:signup][:errors][:approbation_rules_required]
    end
    expect(page).to have_content(error_msg)
  end
end #/ mauvaise_inscription_avec

# Méthode utilitaire pour procéder à l'inscription en utilisant le formulaire.
def proceed_inscription_with(data)
  goto("concours/inscription")
  start_time = Time.now.to_i
  # Un utilisateur s'inscrit
  data[:patronyme] ||= "Concurrent #{start_time + rand(10000)}"
  data[:mail]   ||= "#{data[:patronyme].downcase.gsub(/ /,'')}@philippeperret.fr"
  data[:mail_confirmation ] ||= data[:mail]
  data[:sexe] ||= "féminin"
  within("form#concours-signup-form") do
    fill_in("p_patronyme", with: data[:patronyme])
    fill_in("p_mail", with: data[:mail])
    fill_in("p_mail_confirmation", with: data[:mail_confirmation])
    select(data[:sexe], from: "p_sexe")
    if data[:reglement] === false
      uncheck("p_reglement")
    else
      check("p_reglement")
    end
    if data[:fiche_lecture] === false
      uncheck("p_fiche_lecture")
    else
      check("p_fiche_lecture")
    end
    # sleep 10
    # On soumet le formulaire
    click_on(UI_TEXTS[:concours_bouton_signup])
  end
end #/ proceed_inscription_with
