# encoding: UTF-8
=begin
  Module chargé quand on est à l'accueil du site, pour avoir une
  page tout à fait différente.
=end
require_module('citation')
class HTML
  def build_body
    @body = deserb('body', self)
  end

  def build_header
    @header = []
    @header << Tag.link(route:'overview/home'.freeze, text:'en savoir plus'.freeze)
    if user.guest?
      @header << MainLink[:login].simple
      @header << MainLink[:signup].simple
    else
      @header << MainLink[:logout].simple
      @header << MainLink[:bureau].simple
    end
    @header = @header.join(' ')
  end
end
