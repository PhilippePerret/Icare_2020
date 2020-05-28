# encoding: UTF-8
class HTML
  def lien_retour_bureau
    @lien_retour_bureau ||= '<a href="bureau/home" class="small"><span style="vertical-align:sub;">↩︎</span> bureau</a>'.freeze
  end
end
