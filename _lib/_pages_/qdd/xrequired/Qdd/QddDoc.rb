# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class QddDoc
  ------------
  Pour gérer un document comme un document QDD
=end
class QddDoc

LINK_DOWNLOAD_PDF = '<a href="%s" target="_blank" class="fleft"><img src="img/icones/pdf%s.jpg" class="vmiddle mr1" /></a>'
DOWNLOAD_ROUTE = 'qdd/download?qid=%i&qdt=%s'


# ---------------------------------------------------------------------
#
#   INSTANCES
#
# ---------------------------------------------------------------------

# Retourne les cartes, celle pour le commentaire, si existe et partagé
# et celle pour l'original, si partagé
def cards
  ary = []
  ary << card(:original) if shared?(:original)
  ary << card(:comments) if shared?(:comments)
  return ary.join
rescue Exception => e # pour mode sans erreur
  err_mess = "[QDD] Problème d'affichage avec le document ##{id} : #{e.message}"
  send_error(err_mess, self.data.merge(backtrace: e.backtrace.join(RC))) #rescue nil
  "<div class='qdd-card'><div class='bold'>[#{err_mess}]</div></div>"
end #/ cards
alias :out :cards

# Retourne une 'carte du document'
def card(dtype = :original)
  for_original = dtype == :original
  suftype = for_original ? '' : '-comments'
  droute  = DOWNLOAD_ROUTE % [id, dtype]
  inner = ''
  inner << Tag.div(text:(LINK_DOWNLOAD_PDF % [droute, suftype]), class:'fleft')
  inner << Tag.div(text: "#{original_name} <span class='small'>(#{for_original ? 'original' : 'commentaires'})</span>", class:'filename')
  msg = "<label>par</label> #{auteur.pseudo.capitalize}, <label>module</label> “#{etape.module.name}” #{etape.ref}, <label>le</label> #{formated_date(dtype)}."
  inner << Tag.div(text:msg)
  Tag.div(text:inner, class:'qdd-card')
end #/ card

end #/QddDoc
