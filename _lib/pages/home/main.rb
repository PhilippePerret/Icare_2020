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
    @header << MAIN_LINKS[:overview_s]
    if user.guest?
      @header << MAIN_LINKS[:login_s]
      @header << MAIN_LINKS[:signup_s]
    else
      @header << MAIN_LINKS[:logout_s]
      @header << MAIN_LINKS[:bureau_s]
    end
    @header = @header.join(' ')
  end
end
