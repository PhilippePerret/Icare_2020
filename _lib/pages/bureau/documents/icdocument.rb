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
      <img src="./img/icones/pdf.jpg" alt="Document original">
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
    <a href="bureau/documents?op=download&did=#{id}&fd=comments"><img src="./img/icones/pdf-comments.jpg" alt="Document commentaires"></a>
    <span class="libelle inline nopadding">Remis le</span>
    <span class="date">#{formate_date(time_comments,{hour:true})}</span>
  </div>
  #{block_tools(:comments)}
</div>
  HTML
end #/ block_comments

# Le bloc avec les outils
def block_tools(fordoc)
  <<-HTML.strip.freeze
<div class="tools center">
  <select name="partage-#{fordoc}" class="small">
    <option value="1"#{shared?(fordoc) ? ' SELECTED' : ''}>partagé</option>
    <option value="0"#{shared?(fordoc) ? '' : ' SELECTED'}>non partagé</option>
  </select>
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
  require_module('download')
  downloader = Downloader.new(qdddoc.path)
  downloader.download
end #/ download

# Retourne TRUE si le document a été émis un autre jour (plus tard)
# que +time+
def older_than(time)
  Time.at(created_at).strftime('%Y%m%d') < Time.at(time).strftime('%Y%m%d')
end #/ older_than


end#/IcDocument
