# encoding: UTF-8

class HTML
  def titre
    "🎉 Les belles réussites (hall of fame)".freeze
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
                end.join
    File.open(path_erb,'wb'){|f| f.write reussites}
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
