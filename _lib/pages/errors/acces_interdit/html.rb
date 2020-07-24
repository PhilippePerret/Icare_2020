# encoding: UTF-8
=begin
  Accès interdit à une page
=end
class HTML
  def titre
    "#{Emoji.get('nature/eclair').page_title+ISPACE}Accès interdit"
  end #/ titre
  def build_body
    @body = <<-HTML
<div class="only-message">Désolé, mais l’accès à cette page vous est interdit.</div>
<div class="center">#{MainLink[:plan].with(picto:true, titleize:true)}</div>
    HTML
  end
end #/HTML
