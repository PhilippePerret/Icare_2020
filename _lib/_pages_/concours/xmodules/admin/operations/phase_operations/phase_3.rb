# encoding: UTF-8
# frozen_string_literal: true
require_module('mail')
class ConcoursPhase
class Operation

# TODO Un concurrent qui n'a pas envoyé un fichier ou un fichier non
# conforme est considéré comme un non sélectionné (ou alors faut-il simplement
# le zapper ?)


# Méthode qui produit le fichier palmares.yaml qui contient les informations
# sur les résultats pour le concours (cf. le manuel pour le détail)
def consigne_resultats_in_file_palmares(options)
  # Structure de la donnée qui sera enregistrée dans palmares-<annee>.yaml
  dpalm = {
    infos:{
      annee: ANNEE_CONCOURS_COURANTE,
      nombre_inscriptions:  nil,
      nombre_concurrents:   nil,
      nombre_sans_dossier:  nil,
      nombre_non_conforme:  nil,
      nombre_femmes:        nil,
      nombre_hommes:        nil,
      concurrents_femmes:   nil,
      concurrents_hommes:   nil
    },
    classement:   [],
    non_conforme: [],
    sans_dossier: []
  }

  request = <<-SQL
SELECT
  *, c.sexe AS sexe
  FROM #{DBTBL_CONCURS_PER_CONCOURS} cpc
  INNER JOIN #{DBTBL_CONCURRENTS} c ON c.concurrent_id = cpc.concurrent_id
  WHERE annee = ?
  SQL
  inscriptions  = db_exec(request, [ANNEE_CONCOURS_COURANTE])
  concurrents   = inscriptions.select { |dc| dc[:specs][0..1] == '11'}
  sans_dossier  = inscriptions.select { |dc| dc[:specs][0]    == '0' }
  non_conforme  = inscriptions.select { |dc| dc[:specs][0..1] == '12'}

  dpalm[:infos][:nombre_inscriptions] = inscriptions.count
  dpalm[:infos][:nombre_femmes]       = inscriptions.select{|d|d[:sexe]=='F'}.count
  dpalm[:infos][:nombre_hommes]       = inscriptions.select{|d|d[:sexe]=='H'}.count
  dpalm[:infos][:nombre_concurrents]  = concurrents.count
  dpalm[:infos][:concurrents_femmes]  = concurrents.select{|d|d[:sexe]=='F'}.count
  dpalm[:infos][:concurrents_hommes]  = concurrents.select{|d|d[:sexe]=='H'}.count
  dpalm[:infos][:nombre_non_conforme] = non_conforme.count
  dpalm[:infos][:nombre_sans_dossier] = sans_dossier.count

  # Pour pouvoir procéder au calcul des notes et du classement
  require './_lib/_pages_/concours/xmodules/calculs/Dossier'
  dpalm[:classement] = Dossier.classement.collect do |dossier|
    {concurrent_id: dossier.concurrent_id, note: dossier.note_totale}
  end

  dpalm[:non_conforme] = non_conforme.collect { |dc| dc[:concurrent_id] }
  dpalm[:sans_dossier] = sans_dossier.collect { |dc| dc[:concurrent_id] }

  palmares_file_path = Dossier.palmares_file_path(ANNEE_CONCOURS_COURANTE)

  if options[:noop]
    html.res << "Je dois créer le fichier #{palmares_file_path} avec la donnée palmarès suivante : #{dpalm.inspect}"
  else
    File.delete(palmares_file_path) if File.exists?(palmares_file_path)
    File.open(palmares_file_path,'wb'){|f| f.write(YAML.dump(dpalm))}
  end

end #/ consigne_resultats_in_file_palmares

# Méthode qui construit le tableau présentant les présélectionnés dans la
# section Palmarès du site
#
def build_tableau_preselections_palmares(options)
  if options[:noop]
    html.res << "Je dois créer le tableau des présélections pour la section Palmarès"
  else
    require_xmodule('palmares')
    Concours.current.build_tableau_palmares(3)
  end
end #/ build_tableau_preselections_palmares

# Méthode qui construit le tableau présentant les lauréats dans la
# section Palmarès du site
#
def build_tableau_laureats_palmares(options)
  if options[:noop]
    html.res << "Je dois créer le tableau des lauréats pour la section Palmarès"
  else
    require_xmodule('palmares')
    Concours.current.build_tableau_palmares(5)
  end
end #/ build_tableau_preselections_palmares

  # Envoie les mails aux concurrents après la première sélection
  # Note : il y a trois mails différents
  #   1) Celui aux concurrents présélectionnés
  #   2) Celui aux concurrents non présélectionnés (mais avec fichier)
  #   3) Celui aux concurrents sans fichier ou non conforme
  def send_mail_concurrents_preselection(options)
    selecteds     = []
    not_selecteds = []
    sans_fichier  = []
    lien_espace_personnel = ESPACE_LINK.with(text:"votre espace personnel", full:true, target: :blank)
    ajout_avec_fiche_lecture = "D'ici là, vous pouvez récupérer votre fiche de lecture personnelle sur #{lien_espace_personnel}, qui vous aidera sans doute à mieux comprendre les raisons de nos choix."
    ajout_sans_fiche_lecture = "Vous avez fait le choix de ne pas recevoir de fiche de lecture, vous n'en trouverez donc pas sur #{lien_espace_personnel}."
    Concurrent.all_current.each do |conc|
      min_data = conc.min_data.merge(titre: conc.projet_titre)
      # log("\nCONC ÉTUDIÉ : #{conc.inspect}")
      if not(conc.cfile.conforme?)
        # log("  FICHIER NON CONFORME")
        sans_fichier << min_data
      elsif conc.preselected?
        # log("  PRÉSÉLECTIONNÉ")
        selecteds << min_data
      else
        # log("  NON PRÉSÉLECTIONNÉ")
        ajout_fiche = conc.fiche_lecture? ? ajout_avec_fiche_lecture : ajout_sans_fiche_lecture
        not_selecteds << min_data.merge(ajout_fiche_lecture: ajout_fiche)
      end
    end
    if not selecteds.empty?
      MailSender.send_mailing({from:CONCOURS_MAIL, to:selecteds, file:mail_path('phase3/mail_preselected'), bind:self}, options)
    end
    if not not_selecteds.empty?
      MailSender.send_mailing({from:CONCOURS_MAIL, to:not_selecteds, file:mail_path('phase3/mail_non_preselected'), bind:self}, options)
    end
    if not sans_fichier.empty?
      MailSender.send_mailing({from:CONCOURS_MAIL, to:sans_fichier, file:mail_path('phase3/mail_sans_fichier'), bind:self}, options)
    end

  end #/ send_mail_concurrents_preselection

  # DO    Envoie les mails aux membres du jury
  # Note : il y a deux types de juré (premier ou second jury), il faut faire la
  # distinction.
  def send_mail_jury_preselection(options)
    log("-> send_mail_jury_preselection")
    jurys = {
      1 => [],
      2 => [],
      3 => []
    }
    log("Concours.current.jury: #{Concours.current.jury.inspect}")
    Concours.current.jury.each do |membre|
      # log("étude du juré : #{membre.inspect}")
      if membre[:jury].nil?
        raise "Le membre #{membre.inspect} ne définit pas son jury (1, 2 ou 3 — 1 + 2)"
      end
      jurys[membre[:jury]] << membre
    end
    jurys.each do |idjury, membres|
      next if membres.empty?
      MailSender.send_mailing({from:CONCOURS_MAIL, to: membres, file: mail_path("phase3/mail_jury_#{idjury}"), bind: self}, options)
    end
  end #/ send_mail_jury_preselection

  def add_actualite_concours_fin_preselection(options)
    Actualite.create(type:'CONCPRESEL', message:"Fin de la présélection de la session #{ANNEE_CONCOURS_COURANTE} du Concours de Synopsis.")
  end


end #/Operation
end #/ConcoursPhase
