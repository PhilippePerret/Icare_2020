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
    goto("plan")
    click_on("CONCOURS")
    btn_name = phase < 2 ? "vous inscrire" : "Inscription au prochain concours"
    click_on(btn_name)
    expect(page).to be_inscription_concours(form = nil)
  end

  scenario "peut s'inscrire au concours en tant que #{HUMAN_VISITOR_STATE[as]}" do
    start_time = Time.now.to_i
    require './_lib/_pages_/concours/inscription/constants'
    goto("concours/inscription")
    case as
    when :simple
      expect(page).to be_inscription_concours(with_formulaire = true)
      concurrent_pseudo = "Concurrent #{Time.now.to_i}"
      concurrent_mail   = "#{concurrent_pseudo.downcase.gsub(/ /,'')}@philippeperret.fr"
      within("form#concours-signup-form") do
        fill_in("p_patronyme", with: concurrent_pseudo)
        fill_in("p_mail", with: concurrent_mail)
        fill_in("p_mail_confirmation", with: concurrent_mail)
        select("féminin", from: "p_sexe")
        check("p_reglement")
        check("p_fiche_lecture")
        click_on(UI_TEXTS[:concours_bouton_signup])
        concurrent_e = "e"
        concurrent_sexe = 'F'
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

    concurrent_pseudo ||= visitor.pseudo.freeze
    concurrent_patro  ||= (visitor.patronyme || visitor.pseudo).freeze
    concurrent_mail   ||= visitor.mail.freeze
    concurrent_id     ||= begin
      dc = db_exec("SELECT * FROM #{DBTBL_CONCURRENTS} WHERE patronyme = ?", [concurrent_patro]).first
      dc[:concurrent_id]
    end
    concurrent_e      ||= visitor.fem(:e)
    concurrent_sexe   ||= visitor.femme? ? 'F' : 'H'

    expect(page).to be_espace_personnel

    # Un message annonce la réussite de l'opération
    expect(page).to have_message(MESSAGES[:concours_confirm_inscription_session_courante] % {e:concurrent_e, pseudo:concurrent_pseudo})

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

    # L'inscrit a reçu un mail de confirmation (différent en fonction de
    # son statut à son arrivée)
    msg_content = case as
    when :icarien
      ["Je vous confirme que votre inscription à la session #{ANNEE_CONCOURS_COURANTE} du Concours de Synopsis"]
    else
      ["vous confirmons par la présente votre inscription au Concours de Synopsis","Numéro de concurrent",concurrent_id.to_s]
    end
    expect(visitor).to have_mail(after:start_time, subject:MESSAGES[:concours_signed_confirmation], message:msg_content)
  end
end

# Dans ce test, le visiteur (@visitor) essaie par tous les moyens possibles
# de s'inscrire (alors qu'il l'est déjà)
def ne_peut_pas_sinscrire_au_concours(raison_affichee = "déjà concurrent")
  it "ne peut pas s'inscrire au concours (#{raison_affichee})" do
    require './_lib/_pages_/concours/inscription/constants'
    goto("concours/inscription")
    expect(page).to be_inscription_concours(formulaire = false)
    expect(page).to have_content(raison_affichee)
  end
end #/ne_peut_pas_sinscrire_au_concours
