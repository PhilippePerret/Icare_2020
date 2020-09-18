# encoding: UTF-8
=begin
  Gestion d'UN document
  Voir le module 'documents.rb' pour la gestion des listes de documents
=end
require_module('icmodules')
class IcDocument < ContainerClass

# ---------------------------------------------------------------------
#
#     Méthodes d'HELPERS
#
# ---------------------------------------------------------------------
def as_card
  <<-HTML.strip.freeze
<div id="icdocument-#{id}" class="icdocument">
  <div class="infos">
    <div class="name">
      <span class="libelle inline">Nom original</span>
      <span class="original-name">#{original_name}</span>
    </div>
    <div class="right small">#{icetape.ref.capitalize}</div>
  </div>
  <div class="original">
    <div>
      <a href="bureau/documents?op=download&did=#{id}&fd=original"><img src="./img/icones/pdf.jpg" alt="Pictor de document original"></a>
      <span class="libelle inline nopadding">Émis le</span>
      <span class="date">#{formate_date(time_original,{hour:true})}</span>
    </div>
    #{block_tools(:original)}
  </div>
  #{block_comments if has_comments?}
</div>
  HTML
end

def block_comments
  <<-HTML.strip.freeze
<div class="comments">
  <div>
    <a href="bureau/documents?op=download&did=#{id}&fd=comments"><img src="./img/icones/pdf-comments.jpg" alt="Picto de document commentaires"></a>
    <span class="libelle inline nopadding">Remis le</span>
    <span class="date">#{formate_date(time_comments,{hour:true})}</span>
  </div>
  #{block_tools(:comments)}
</div>
  HTML
end #/ block_comments

# Le bloc avec les outils
TAG_LIEN_SHARE = '<a class="discret" href="bureau/documents?op=share&did=%i&fd=%s&mk=%i">%s</a>'.freeze
def block_tools(fordoc)
  is_shared = shared?(fordoc)
  mark_shared = is_shared ? 'Partagé' : 'Non partagé'
  lien_shared = is_shared ? 'ne plus partager' : 'le partager'
  lien_shared = TAG_LIEN_SHARE % [id, fordoc.to_s, is_shared ? 0 : 1, lien_shared]
  <<-HTML.strip.freeze
<div class="tools center">
  <span id="partage-#{id}-#{fordoc}" class="partage-#{fordoc} #{is_shared ? 'shared' : 'not-shared'}">#{mark_shared}</span>
  <span class="ml2">#{lien_shared}</span>
</div>
  HTML
end #/ block_tools

def date_jour
  "<div class='day-div'><span class='day'>#{formate_date(created_at)}</span></div>".freeze
end #/ date_jour
# ---------------------------------------------------------------------
#
#   Méthodes fonctionnelles
#
# ---------------------------------------------------------------------

# Permet de télécharger le document (donc l'original et le commenté)
def proceed_download
  require_module('qdd')
  qdddoc = QddDoc.new(data)
  fordoc = param(:fd).to_sym
  if qdddoc.pdf_exists?(fordoc)
    require_module('download')
    downloader = Downloader.new(qdddoc.path(fordoc))
    downloader.download
  else
    erreur(ERRORS[:cant_find_qdd_document])
  end
end #/ download

# Retourne TRUE si le document a été émis un autre jour (plus tard)
# que +time+
def older_than(time)
  Time.at(created_at.to_i).strftime('%Y%m%d') < Time.at(time.to_i).strftime('%Y%m%d')
end #/ older_than


end#/IcDocument
