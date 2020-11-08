# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la class Synopsis pour cette section du concours
=end
class Synopsis
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# *** Méthode marquant le synopsis non conforme et invitant son auteur
#     à le corriger ***
def set_non_conforme(motifs, motif_detailled)
  admin_required
  require_module('mail')
  motifs = motifs.nil_if_empty
  motif_detailled = motif_detailled.nil_if_empty
  motifs || motif_detailled || raise("Il faut fournir au moins 1 motif de non conformité !")
  motifs = [motifs] if motifs.is_a?(String)

  # Marquage du synopsis comme non conforme
  # TODO
  
  # Envoi du mail à l'auteur
  # TODO

  # Message de confirmation
  # TODO
end #/ set_non_conforme
end #/Synopsis
