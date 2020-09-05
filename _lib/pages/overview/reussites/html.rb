# encoding: UTF-8
# frozen_string_literal: true

class HTML
  def titre
    "#{Emoji.get('objets/paquet-cadeau').page_title+ISPACE}Les belles réussites (hall of fame)"
  end
  # Code à exécuter avant la construction de la page
  def exec
    update_data_erb if first_is_older_than('data.erb', 'data.yaml', true)
  end
  # Fabrication du body
  def build_body
    @body = deserb('data', self)
  end

  # Actualisation du fichier data.erb
  def update_data_erb
    path_erb = full_path('data.erb')
    reussites = data_reussites.collect do |dreussite|
                  succ = Reussite.new(*dreussite.values)
                  succ.out
                end
    # On insert les deux tables des matières
    reussites.unshift(tdm)
    reussites.insert(-3, tdm)
    File.open(path_erb,'wb'){|f| f.write reussites.join}
  end #/ update_data_erb

  def data_reussites
    @data_reussites ||= deyaml('data')
  end #/ data_reussites

end #/HTML

Reussite = Struct.new(:date, :content) do
  def out
    <<-HTML
<div class="div-reussite p">
  <div class="date">#{date}</div>
  <div class="content">#{content}</div>
</div>
    HTML
  end #/ out
end
