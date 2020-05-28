# encoding: UTF-8
=begin
  Accès interdit à une page
=end
class HTML
  def build_body
    @body = <<-HTML
<div class="only-message">Désolé, mais l’accès à cette page vous est interdit.</div>
<div class="center">#{MAIN_LINKS[:plan]}</div>
    HTML
  end
end #/HTML
