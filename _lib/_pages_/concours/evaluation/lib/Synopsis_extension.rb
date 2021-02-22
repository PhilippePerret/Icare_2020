# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la class Synopsis pour cette section du concours
=end
class Synopsis
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# *** Méthode marquant le synopsis non conforme et invitant son auteur
#     à le corriger ***
attr_reader :motifs # pour le mail
attr_reader :s_problemes # idem
def set_non_conforme(motifs, motif_detailled)
  admin_required
  require './_lib/data/secret/concours'
  require_module('mail')
  motifs = motifs.nil_if_empty
  motif_detailled = motif_detailled.nil_if_empty
  motifs || motif_detailled || raise("Il faut fournir au moins 1 motif de non conformité !")
  motifs = [motifs] if motifs.is_a?(String)
  motifs = motifs&.collect do |motif|
    data_motif = MOTIF_NON_CONFORMITE[motif.to_sym]
    "#{data_motif[:motif]}#{" (#{data_motif[:precision]})" if data_motif[:precision]}"
  end || [] # quand seulement autre motif
  if not motif_detailled.nil?
    motifs += motif_detailled.split(/\r?\n/)
  end
  # log("motifs: #{motifs.inspect}")

  last_idx = motifs.count - 1
  lis_motifs = []
  motifs.each_with_index do |motif, idx|
    li = "<li>#{motif}#{idx == last_idx ? '.' : ','}</li>"
    lis_motifs << li
  end

  # Pour le mail
  @s_problemes = lis_motifs.count > 1 ? 's' : ''
  @motifs = lis_motifs.join(RC)

  # Marquage du synopsis comme non conforme
  # Note : c'est une petite bizarreté du programme, ici, puisque c'est le
  # concurrent qui doit changer les specs.
  concurrent.set_spec(1,2)

  # Message de confirmation
  message(MESSAGES[:msg_file_non_conforme] % {pseudo:concurrent.pseudo, e:concurrent.fem(:e)})

  # Envoi du mail à l'auteur
  # -------------------------
  # S'il est à la limite de l'échéance (2 jours avant) il ne peut plus
  # renvoyer son dossier
  mail_name = "mail_non_conformite"
  if Concours.proche_echeance?
    mail_name = "#{mail_name}_definitive"
    message("Comme nous sommes proches de l'échéance, il n'a plus la possitilité de renvoyer son dossier.")
  end
  MailSender.send(to:concurrent.mail, from:CONCOURS_MAIL, file:mail_path("phase1/#{mail_name}"), bind: self)


end #/ set_non_conforme
end #/Synopsis
