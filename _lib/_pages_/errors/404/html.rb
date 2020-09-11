# encoding: UTF-8
=begin
  Page atteinte en cas de mauvaise route
=end
class HTML
  def titre
    "#{Emoji.get('panneau/interdit-pieton').page_title+ISPACE}Voie sans issue"
  end #/ titre
  def build_body
    @body = <<-HTML
<div class="only-message" style="padding-top:2em;">#{user.pseudo}, la route '#{CGI.unescape(param(:r))}' vous a conduit dans une impasse (#{Tag.lien(route:'plan', text:'voir un plan')}).
<div class="center mt4">
  <img id="voie-sans-issue" src="img/icones/voie-sans-issue.png" width="400" alt="Image de voie sans issue" />
</div>
</div>
    HTML
  end #/ build_body
end #/HTML
