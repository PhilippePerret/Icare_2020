# encoding: UTF-8
# frozen_string_literal: true
require_module('mail')
class ConcoursPhase
class Operation

# TODO Un concurrent qui n'a pas envoyé un fichier ou un fichier non
# conforme est considéré comme un non sélectionné (ou alors faut-il simplement
# le zapper ?)

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
      log("étude du juré : #{membre.inspect}")
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
